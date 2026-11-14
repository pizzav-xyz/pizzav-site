# PRODUCT.md

## What this is

Personal homepage of PizzaV — a selfhosting-oriented personal site listing the services I run (copyparty, forgejo, privatebin, mailcow, continuuwuity) plus a web-ring of 88×31 friend badges (strip currently disabled — see `DESIGN.md` §"88×31 badge strip"). Not a business site: no SEO targets, no analytics configured.

Two external-request facts an agent must not silently change:
- The theme's `head.html` includes Hugo's `google_analytics` template — it stays inert only because no `googleAnalytics` config exists. Adding analytics requires explicit approval.
- Fira Code loads from a third-party CDN (`cdn.staticdelivr.com`) — the site's only external font/asset request.

## Audience

Friends, other selfhosters, and web-ring visitors arriving from badge links. They know what a terminal is; don't explain things or add onboarding copy.

## Voice / personality

- Casual, first-person, lowercase-nerd. Jokes belong in microcopy — see the badge alt texts in `data/buttons88x31.toml` ("i actually use cachyos", "ermm thats the thunderbird logo not betterbird") for the calibration.
- No corporate copy, no marketing language, no emoji in UI chrome.

## Anti-references

The site must **not** drift toward:

- Polished SaaS/landing-page aesthetics: no gradients, no shadows, no rounded corners, no cards or hero sections.
- A dark-mode toggle — it is permanently a black CRT terminal (see `DESIGN.md` §1).
- Generic AI-ish footer/headline copy ("Welcome to my corner of the internet"). Match the terse, factual tone of the existing home page.
