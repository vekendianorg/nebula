# nebula-site

Source for the Nebula SDK website (`https://vekendianorg.github.io/nebula/`).

This is a static site — no framework, no bundler, no build step required
to *view* it. There is a small Python build script for regenerating the
documentation page from source content; everything else is plain
HTML/CSS/JS you can edit directly.

## Layout

```
index.html          Home page
docs.html            Documentation — GENERATED, see below. Don't hand-edit.
license.html         License page
404.html              Custom not-found page

css/style.css         All styles, shared across every page

js/particles.js       Background particle animation (shared)
js/nav.js              Page-transition + active nav-link logic (shared)
js/hero.js             Home page's title/subtitle/button fade-in
js/docs.js              Docs page: TOC scroll-spy, mobile TOC toggle, code-block copy buttons + language labels
js/search.js            Search modal (used on every page, indexes docs.html content)

content/guide.md        Prose documentation source (philosophy, install, usage, etc.)
content/api/*.md         Per-module API reference source — one file per module.
                          See content/api/gamestatus.md for the format and
                          a full worked example.

scripts/build_docs.py    Regenerates docs.html + assets/search-index.json
                          from content/. Run this after editing anything
                          in content/.
scripts/docs_template.html  The HTML shell build_docs.py fills in. Edit
                              this (not docs.html) if you need to change
                              the docs page's chrome — nav, sidebar
                              wrapper, search modal markup, etc.

assets/                 Favicons, OG share image, generated search index
robots.txt, sitemap.xml, site.webmanifest
```

## Adding documentation

**Add a function to an existing module** (e.g. a new `GameStatus` method):
Open `content/api/gamestatus.md`, copy an existing `### Module.func(args)`
block, edit it, rerun the build script.

**Document a new module**: Create `content/api/<modulename>.md` following
the same format (see the comment at the top of `gamestatus.md`). New
files under `content/api/` are picked up automatically — nothing else to
register.

**Edit the prose guide** (philosophy, install steps, memory layout,
etc.): edit `content/guide.md` directly, same as editing a README.

After changing anything in `content/`, regenerate the site:

```bash
pip install markdown --break-system-packages   # one-time, if not already installed
python3 scripts/build_docs.py
```

This rewrites `docs.html` and `assets/search-index.json`. Both are
generated files — don't hand-edit `docs.html`, your changes will be
overwritten next time someone runs the build script. If you need to
change the docs page's surrounding chrome (nav bar, sidebar container,
search modal), edit `scripts/docs_template.html` instead.

## Editing everything else

`index.html`, `license.html`, and `404.html` are plain hand-written HTML
— edit them directly, no build step. Same for `css/style.css` and all of
`js/`.

## Local preview

Any static file server works, e.g.:

```bash
python3 -m http.server 8000
```

Note that all internal links/asset paths are rooted at `/nebula/` to
match this project's GitHub Pages deployment path
(`vekendianorg.github.io/nebula/`). If you deploy this elsewhere (a
custom domain, a different subpath), you'll need to update:

- Every `href="/nebula/...` and `src="/nebula/...` in the four HTML
  pages (and in `scripts/docs_template.html`, since docs.html is
  generated from it)
- The `data-assets-path="/nebula/"` attribute on `<body>` in each page
  (this is what `search.js` and the nav-highlighting logic use — it's
  the one place that drives those two behaviors, so update it there
  rather than hunting through the JS)
- `sitemap.xml`, `robots.txt`, and the canonical/OG URLs in each page's
  `<head>`

## Deployment

This is a GitHub Pages project site. Pushing to the branch GitHub Pages
is configured to serve from is the entire deployment step — no CI build
required, since `docs.html` is committed as a regular file (it's
generated locally by `scripts/build_docs.py`, then committed like any
other change).
