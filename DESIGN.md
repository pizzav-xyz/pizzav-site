# DESIGN.md

Visual source of truth for this site. Read before writing or changing any UI. Every element below has a **spec** (what it looks like and when to use it) and a **recipe** (where it lives and how to build/extend it). All values are verified from `themes/terminal/assets/*.css` and `themes/terminal/static/terminal.css`.

---

## 1. Visual theme

The site is permanently a **black CRT terminal**: pure black background, monochrome amber text, sharp corners, monospace everything. It must never drift toward a polished SaaS look (see `PRODUCT.md` anti-references). Any new element must be expressible in exactly three colors: black, amber, and translucent amber.

## 2. Color palette (roles and intent)

**Tokens live in** `themes/terminal/assets/css/terminal.css` (`:root`) and `themes/terminal/assets/css/main.css` (`:root`, identical values). Never copy a hex; always use the var.

| Token | Value | Intent |
|---|---|---|
| `--background` | `#000000` | Page and surface background |
| `--foreground` | `#ffaf00` | Body text, table/fieldset borders |
| `--accent` | `#ffaf00` | Links, interactive borders, buttons, bullets, emphasis |
| `--radius` | `0` | Corner radius — global zero |

**Derived tones** (defined once, reused by intent):

| Token | Definition | Intent | Used for |
|---|---|---|---|
| `--first-tone` | `var(--accent)` | full amber | primary syntax tokens |
| `--second-tone` | accent at 70% | dimmed amber | secondary syntax tokens |
| `--comment` | foreground at 50% | half-faded amber | comments, code-title label |
| `--code-border` | foreground at 10% | faint amber | code/highlight borders |

**Opacity/dim roles** (achieved with `color-mix(in srgb, …, transparent)` — never invent a gray or a second hue):

| Mix | Intent |
|---|---|
| accent 5% + bg | code and pre background tint |
| foreground 10% | hairline separators between posts |
| foreground 25% | inline code / pre borders |
| foreground 50% | footnotes, comments |
| foreground 65% | post meta line, footer (via `opacity: 0.65`) |
| accent 15% | button hover wash |
| accent 45% | `<mark>` highlight |

**The single sanctioned raw color:** `#ccc` as the 88×31 footer top border in `layouts/partials/extended_footer.html`. Pre-existing site quirk; do not propagate it anywhere else.

## 3. Typography

- **One font only: Fira Code** (fallbacks JetBrains Mono → Monaco → Consolas → Ubuntu Mono → monospace). Loaded via Google Fonts CDN import in `terminal.css`. Adding any second typeface requires approval.
- Base `1rem` / `1.54` line-height; drops to `0.95rem` below 684px.
- Heading scale (all weight 600): h1 ×1.45, h2 ×1.35, h3 ×1.15, h4–h6 ×1.0.
- Bold (600) applies to headings, `b`/`strong`, `th`, `button` — nothing else.
- Long-form text = body paragraphs; headings = page/post titles; everything is the same face. There is no display face.

## 4. Component styles (spec + recipe per element)

### Header + logo
**Use for:** site identity, top of every page.
**Spec:** solid amber block with black bold text (`padding: 5px 10px`), followed by a dashed "cable" line filling the rest of the row (2px amber dashes, 10px gap, via `repeating-linear-gradient`). Hidden entirely in `@media print`.
**Recipe:** markup `themes/terminal/layouts/partials/logo.html`; CSS `themes/terminal/assets/css/header.css` (`.header`, `.header__logo::after`, `.logo`). Link target comes from `params.Logo.logoHomeLink` or `baseURL`.
**Never:** replace the dashed line with a solid border, or give the logo text a different color.

### Desktop navigation
**Use for:** horizontal menu links under the header (currently unused — no menu configured).
**Spec:** plain amber text links, 20px gaps, no decoration beyond color. Overflow items go into a "Show more ▾" trigger that opens an absolute dropdown: black background, **2px solid amber border**, 10px padding, z-index 99.
**Recipe:** markup `themes/terminal/layouts/partials/menu.html`; CSS `themes/terminal/assets/css/menu.css` (`.navigation-menu`, `.menu__dropdown`, `.open`); configured via `[languages.en.menu.main]` in `hugo.toml` with `showMenuItems`.
**Never:** nest menu children (unsupported), or rely on the dropdown's box-shadow (it's black-on-black decorative legacy).

