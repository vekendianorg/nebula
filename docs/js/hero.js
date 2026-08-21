/**
 * hero.js
 * ---------------------------------------------------------------------
 * Handles the staggered fade-in of the hero title/subtitle/actions on
 * the home page (index.html only — safe to include elsewhere, it's a
 * no-op if the elements aren't present).
 *
 * Why this is its own file instead of an inline <script>:
 * Mobile browsers can restore a page from the back-forward cache
 * (bfcache) when the user swipes/taps back. When that happens the DOM
 * is exactly as it was when the user left — if the reveal timers had
 * already fired, `.visible` classes are still there and everything is
 * fine. But on some browsers a bfcache restore re-runs page load in a
 * way that skips a plain `DOMContentLoaded`-bound timer, or the tab was
 * frozen mid-timer, leaving the hero permanently invisible (opacity: 0
 * from the base CSS) until something else adds `.visible`.
 *
 * Fix: also run the reveal on the `pageshow` event, which fires both on
 * a normal load AND on a bfcache restore (check `event.persisted`).
 * Re-running is harmless — classList.add is idempotent.
 * ---------------------------------------------------------------------
 */
(function() {
    'use strict';

    var TITLE_DELAY = 250;
    var SUBTITLE_DELAY = 550;
    var ACTIONS_DELAY = 800;

    var timers = [];

    function clearTimers() {
        timers.forEach(clearTimeout);
        timers = [];
    }

    function reveal() {
        var title = document.getElementById('hero-title');
        var subtitle = document.getElementById('hero-subtitle');
        var actions = document.getElementById('hero-actions');
        if (!title && !subtitle && !actions) return; // not the home page

        clearTimers();

        // If elements are already visible (bfcache restore after timers
        // already fired once), nothing to do.
        var alreadyVisible = title && title.classList.contains('visible');
        if (alreadyVisible) return;

        if (title) timers.push(setTimeout(function() { title.classList.add('visible'); }, TITLE_DELAY));
        if (subtitle) timers.push(setTimeout(function() { subtitle.classList.add('visible'); }, SUBTITLE_DELAY));
        if (actions) timers.push(setTimeout(function() { actions.classList.add('visible'); }, ACTIONS_DELAY));
    }

    // Normal first load
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        reveal();
    } else {
        document.addEventListener('DOMContentLoaded', reveal);
    }

    // Back/forward navigation, including bfcache restores on mobile Safari/Chrome
    window.addEventListener('pageshow', reveal);
})();
