/**
 * nav.js
 * ---------------------------------------------------------------------
 * Shared, site-wide navigation behavior. Included on every page.
 *
 * Responsibilities:
 *   1. Fade the page in on load (avoids a flash of unstyled content).
 *   2. Animate internal link clicks with a brief "exit" transition
 *      before the browser actually navigates.
 *   3. Clean up that exit-transition state if the page is restored
 *      from the back-forward cache (see the bfcache note below).
 *   4. Highlight the current page's link in the top nav.
 *
 * This file has no dependencies on the other page scripts (docs.js,
 * search.js, hero.js) — it's safe to include on any page by itself.
 * ---------------------------------------------------------------------
 */
(function() {
    'use strict';

    /* ================= 1. Fade in on load ================= */
    function markReady() {
        document.body.classList.add('ready');
    }
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        requestAnimationFrame(markReady);
    } else {
        document.addEventListener('DOMContentLoaded', markReady);
    }

    /* ================= 2. Animated internal navigation ================= */
    var reducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var EXIT_ANIMATION_MS = 180; // keep in sync with .page-root leave animation duration in style.css

    document.addEventListener('click', function(e) {
        var link = e.target.closest('a[href]');
        if (!link) return;
        if (link.target === '_blank' || link.hasAttribute('download')) return;
        if (link.dataset.noTransition !== undefined) return; // opt-out escape hatch, e.g. the logo link

        var url;
        try { url = new URL(link.href, location.href); } catch (err) { return; }

        if (url.origin !== location.origin) return; // external link, let the browser handle it
        if (url.pathname === location.pathname && url.hash) return; // in-page anchor, no page change
        if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || e.button !== 0) return; // open-in-new-tab etc.
        if (reducedMotion) return;

        e.preventDefault();
        document.body.classList.add('page-exit');
        window.setTimeout(function() {
            window.location.href = link.href;
        }, EXIT_ANIMATION_MS);
    });

    /* ================= 3. bfcache safety net =================
     * Mobile browsers can restore a page from the back-forward cache
     * (bfcache) instead of reloading it — e.g. when the user swipes or
     * taps the browser back button. When that happens the DOM comes
     * back exactly as it was at the moment the user left the page.
     *
     * If they had just clicked a link (triggering the `page-exit` class
     * above) and then navigated back before the 180ms timeout fired,
     * the cached page can be restored with `page-exit` still applied —
     * which leaves it invisible, and there's no further script about to
     * run that would ever remove it.
     *
     * `pageshow` fires on every page display, including bfcache
     * restores (check `event.persisted` if you need to distinguish
     * them). Clearing the class here is a cheap, always-safe no-op on
     * a normal load and the actual fix on a bfcache restore.
     */
    window.addEventListener('pageshow', function() {
        document.body.classList.remove('page-exit');
    });

    /* ================= 4. Active nav link ================= */
    // Compare full pathnames (not just the trailing segment) so this
    // keeps working regardless of which subpath the site is deployed
    // under (e.g. GitHub Pages project sites live under /repo-name/).
    var currentPath = location.pathname.replace(/\/index\.html$/, '/');
    document.querySelectorAll('.nav-link').forEach(function(link) {
        var linkPath = link.getAttribute('data-path');
        if (linkPath && currentPath === linkPath) {
            link.classList.add('active');
        }
    });
})();