### Mobile menu
**Use for:** menu access ≤ 684px when desktop nav hides.
**Spec:** bordered "Menu ▾" trigger (2px amber border); dropdown right-aligned.
**Recipe:** markup `themes/terminal/layouts/partials/mobile-menu.html`; CSS `menu.css`; JS `themes/terminal/assets/js/menu.js` toggles `.open` on `.menu` and closes on body click / resize.
**Never:** rename `.menu__trigger` / `.menu__dropdown` — menu.js binds to them; renaming breaks toggling and close-on-outside-click.

### Buttons
**Use for:** actions. Max one emphasized action per view; the rest should be `.link`/`.inline` (plain text).
**Don't use for:** navigation inside content (plain links are the terminal style).
**Anatomy/states:** transparent background, **4px solid accent border**, bold amber text, `--radius` corners (0), `padding: 5px 18px` (base `<button>`, from `terminal.css`). Hover = 15% accent wash; focus-visible = 1px amber outline, 2px offset.
**Variants** (`themes/terminal/assets/css/buttons.css`): `.outline` (borderless emphasis), `.link` (no border/background, plain text), `.small` (0.8× font), `.wide` (min-width 200px, `padding: 14px 24px`), `.inline` / `.read-more` (degenerates to a plain amber link).
**Recipe:** real example from the theme: `<a class="read-more button inline" href="{{ .RelPermalink }}">[{{ $.Site.Params.ReadMore }}]</a>` — brackets are literal markup, part of the terminal idiom.
**Never:** rounded corners, non-token colors, or box-shadows on buttons.

### Pagination (post lists)
**Use for:** moving between pages of posts.
**Spec:** centered row of buttons: `< [Newer posts]` `::` `[Older posts] >`, ellipsis-truncated, hidden in print.
**Recipe:** markup `themes/terminal/layouts/partials/pagination.html`; CSS `themes/terminal/assets/css/pagination.css` (`.pagination__buttons`, `.prev`/`.next`, `.button__text`); labels from `newerPosts`/`olderPosts` params.

### Post navigation (single posts)
**Use for:** previous/next post links on a post page.
**Spec:** "READ OTHER POSTS" label — 0.8×, uppercase, letter-spaced — centered on top of a 2px amber `<hr>` (label gets black background to punch through the line), then prev/next title buttons.
**Recipe:** markup `themes/terminal/layouts/partials/posts_pagination.html`; same CSS as above.

### Post card (list item)
**Use for:** each post on the home/list pages.
**Spec:** 30px vertical padding; 10%-opacity amber hairline between posts; h2 title in amber with a **double 3px dotted amber underline** (border-bottom + a `::after` copy 2px lower); meta line dimmed to 65% with literal `::` separators; amber `#tags`; excerpt; `[Read more]` inline button.
**Recipe:** templates `_default/index.html` (home), `list.html`, `term.html`; CSS `themes/terminal/assets/css/post.css` (`.post`, `.post-title`, `.post-meta`).
**Never:** a single underline or a solid rule instead of the double-dotted underline — it's the signature post-title look.

### Post meta line
**Spec:** dim (65%) row, `::` separators auto-injected via `::before` on every non-first child. Order: date `[Updated: date]` `::` author `::` `N min read (N words)`.
**Recipe:** partials `post-date.html`, `post-lastmod.html`; params `dateFormat`, `showLastUpdated`, `readingTime`, `updatedDatePrefix`.

### Tags
**Spec:** amber `#tag` links → `/tags/<name>/`. Tag index page lists `name [count]` with amber `-` dash bullets (`.terms`).
**Recipe:** rendered inline in list/single templates; terms pages via `_default/terms.html` + `term.html`; CSS `themes/terminal/assets/css/terms.css`.

### Table of contents
**Use for:** long posts only (opt-in per page).
**Spec:** plain block, 40px vertical margins, h2 title from `TocTitle`.
**Recipe:** `_default/single.html`; front-matter `Toc: true`, `TocTitle: "..."`.

### Heading anchors
**Spec:** amber `#` after each heading, invisible until the heading is hovered.
**Recipe:** regex-wrapped `<a class="hanchor">` injected in `_default/single.html`; visibility handled in `post.css` (`h1:hover .hanchor …`).

### Inline code
**Spec:** 5% amber tint background, 1px border at 25% mix, 0.95em, slightly dimmed amber text, `padding: 0 6px`.
**Recipe:** plain markdown backticks; styled in `terminal.css` (`code`, `code code` resets).
**Never:** hand-style code spans — they inherit from the tokens above.

