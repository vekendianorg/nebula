#!/usr/bin/env python3
"""
build_docs.py
=============================================================================
Generates docs.html, its sidebar table of contents, and
assets/search-index.json from the source files in content/.

WHY THIS EXISTS
----------------
Earlier versions of this site had README content pasted directly into
docs.html by hand. That's fine for a one-time build, but painful the
moment you want to add a second doc, add per-function API reference
pages, or just fix a typo without wading through 400 lines of generated
HTML looking for the right spot.

This script is the single source of truth for turning readable content
files into the site's HTML. Edit content/, rerun this script, done.

CONTENT SOURCES
----------------
  content/guide.md         The prose guide (philosophy, install, usage,
                            memory layout, etc.) — one big markdown file,
                            same as the project's README.

  content/api/*.md         Per-module API reference. Each file documents
                            one module (e.g. gamestatus.md documents the
                            GameStatus module) using ### headings for each
                            function. See content/api/gamestatus.md for
                            the exact format and a full example — new
                            files are picked up automatically, nothing
                            to register elsewhere.

HOW TO ADD CONTENT
----------------
  New function on an existing module:
    Add a new "### Module.functionName(...)" block to that module's
    file in content/api/. Rerun this script.

  New module:
    Create content/api/<modulename>.md, add ### blocks for its
    functions. Rerun this script. No other file needs to change.

  New guide section:
    Add a new "## Heading" (or "### Sub-heading") to content/guide.md.
    Rerun this script.

USAGE
----------------
    python3 scripts/build_docs.py

Requires the `markdown` package (for the guide) — install with:
    pip install markdown --break-system-packages
Syntax highlighting additionally uses `pygments`, which `markdown`'s
codehilite extension depends on for the same command.
=============================================================================
"""

import re
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENT_DIR = ROOT / "content"
API_DIR = CONTENT_DIR / "api"
ASSETS_DIR = ROOT / "assets"
DOCS_HTML_PATH = ROOT / "docs.html"
DOCS_TEMPLATE_PATH = ROOT / "scripts" / "docs_template.html"

try:
    import markdown
except ImportError:
    print("ERROR: the 'markdown' package is required.\n"
          "Install it with: pip install markdown --break-system-packages",
          file=sys.stderr)
    sys.exit(1)


LANG_LABELS = {"lua": "Lua", "text": "Text", "bash": "Shell", "sh": "Shell", "json": "JSON"}


def strip_html_comments(text):
    """Source .md files use leading HTML comments as author-facing
    instructions (see content/api/gamestatus.md). Markdown passes HTML
    comments through untouched, so without this they'd render as
    invisible-but-present <!-- --> nodes in the final page. Strip them
    before rendering."""
    return re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL)


def slugify(text):
    """Turn a heading string into a URL-safe #anchor id, matching the
    same convention GitHub/python-markdown's TOC extension uses, so
    links written by hand (e.g. "see [Dangerous fields](#dangerous-fields)")
    keep working."""
    text = text.strip().lower()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s]+", "-", text)
    return text


def extract_fence_languages(md_text):
    """python-markdown's codehilite doesn't expose each block's declared
    language on the rendered element, so we scan the raw markdown fences
    ourselves, in document order, and zip them onto the rendered <div
    class="hl"> blocks afterwards. Blocks without a language tag (```
    alone) are labeled 'text'."""
    blocks = re.findall(r"```(\w*)\n.*?```", md_text, re.DOTALL)
    return [lang or "text" for lang in blocks]


def render_markdown_with_lang_tags(md_text):
    """Render markdown to HTML, then tag each syntax-highlighted code
    block with a data-lang attribute so docs.js can show a language
    label without re-parsing anything client-side."""
    langs = extract_fence_languages(md_text)

    md = markdown.Markdown(
        extensions=["fenced_code", "tables", "toc", "codehilite"],
        extension_configs={
            "codehilite": {"guess_lang": False, "css_class": "hl"},
            "toc": {"anchorlink": False, "permalink": False},
        },
    )
    html = md.convert(md_text)

    counter = {"i": 0}

    def tag_lang(match):
        lang = langs[counter["i"]] if counter["i"] < len(langs) else "text"
        counter["i"] += 1
        return f'<div class="hl" data-lang="{lang}">'

    html = re.sub(r'<div class="hl">', tag_lang, html)
    return html, md


