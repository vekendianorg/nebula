/**
 * search.js
 * ---------------------------------------------------------------------
 * Site-wide docs search modal. Included on every page (the search
 * button in the nav lives everywhere), but the actual search index is
 * only ever built from docs.html's content — results always link to
 * `docs.html#<section-id>`.
 *
 * Data source: /assets/search-index.json, generated from README.md at
 * build time (see scripts/build-docs.py). Each entry looks like:
 *   { "id": "bitmask", "title": "BitMask", "level": 3, "snippet": "..." }
 *
 * To add more searchable content later (e.g. once individual function
 * references exist), either:
 *   - add more sections to README.md and rerun the build script, or
 *   - extend build-docs.py to also emit entries from another source
 *     into the same search-index.json array. Nothing here needs to
 *     change as long as entries keep the same {id, title, snippet}
 *     shape and `id` matches a real element id on docs.html.
 * ---------------------------------------------------------------------
 */
(function() {
    'use strict';

    var overlay = document.getElementById('search-overlay');
    if (!overlay) return; // page doesn't include the search modal markup

    var input = document.getElementById('search-input');
    var resultsEl = document.getElementById('search-results');
    var closeBtn = document.getElementById('search-close');
    var triggers = document.querySelectorAll('[data-search-trigger]');

    // Every page declares its site root once via data-assets-path (e.g.
    // "/nebula/" on GitHub Pages, "/" on a custom domain). Both the
    // index fetch and the results' links derive from it, so deploying
    // under a different subpath only ever requires changing that one
    // attribute per page, not touching this script.
    var SITE_ROOT = document.body.getAttribute('data-assets-path') || '/';
    var DOCS_URL = SITE_ROOT + 'docs.html';

    var index = null;
    var indexPromise = null;

    /* ================= Index loading ================= */

    function loadIndex() {
        if (indexPromise) return indexPromise;
        indexPromise = fetch(SITE_ROOT + 'assets/search-index.json')
            .then(function(res) { return res.json(); })
            .then(function(data) { index = data; return data; })
            .catch(function() { index = []; return index; });
        return indexPromise;
    }

    /* ================= Rendering helpers ================= */

    function escapeHtml(s) {
        return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    function highlight(text, query) {
        if (!query) return escapeHtml(text);
        var escaped = escapeHtml(text);
        var q = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // escape regex metacharacters in the user's query
        try {
            return escaped.replace(new RegExp('(' + q + ')', 'ig'), '<mark>$1</mark>');
        } catch (e) {
            return escaped;
        }
    }

    var activeIndex = -1;
    var currentResults = [];

    /**
     * Very small ranking heuristic: exact title match > title starts
     * with query > title contains query > snippet contains query.
     * Good enough for a docs page with a few dozen sections; if the
     * content grows a lot, swap this for a proper fuzzy-match library
     * without needing to change anything outside this function.
     */
    function render(query) {
        if (!index) { resultsEl.innerHTML = '<div class="search-empty">Loading\u2026</div>'; return; }

        var q = query.trim().toLowerCase();
        var matches;
        if (!q) {
            matches = index.slice(0, 8); // show a handful of sections by default
        } else {
            matches = index
                .map(function(item) {
                    var score = 0;
                    var titleLower = item.title.toLowerCase();
                    var snippetLower = item.snippet.toLowerCase();
                    if (titleLower === q) score += 100;
                    else if (titleLower.indexOf(q) === 0) score += 60;
                    else if (titleLower.indexOf(q) !== -1) score += 35;
                    if (snippetLower.indexOf(q) !== -1) score += 10;
                    return { item: item, score: score };
                })
                .filter(function(r) { return r.score > 0; })
                .sort(function(a, b) { return b.score - a.score; })
                .map(function(r) { return r.item; })
                .slice(0, 8);
        }

        currentResults = matches;
        activeIndex = matches.length ? 0 : -1;

        if (!matches.length) {
            resultsEl.innerHTML = '<div class="search-empty">No results for \u201c' + escapeHtml(query) + '\u201d</div>';
            return;
        }

        resultsEl.innerHTML = matches.map(function(item, i) {
            return '<a class="search-result' + (i === 0 ? ' active-result' : '') + '" href="' + DOCS_URL + '#' + item.id + '" data-index="' + i + '">' +
                '<div class="search-result-title">' + highlight(item.title, query) + '</div>' +
                (item.snippet ? '<div class="search-result-snippet">' + highlight(item.snippet, query) + '</div>' : '') +
                '</a>';
        }).join('');
    }

    function updateActiveHighlight() {
        var els = resultsEl.querySelectorAll('.search-result');
        els.forEach(function(el, i) {
            el.classList.toggle('active-result', i === activeIndex);
        });
        var activeEl = els[activeIndex];
        if (activeEl) activeEl.scrollIntoView({ block: 'nearest' });
    }

    /* ================= Open / close ================= */

    function open() {
        overlay.classList.add('open');
        loadIndex().then(function() { render(input.value); });
        setTimeout(function() { input.focus(); input.select(); }, 30);
        document.addEventListener('keydown', onKeydown);
    }

    function close() {
        overlay.classList.remove('open');
        document.removeEventListener('keydown', onKeydown);
    }

    function onKeydown(e) {
        if (e.key === 'Escape') {
            close();
        } else if (e.key === 'ArrowDown') {
            e.preventDefault();
            if (currentResults.length) {
                activeIndex = (activeIndex + 1) % currentResults.length;
                updateActiveHighlight();
            }
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (currentResults.length) {
                activeIndex = (activeIndex - 1 + currentResults.length) % currentResults.length;
                updateActiveHighlight();
            }
        } else if (e.key === 'Enter') {
            var el = resultsEl.querySelectorAll('.search-result')[activeIndex];
            if (el) { window.location.href = el.getAttribute('href'); }
        }
    }

    /* ================= Wiring ================= */

    triggers.forEach(function(t) {
        t.addEventListener('click', function(e) {
            e.preventDefault();
            open();
        });
    });

    closeBtn.addEventListener('click', close);
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) close(); // click on the dimmed backdrop, not the panel itself
    });

    input.addEventListener('input', function() {
        render(input.value);
    });

    // Global shortcut: Cmd/Ctrl+K always, or plain "/" when focus isn't
    // already inside a text field (so typing a literal "/" elsewhere
    // still works normally).
    document.addEventListener('keydown', function(e) {
        if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
            e.preventDefault();
            open();
        } else if (e.key === '/' && !overlay.classList.contains('open')) {
            var tag = (document.activeElement && document.activeElement.tagName) || '';
            if (tag !== 'INPUT' && tag !== 'TEXTAREA') {
                e.preventDefault();
                open();
            }
        }
    });
})();