### kbd
**Spec:** keycap look — amber left/right borders, thick **4px amber bottom border**, `border-radius: 4px` (**the only intentional rounding on the site**), same tint background as code.
**Recipe:** `<kbd>` in content; `terminal.css`.

### Code blocks (fenced / highlight)
**Use for:** any real code snippet in content.
**Spec:** `pre` with 5% tint background and faint 25% border; wrapped in `.highlight` with a 1px faint border. The JS bundle injects a `.code-title` bar above each block: uppercase language name in 50%-dim amber + a small **Copy** button (13px, faint 1px border, flashes "Copied" for 1s).
**Recipe:** JS hook is `.chroma code[data-lang]` in `themes/terminal/assets/js/code.js` — preserve it. Duotone coloring comes from `themes/terminal/assets/css/syntax.css` via `--first-tone` / `--second-tone` / `--comment`.
**Gotcha:** duotone classes are inert until `hugo.toml` adds `[markup.highlight] noClasses = false` (see AGENTS.md Gotchas). Ask before enabling.

### Collapsable code (`{{< code >}}`)
**Use for:** long optional snippets; collapsible by default.
**Spec:** `<details>` with 1px amber border; uppercase language badge; summary row gets a 10% amber wash on hover; `open="true"` pre-expands.
**Recipe:** `{{< code language="css" title="Title" open="true" >}} … {{< /code >}}`; template `themes/terminal/layouts/shortcodes/code.html`; CSS `code.css` (`.collapsable-code`). `language` is mandatory.

### Step rows (`{{< steps >}}`)
**Use for:** numbered walkthroughs and how-to instructions as clickable numbered rows (extracted from the site's original Style E5 demo; site-only pattern, not upstream theme).
**Don't use for:** plain lists (that's what `ul`/`ol` markdown is for); navigation menus.
**Spec:** a wrapper `ol.step-rows` with auto-numbered square badges (22×22, 1px amber border, CSS counters — never hardcoded) at `left: 10px`; vertically centered on link rows, `top: 10px` on instruction rows, and sitting on the summary of expandable rows. Three row kinds:
- `step-link` (has `href`): whole row is a block `<a>` (`target="_blank"` — walkthroughs keep the page open) — 1px amber border, 5% tint background, `padding: 6px 10px 6px 44px`, hover = 10% amber wash, focus-visible = 1px amber outline offset 2.
- `step-text` (no `href`): same bordered/tinted box, inherited amber text, not clickable.
- `step-expand`: `<details class="step-details">` — summary row (5% tint background, 10% amber hover wash, `padding: 6px 30px 6px 44px`) with the number badge on the summary and a `▸`/`▾` toggle character at the right edge (`::after`, swaps when `[open]`); content area separated by a 1px amber top border, `padding: 10px`, inherited text color.
All corners `--radius: 0`; colors only via `--accent`/`--foreground`/`--background` + `color-mix(…, transparent)`.
**Recipe:** shortcodes `themes/terminal/layouts/shortcodes/steps.html`, `step.html`, `step-details.html`; styles in the "Step rows" block appended at the end of `themes/terminal/static/terminal.css`. Usage:
```md
{{< steps >}}
{{< step href="/path" >}}**Label:** description{{< /step >}}
{{< step-details title="Expandable step" >}}Detail content (markdown).{{< /step-details >}}
{{< step >}}Plain instruction text.{{< /step >}}
{{< /steps >}}
```
**Never:** hardcode step numbers, colors, radii, or page-specific selectors; use the shortcodes so numbering stays automatic.

### Step panel (`{{< step-panel >}}`)
**Use for:** an expandable step row (same badge/summary/`▸▾` idiom as `step-details`) whose content is an auto-fill grid of link-buttons — e.g. a "pick a source" checklist. Site-only pattern, sibling of Step rows.
**Spec:** `<details class="step-panel">` with numbered badge + `▸/▾` on the summary; body is `repeat(auto-fill, minmax(160px, 1fr))` grid of 1px-bordered amber link buttons (`target="_blank"`, single column ≤ 684px). With `progress="true"`, each link gets an empty check-box that fills solid once opened (tracked per-href in `localStorage`, key `step-panel-opened`); when every link in a panel is opened, its summary badge fills at 45% amber wash with a black step number. `{{< step-panel-reset >}}` emits the `[ Reset progress ]` button + the tracking script — once per page. Body may carry one leading description paragraph (styled tight, `margin: 0 0 8px`) above the link list.
**Recipe:** site shortcodes `layouts/shortcodes/step-panel.html` + `step-panel-reset.html`; styles in the "Step panel" block at the end of `themes/terminal/static/terminal.css`. Usage: `{{< step-panel progress="true" title="Open a source" >}}` + a markdown link list inside, then `{{< step-panel-reset >}}` after the panel(s). Add `row="true"` to use the panel as a numbered row inside `{{< steps >}}` — it emits the `li.step-expand` wrapper and the badge reads the step-rows counter instead of the panel's own.
**Never:** put arbitrary block content in the panel body (only the leading description paragraph + the `> ul` link list), or duplicate the tracking script on a page.

