(function() {
    'use strict';

    /* ================= Mobile TOC toggle ================= */
    var tocToggle = document.getElementById('toc-toggle');
    var docSidebar = document.getElementById('doc-sidebar');
    if (tocToggle && docSidebar) {
        tocToggle.addEventListener('click', function() {
            docSidebar.classList.toggle('open');
            tocToggle.classList.toggle('open');
        });
    }

    /* ================= TOC link scrolling ================= */
    var tocLinks = document.querySelectorAll('.toc-link');
    tocLinks.forEach(function(link) {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            var id = link.dataset.target;
            var isMobile = window.innerWidth <= 860;

            if (isMobile && docSidebar) {
                docSidebar.classList.remove('open');
                tocToggle.classList.remove('open');
            }

            // Wait for the sidebar-collapse reflow to finish before measuring
            // the target's position, otherwise scrollIntoView jumps to the
            // wrong spot because the layout above it just changed height.
            requestAnimationFrame(function() {
                requestAnimationFrame(function() {
                    var target = document.getElementById(id);
                    if (target) {
                        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                    history.replaceState(null, '', '#' + id);
                });
            });
        });
    });

    /* ================= Scrollspy ================= */
    var headings = document.querySelectorAll('.doc-content h2[id], .doc-content h3[id]');
    function updateScrollSpy() {
        var scrollPos = window.scrollY + 100;
        var current = null;
        headings.forEach(function(h) {
            if (h.offsetTop <= scrollPos) current = h.id;
        });
        tocLinks.forEach(function(link) {
            link.classList.toggle('active', link.dataset.target === current);
        });
    }
    window.addEventListener('scroll', updateScrollSpy, { passive: true });
    updateScrollSpy();

    /* ================= Deep-link to a heading on load ================= */
    if (location.hash) {
        var target = document.getElementById(location.hash.slice(1));
        if (target) {
            requestAnimationFrame(function() {
                target.scrollIntoView({ block: 'start' });
            });
        }
    }

    /* ================= Code blocks: language label + copy button ================= */
    var LANG_LABELS = { lua: 'Lua', text: 'Text', bash: 'Shell', sh: 'Shell', json: 'JSON' };

    document.querySelectorAll('.doc-content .hl').forEach(function(hl) {
        var lang = hl.getAttribute('data-lang') || 'text';
        var label = LANG_LABELS[lang] || lang;

        var wrapper = document.createElement('div');
        wrapper.className = 'code-block';
        hl.parentNode.insertBefore(wrapper, hl);

        var head = document.createElement('div');
        head.className = 'code-block-head';

        var langEl = document.createElement('span');
        langEl.className = 'code-lang';
        langEl.textContent = label;
        head.appendChild(langEl);

        var btn = document.createElement('button');
        btn.className = 'copy-btn';
        btn.textContent = 'Copy';
        btn.addEventListener('click', function() {
            var codeEl = hl.querySelector('code') || hl;
            var text = codeEl.innerText;
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(text).then(function() {
                    btn.textContent = 'Copied';
                    btn.classList.add('copied');
                    setTimeout(function() { btn.textContent = 'Copy'; btn.classList.remove('copied'); }, 1600);
                });
            }
        });
        head.appendChild(btn);

        wrapper.appendChild(head);
        wrapper.appendChild(hl);
    });

    /* ================= Docs content entrance stagger ================= */
    var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (!reduced) {
        var items = document.querySelectorAll('.doc-content > *');
        items.forEach(function(el, i) {
            el.style.opacity = '0';
            el.style.transform = 'translateY(8px)';
            el.style.animation = 'pageEnter 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards';
            el.style.animationDelay = (0.05 + Math.min(i, 10) * 0.025) + 's';
        });
    }
})();
