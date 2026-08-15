# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Shaswat Patel's personal academic site — a fork of the [al-folio](https://github.com/alshedivat/al-folio) Jekyll theme, published at https://shaswatpatel.github.io via GitHub Pages.

Because it's a theme fork, **most files in the repo are still upstream demo content** (`_posts/*`, `_projects/*`, `_pages/about_einstein.md`, most of `assets/img`, `assets/json/resume.json`, `_data/cv.yml`). A file existing does not mean it is part of the live site — check `_config.yml` toggles and page front matter before assuming something is rendered.

## Commands

```bash
bundle install                  # Ruby deps (first time)
bundle exec jekyll serve        # dev server at http://localhost:4000, live reload
bundle exec jekyll build        # one-off build into _site/ (same as bin/cibuild)

docker compose up               # alternative dev setup, serves on :8080
docker compose -f docker-compose-slim.yml up

npx prettier --write .          # formatter (prettier 3.1.1 + @shopify/prettier-plugin-liquid)

pip install -r requirements.txt
python bin/update_scholar_citations.py   # refreshes _data/citations.yml from Google Scholar
```

There is no test suite. `node_modules/` is committed, so `npx prettier` works without `npm install`. Changes to `_config.yml` require restarting `jekyll serve`.

## Deployment

Pushing to `main` triggers `.github/workflows/deploy.yml`, which runs `bundle exec jekyll build` with `JEKYLL_ENV=production` and publishes the artifact to GitHub Pages. `bin/deploy` (the upstream gh-pages-branch script) is **not** used here — don't run it.

`JEKYLL_ENV=production` is what enables minification (`jekyll-minifier`, `jekyll-terser` with `drop_console`), so production output differs from local dev output.

## Where content lives

Editing this site is almost always a content/config change, not a code change.

| Want to change | Edit |
| --- | --- |
| Homepage text, profile photo, homepage section toggles | `_pages/about.md` front matter + body |
| Which pages appear in the navbar | `nav: true` / `nav_order` in `_pages/*.md` |
| Publications | `_bibliography/papers.bib` |
| News / announcements | `_news/*.md` |
| Social links, CV PDF path, `scholar_userid` | `_data/socials.yml` |
| Site-wide features, theme, plugin config | `_config.yml` |

Currently in the navbar: publications (2), cv (4), teaching (6). `projects`, `blog`, `repositories`, `books`, `profiles` are all `nav: false`.

### Homepage (`_pages/about.md`)

Uses `layout: about`. Its front matter drives which homepage sections render: `selected_papers`, `social`, `announcements.enabled` (currently `false`), `latest_posts.enabled` (currently `false`), and the `profile:` block (image, `more_info` HTML).

### Publications

Rendered by `jekyll-scholar` from `_bibliography/papers.bib` through `_layouts/bib.liquid`. Non-standard BibTeX fields carry site behavior:

- `selected={true}` — surfaces the entry in the homepage's selected papers list
- `abbr={...}` — the venue badge shown next to the entry
- `bibtex_show={true}` — shows the "Bib" expander
- `pdf`, `code`, `html`, `poster`, `slides`, `preview`, `award`, ... — render as link buttons / thumbnails

These custom keys are stripped from the displayed BibTeX by `filtered_bibtex_keywords` in `_config.yml`; a new custom field must be added there or it will leak into the shown citation. Grouping is by year, descending.

### CV page — important

`_pages/cv.md` uses `layout: none` and is a hand-written meta-refresh + JS redirect straight to `/assets/pdf/Shaswat_Patel_Resume.pdf`. This deliberately bypasses al-folio's CV rendering machinery — `_data/cv.yml`, `assets/json/resume.json`, `_layouts/cv.liquid`, `_includes/cv/*`, `_includes/resume/*` are all dead code for this site. To update the CV, replace the PDF; editing `cv.yml` does nothing.

### News

`_news/*.md` is a collection defaulting to `layout: post`. `inline: true` means the item renders inline in the news list instead of getting its own page. Homepage display is gated by `announcements.enabled` in `_pages/about.md`.

### Projects

`_projects/*.md` grouped by `category` and sorted by `importance` on `/projects/`. Still upstream demo content and hidden from the navbar.

## Build-time behavior worth knowing

- **Network calls during build.** `_plugins/google-scholar-citations.rb` and `inspirehep-citations.rb` scrape citation counts, `_plugins/external-posts.rb` pulls the RSS feeds in `external_sources`, and `jekyll-get-json` fetches remote JSON. Builds are slow and can fail or degrade without network.
- **ImageMagick required.** `imagemagick.enabled: true` generates responsive `.webp` variants of `assets/img/` at 480/800/1400px on every build. `convert` must be on PATH.
- **Third-party libs come from CDN.** `third_party_libraries` in `_config.yml` pins versions + SRI hashes. Bumping a version requires updating the matching `integrity` hash or the asset silently fails to load. Setting `download: true` makes `_plugins/download-3rd-party.rb` vendor them locally instead.
- **Cache busting.** `_plugins/cache-bust.rb` appends an MD5 query string to asset URLs; don't hand-write versioned asset filenames.
- **Styles.** `assets/css/main.scss` is the single Sass entrypoint importing `_sass/*`; it needs its empty front matter dashes to be processed at all. Theme colors and light/dark variables live in `_sass/_variables.scss` and `_sass/_themes.scss`.

## Conventions

- Templates are Liquid (`.liquid` in `_includes/` and `_layouts/`) — prettier's Shopify Liquid plugin handles them, so run the formatter after editing.
- Adding a new social platform touches four files (see `CONTRIBUTING.md`): `_data/socials.yml`, `_includes/metadata.liquid`, `_includes/social.liquid`, `_scripts/search.liquid.js`. Entries in these are kept alphabetically sorted.
- `_site/` is gitignored; everything else, including `node_modules/`, is tracked.