### Language switch (`{{< lang-switch >}}`)
**Use for:** switching a page between language variants (site-only pattern, sibling of Step rows/panel).
**Spec:** draggable 3-stop switch — NL, inert translate icon in the middle, EN — with a sliding solid-accent thumb (the `.logo` idiom: solid `--accent` block, bold text in `--background`). 2px `--accent` border, `--radius: 0`; drag has magnetic snapping to the two real stops, rubber-band past the ends, and honors `prefers-reduced-motion`. Hidden in print.
**Recipe:** shortcode `layouts/shortcodes/lang-switch.html`; styles in the "lang-switch" block appended at the end of `themes/terminal/static/terminal.css` (pinned last, duotone via `--accent`/`--background` only). Params: `left` (default `nl`), `right` (default `en`), `position` = `left`/`center`/`right` (right = top-right of the content flow via `margin-left: auto`), `current` = `left`/`right` (optional — auto-detected from the URL's trailing `/nl/` or `/en/` segment; only needed on a page that is itself neither variant, e.g. `current="right"` on an English parent page). Links resolve from the current URL: the trailing language segment is stripped, so both links always point at the sibling variants (`/game/nl/` ↔ `/game/en/`) from any of the pages. Variants live as `content/<page>/<lang>/index.md`; embed the switch on the parent and on every variant page. Self-contained inline `<script>` — one per page.
**Never:** duplicate the script, style it outside the pinned terminal.css block, or nest variant pages deeper than one `<lang>/` segment.

### Blockquote
**Spec:** amber `>` character in the left margin (via `::before`), 1px amber top and bottom borders, 25px padding, no background.
**Recipe:** markdown `>`; `terminal.css`.

### `<hr>`
**Spec:** solid 2px amber bar, full width, no borders.
**Recipe:** markdown `---`; `terminal.css`.

### Tables
**Spec:** full 2px amber grid (`--foreground`), 10px cell padding, headers uppercase/bold/letter-spaced 0.04em, left-aligned.
**Recipe:** markdown tables; `terminal.css`.

### Images
**Use for:** any raster image in content. The frame is mandatory.
**Spec:** **8px solid amber border + 8px black padding** — an image mounted in a terminal window; sharp corners; `max-width: 100%`. Alignment classes `.left` / `.center` / `.right`. `figcaption`: solid amber bar, black text, centered, pulled up `-8px` under the image.
**Recipe:** `{{< image src="..." alt="..." position="center" style="..." >}}` (`themes/terminal/layouts/shortcodes/image.html`) or plain markdown images; styles in `terminal.css` + `main.css`.
**Never:** remove the frame or apply a radius.

### Video / YouTube embeds
**Spec:** iframes matching `iframe[src*="youtube.com"]` get the same 8px amber border; Hugo's built-in video output gets a 60px `.play` overlay via `.__h_video`.
**Recipe:** built-in `{{< youtube ID >}}` / `{{< vimeo ID >}}` shortcodes; `main.css`.

### Forms
**Use for:** any future form; none exists in the repo today.
**Spec:** inputs/textarea: transparent background, 1px `--foreground` border, amber text, focus = amber border + 1px outline offset 2. Selects: native arrow replaced by a CSS-drawn split chevron (two 5px background gradients — approved functional exception). Checkboxes: square with inset 3px black ring, checked = solid amber fill; radios: 10px circles, same fill. Fieldsets: 2px `--foreground` border.
**Recipe:** styled globally in `terminal.css`; no partial needed.

### Footer
**Spec:** entire footer dimmed to **65% opacity**; centered copyright row; stacks vertically ≤ 900px. Reads "© 2026 Powered by Hugo :: Theme made by panr" (or site `copyright` param).
**Recipe:** markup `themes/terminal/layouts/partials/footer.html`; CSS `themes/terminal/assets/css/footer.css`; extended content (the currently-disabled badge strip) via site override `layouts/partials/extended_footer.html`.

### 88×31 badge strip
**Use for:** the friend/software web-ring under the footer.
**Status: enabled** — `layouts/partials/extended_footer.html` includes the strip on every page. It was previously disabled behind a template comment after a broken external badge caused page-load hangs; re-enabled on request. If page loads hang again, suspect an external `src` in `data/buttons88x31.toml` first.
**Spec (when enabled):** centered flex-wrap row of 20 badges (11 local, 9 external; the 2 entries with empty `link` render as bare images), 5px gaps, 10px vertical margins, inside a block separated by a **1px `#ccc` top border** (the only non-palette color; see §2). All render at 88×31.
**Recipe:** entries in `data/buttons88x31.toml` (`filename` → `static/88x31/`, or `src` for external URLs; `alt`; `link`); markup `layouts/partials/buttons88x31.html` + `layouts/shortcodes/buttons88x31.html` (also usable as `{{< buttons88x31 >}}` in content). Adding a badge touches the TOML and (for local ones) `static/88x31/`. `static/88x31/cc-by-nc-sa.png` is an unreferenced orphan — don't build on it. External badge URLs need approval (one broken URL is what disabled the strip).
**Never:** add borders, radii, or resize badges.

### 404 page
**Spec:** post-styled block: "404 — Page not found…" title + "Back to home page →" link.
**Recipe:** `themes/terminal/layouts/404.html`; served for unknown paths by the Worker's SPA fallback (`wrangler.toml`).

## 5. Layout principles

- `FullWidthTheme = true` in `hugo.toml` → `.container.full`: full width, no border, 40px padding (20px ≤ 684px), min-height 100vh, flex column. The theme's default 864px container with a right hairline border is unused.
- Vertical rhythm: `h1–h6, p, ul, ol, img, figure, video, table` all get 25px vertical margins — don't add ad-hoc spacing.
- Lists indent 4ch; list markers are amber; inside `.post`, bullets become literal amber `-` dashes positioned in the left margin.
- The page is one black column; there are no cards, panels, or sidebars. Hierarchy is achieved with dimming and borders only.

## 6. Depth and elevation

**None.** The design is flat: hierarchy comes from opacity and 1–4px borders, never shadows or gradients. Two sanctioned exceptions:
1. `.menu__dropdown`'s box-shadow is black-on-black decorative legacy (invisible; keep or drop, don't reuse).
2. The select chevron gradients (functional) and the logo cable line (decorative dash pattern) use `linear-gradient`/`repeating-linear-gradient` as approved uses.
**Never** add `box-shadow` or a color gradient for depth.