def flatten_toc(tokens, level_filter=(2, 3)):
    """python-markdown's toc_tokens is a nested tree; flatten it to a
    simple list of (level, id, name) in document order."""
    out = []
    for t in tokens:
        out.append((t["level"], t["id"], t["name"]))
        out.extend(flatten_toc(t["children"], level_filter))
    return [item for item in out if item[0] in level_filter]


def build_toc_html(toc_items):
    """Render the flattened (level, id, name) list as the nested <ul>
    the sidebar CSS expects: h2s as top-level items, h3s nested under
    the preceding h2."""
    parts = ['<ul class="toc-list">']
    i, n = 0, len(toc_items)
    while i < n:
        level, id_, name = toc_items[i]
        if level == 2:
            parts.append(f'<li><a href="#{id_}" class="toc-link" data-target="{id_}">{name}</a>')
            sub = []
            j = i + 1
            while j < n and toc_items[j][0] == 3:
                sub.append(toc_items[j])
                j += 1
            if sub:
                parts.append('<ul class="toc-sublist">')
                for _, sid, sname in sub:
                    parts.append(f'<li><a href="#{sid}" class="toc-link toc-sub" data-target="{sid}">{sname}</a></li>')
                parts.append("</ul>")
            parts.append("</li>")
            i = j
        else:
            i += 1
    parts.append("</ul>")
    return "".join(parts)


def build_search_index_from_guide(md_text):
    """Split content/guide.md into ##/### sections and turn each into a
    lightweight {id, title, level, snippet} search entry. Mirrors the
    same heading-splitting logic used for the TOC so ids always match
    real anchors on the page."""
    lines = md_text.split("\n")
    sections = []
    current = None
    in_code = False

    for line in lines:
        if line.strip().startswith("```"):
            in_code = not in_code
            if current:
                current["body"].append(line)
            continue
        m = re.match(r"^(#{1,3})\s+(.*)", line) if not in_code else None
        if m:
            level = len(m.group(1))
            title = m.group(2).strip()
            if level == 1:
                continue  # the page's own h1, not a linkable section
            if current:
                sections.append(current)
            current = {"level": level, "title": title, "id": slugify(title), "body": []}
        elif current is not None:
            current["body"].append(line)
    if current:
        sections.append(current)

    entries = []
    for s in sections:
        body_text = "\n".join(s["body"])
        body_text = re.sub(r"```.*?```", " ", body_text, flags=re.DOTALL)
        body_text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", body_text)  # markdown links -> plain text
        body_text = re.sub(r"[`*_#>|]", " ", body_text)
        body_text = re.sub(r"^\s*-\s+", "", body_text, flags=re.MULTILINE)
        body_text = re.sub(r"\s+", " ", body_text).strip()
        entries.append({
            "id": s["id"],
            "title": s["title"],
            "level": s["level"],
            "snippet": body_text[:220],
        })
    return entries


def build_search_index_from_api(api_html_sections):
    """API reference functions get their own search entries too, so
    searching "GameStatus.set" jumps straight to that function even
    though it also appears in the guide's higher-level prose."""
    entries = []
    for module_name, functions in api_html_sections:
        for fn in functions:
            entries.append({
                "id": fn["id"],
                "title": fn["signature"],
                "level": 3,
                "snippet": fn["summary"],
            })
    return entries


def parse_api_module(path):
    """Parse one content/api/<module>.md file into a module heading
    (## Module) plus a list of function entries (### blocks), each
    kept as raw markdown so it can be rendered with the same renderer
    (and thus the same styling/highlighting) as the guide."""
    text = strip_html_comments(path.read_text(encoding="utf-8"))

    module_match = re.match(r"^\s*##\s+(.+)", text, re.MULTILINE)
    module_name = module_match.group(1).strip() if module_match else path.stem

    # Split on ### headings (function definitions), keeping the heading text
    parts = re.split(r"^###\s+(.+)$", text, flags=re.MULTILINE)
    # parts[0] is the module intro (module heading + description);
    # parts[1], parts[2], parts[3], parts[4], ... alternate signature, body
    module_intro_md = parts[0]

    functions = []
    for i in range(1, len(parts), 2):
        signature = parts[i].strip()
        body_md = parts[i + 1] if i + 1 < len(parts) else ""
        # Anchor id is derived from just the callable path (e.g.
        # "GameStatus.get" -> "gamestatus-get"), not the full signature
        # with parameter names, so renaming a parameter later doesn't
        # change/break the #anchor other pages or search results link to.
        callable_path = signature.split("(")[0].strip()
        fn_id = slugify(callable_path.replace(".", "-"))
        # First non-empty line of the body (before Parameters/Returns/code)
        # becomes the search snippet.
        first_para = ""
        for line in body_md.strip().split("\n"):
            line = line.strip()
            if line and not line.startswith("**") and not line.startswith("```"):
                first_para = line
                break
        functions.append({
            "id": fn_id,
            "signature": signature,
            "body_md": body_md,
            "summary": first_para[:220],
        })

    return module_name, module_intro_md, functions


