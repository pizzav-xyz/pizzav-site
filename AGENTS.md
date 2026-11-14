# AGENTS.md

Personal Hugo site (PizzaV): amber-on-black CRT-terminal homepage built with the vendored **Terminal** theme (panr v4, MIT), deployed as a Cloudflare Worker serving `public/`. No JS framework, no package.json, no test suite.

## Commands

- Dev server: `hugo server` → localhost:1313 (Hugo Extended ≥ 0.90 must be installed locally)
- Build: `hugo --gc --minify` → writes `public/`
- Verification: a successful `hugo` build is the only check this repo has. There is no lint/test/typecheck tooling — don't look for one or invent one.
- `build.sh` is the CI truth (run by Cloudflare via `wrangler.toml [build]`): pins Hugo Extended 0.154.2, Dart Sass 1.97.1, Go 1.25.5, Node 24.12.0. Never run it locally.

## Structure (only the non-obvious)

- `themes/terminal/` — vendored theme, **edit it directly**; it is the source of truth, not a submodule or module cache.
- `themes/terminal/static/` — `favicon.png`, `og-image.png`, `terminal.css` served at site root. Replacing the favicon/og image means replacing these files.
- `layouts/` — site-level overrides only: `extended_head.html` (mastodon `rel="me"`), `extended_footer.html` (88×31 badge strip, enabled; it was once disabled behind a template comment because a broken external badge hung page loads — if loads hang again, check the external `src` URLs in `data/buttons88x31.toml` first), `partials/buttons88x31.html` + `shortcodes/buttons88x31.html`.
- `data/buttons88x31.toml` + `static/88x31/` — 20 badge entries (11 local, 9 external; 2 entries have empty `link` and render as bare images) and their local images; adding a badge touches both. `static/88x31/cc-by-nc-sa.png` is an unreferenced orphan.
- `hugo-theme/` — stray reference copy. **Not part of the build.** Never edit it.
- `public/`, `resources/_gen/`, `.hugo_build.lock` — gitignored build artifacts. Never edit or commit them.

## UI and design system

Before writing or changing any UI:

- Read `DESIGN.md` (element specs + build recipes) and `PRODUCT.md` (voice/audience).
- Colors only via CSS variables (`--background`, `--foreground`, `--accent`); never hardcode colors or radii. `--radius: 0` everywhere.
- Reuse the theme's existing elements/shortcodes before creating anything new; ask before inventing a new token, component, or shortcode.
- Preserve the JS hooks: `.menu__trigger`/`.menu__dropdown` (menu.js) and `.chroma code[data-lang]` (code.js copy buttons).
- Update `DESIGN.md` when an approved pattern changes the source of truth.
- Verify CSS/markup changes with `hugo --gc --minify`, then check the page at desktop width and ≤ 684px.

## Content

- Blog posts belong in `content/posts/` (`contentTypeName` defaults to `posts`); no posts exist yet. Current content: `content/_index.md` (home) only — no demo pages.
- `hugo.toml` defines no `[[menu.main]]` → the header renders the logo only. Menus are single-level only (nesting unsupported).
- Theme shortcodes: `{{< image src=... alt=... position=left|center|right style=... >}}`, `{{< code language=... title=... open=... >}}`, plus the site's own `{{< buttons88x31 >}}` (badge strip, currently unused while the footer partial is disabled), the steps set `{{< steps >}}` / `{{< step href=... >}}` / `{{< step-details title=... open=... >}}` (specs in `DESIGN.md` §"Step rows"), and `{{< step-panel >}}` / `{{< step-panel-reset >}}` (specs in `DESIGN.md` §"Step panel").
- Page params the theme reads: `cover`, `tags`, `author`, `showFullContent`, `Toc`/`TocTitle`, `hideComments`, `dateFormat`.

## Boundaries

- **Always:** build successfully (`hugo --gc --minify`) before claiming done; read `DESIGN.md` before UI changes.
- **Ask first:** changing palette variables or the font, new partials/shortcodes, adding real fenced code blocks (requires adding `[markup.highlight] noClasses = false` — see Gotchas), new external badge URLs.
- **Never:** edit `hugo-theme/`, `public/`, `resources/_gen/`, `.hugo_build.lock`; hardcode hex colors, border radii, or shadow values; commit secrets.

## Gotchas

- `themes/terminal/assets/css/syntax.css` defines `--comment` globally, which `code.css` depends on (`.code-title` uses `var(--comment)`). Removing syntax.css silently breaks the code-title color.
- This site does not set `[markup.highlight] noClasses = false`, so Hugo emits inline Chroma styles and syntax.css's duotone classes are inert for fenced code. Adding real code blocks without adding that config loses the duotone look.
- `themes/terminal/static/terminal.css` is loaded last in `head.html` and wins on conflicts with the theme's `assets/css/*.css`. Put style changes there (or in the matching component CSS file), not in a new cascade layer. It also carries the site's `steps` shortcode styles (appended at the end).
- `hugo.toml` sets `[markup.goldmark.renderer] unsafe = true` (raw HTML allowed in markdown) but has **no** `[markup.highlight]` section — see the next gotcha before adding code blocks.
- Deploy flow: `wrangler.toml [build]` runs `build.sh` during Cloudflare's deploy; the Worker serves `public/` with SPA-style `not_found_handling`. There is no manual deploy step or CI config in the repo.