## 7. Do's and don'ts

| Do | Don't |
|---|---|
| Use `color-mix()` with `--accent`/`--foreground` for any dimming | Introduce a gray, a second hue, or raw hex (except the sanctioned `#ccc` badge border) |
| Keep `--radius: 0` (kbd's 4px and radio's 20px circle are the only exceptions) | Round anything else |
| Stay in Fira Code | Add a second typeface |
| Reuse an existing element/shortcode first | Invent a new token, component, or shortcode without asking |
| Put style edits in `terminal.css` or the matching component CSS file | Create a new cascade layer or a competing base stylesheet |
| Check desktop + ≤684px after UI changes | Ship CSS without running `hugo --gc --minify` |

## 8. Responsive behavior

- **≤ 684px:** base font → 0.95rem; container padding → 20px; desktop nav hides, mobile "Menu ▾" trigger appears; dropdowns right-align; post covers get `padding: 10px; border-width: 10px`.
- **≤ 900px:** footer stacks vertically.
- Print: header and pagination hidden.

## 9. Agent prompt guide

When asked to build or change UI:
1. Identify the element above; reuse its spec verbatim unless the user asks otherwise.
2. Edit the recipe's files (theme is vendored — edit `themes/terminal/` directly). Override priority: `themes/terminal/static/terminal.css` wins over `assets/css/*.css` (loaded last in `head.html`).
3. Only token values and `color-mix` roles from §2; no new colors.
4. Build: `hugo --gc --minify`. Confirm it exits clean.
5. Inspect the page at desktop and ≤ 684px (`hugo server` + browser). If it renders, you're done — there are no automated tests.
6. If a new pattern was approved, add/update its spec+recipe section here in the same change.