def render_api_section(renderer_fn):
    """Render every content/api/*.md file into one HTML blob for the
    'API Reference' part of docs.html, plus TOC entries and search
    entries for each module and function.

    `renderer_fn` is render_markdown_with_lang_tags, passed in so this
    function doesn't need to import markdown itself.
    """
    if not API_DIR.exists():
        return "", [], []

    api_files = sorted(API_DIR.glob("*.md"))
    if not api_files:
        return "", [], []

    html_parts = ['<h2 id="api-reference">API Reference</h2>']
    toc_items = [(2, "api-reference", "API Reference")]
    search_sections = []

    for path in api_files:
        module_name, module_intro_md, functions = parse_api_module(path)
        module_id = slugify(module_name)

        intro_html, _ = renderer_fn(module_intro_md)
        # module_intro_md still contains the "## ModuleName" heading;
        # python-markdown will render it as an <h2> (with its own
        # auto-generated id from the toc extension) — retarget it to
        # h3-under-API-Reference with OUR id (matching what the TOC
        # links point at), not the auto-generated one.
        intro_html = intro_html.replace("<h2 id=\"", '<h3 id="__placeholder__" data-drop-id="', 1)
        intro_html = re.sub(r'<h3 id="__placeholder__" data-drop-id="[^"]*"', f'<h3 id="{module_id}"', intro_html, count=1)
        intro_html = intro_html.replace("</h2>", "</h3>", 1)
        html_parts.append(intro_html)
        toc_items.append((3, module_id, module_name))

        for fn in functions:
            fn_html, _ = renderer_fn(f"#### {fn['signature']}\n\n{fn['body_md']}")
            # Same id-collision issue as above: strip the toc extension's
            # auto-generated id from the <h4> before writing ours.
            fn_html = re.sub(r'<h4 id="[^"]*"', f'<h4 id="{fn["id"]}" class="fn-signature"', fn_html, count=1)
            html_parts.append(fn_html)
            # Functions are intentionally left out of the sidebar TOC —
            # a module with many functions would otherwise flood the
            # sidebar. They're still fully reachable via search and via
            # direct #anchor links.

        search_sections.append((module_name, functions))

    return "\n".join(html_parts), toc_items, build_search_index_from_api(search_sections)


def apply_code_block_language_labels_css_hook():
    """No-op placeholder retained for clarity: the actual language-label
    UI (the little 'LUA' / 'TEXT' pill above each code block) is added
    client-side by js/docs.js reading the data-lang attribute this
    script writes. Nothing to render here — see js/docs.js if you need
    to change how labels are displayed."""
    pass


def main():
    if not DOCS_TEMPLATE_PATH.exists():
        print(f"ERROR: template not found at {DOCS_TEMPLATE_PATH}", file=sys.stderr)
        sys.exit(1)

    guide_md = (CONTENT_DIR / "guide.md").read_text(encoding="utf-8")
    guide_html, md_instance = render_markdown_with_lang_tags(guide_md)
    guide_toc = flatten_toc(md_instance.toc_tokens)

    api_html, api_toc_items, api_search_entries = render_api_section(render_markdown_with_lang_tags)

    full_toc = guide_toc + api_toc_items
    toc_html = build_toc_html(full_toc)

    full_body_html = guide_html + ("\n" + api_html if api_html else "")

    template = DOCS_TEMPLATE_PATH.read_text(encoding="utf-8")
    output = template.replace("__TOC_HTML__", toc_html).replace("__DOC_BODY__", full_body_html)
    DOCS_HTML_PATH.write_text(output, encoding="utf-8")
    print(f"wrote {DOCS_HTML_PATH.relative_to(ROOT)} ({len(output):,} bytes)")

    guide_search_entries = build_search_index_from_guide(guide_md)
    search_index = guide_search_entries + api_search_entries
    search_index_path = ASSETS_DIR / "search-index.json"
    search_index_path.write_text(json.dumps(search_index, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {search_index_path.relative_to(ROOT)} ({len(search_index)} entries)")


if __name__ == "__main__":
    main()
