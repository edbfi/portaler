<p align="center">
  <img src="src/assets/str_logo_icon.svg" alt="portaler logo" width="160" height="160">
</p>

<h1 align="center">portaler</h1>

<p align="center"><strong>Digitale læremidler — skolens platforme, samlet ét sted</strong></p>

<p align="center">
  <a href="https://github.com/edbfi/portaler/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-AGPL--3.0--or--later-blue?style=flat" alt="License: AGPL-3.0-or-later"></a>
  <a href="https://github.com/oven-sh/bun"><img src="https://img.shields.io/badge/Bun-000000?style=flat&amp;logo=bun&amp;logoColor=white" alt="Bun"></a>
  <a href="https://github.com/withastro/astro"><img src="https://img.shields.io/badge/Astro-BC52EE?style=flat&amp;logo=astro&amp;logoColor=white" alt="Astro"></a>
  <a href="https://github.com/sveltejs/svelte"><img src="https://img.shields.io/badge/Svelte-FF3E00?style=flat&amp;logo=svelte&amp;logoColor=white" alt="Svelte"></a>
  <a href="https://github.com/microsoft/TypeScript"><img src="https://img.shields.io/badge/TypeScript-3178C6?style=flat&amp;logo=typescript&amp;logoColor=white" alt="TypeScript"></a>
  <a href="https://github.com/edbfi/portaler/actions/workflows/ci.yml?query=branch%3Amain"><img src="https://img.shields.io/github/actions/workflow/status/edbfi/portaler/ci.yml?branch=main&amp;event=push&amp;label=CI&amp;style=flat" alt="CI"></a>
</p>

En oversigt over skolens digitale læremidler, e-bøger og portaler, sorteret efter klassetrin og fag.

---

## 📖 Overview

Portaler is a fast, accessible static site that helps teachers find the right
digital learning platform for a given grade or subject. It is built for clarity
first — most users are not technical — with a light/dark theme and a layout that
works on phones, laptops, and desktops.

The home page is organised around the **school journey**: grades 0.–9. klasse,
grouped into the three Danish phases (Indskoling, Mellemtrin, Udskoling). You can
also browse by subject, or search and filter within any list.

## 🧰 Tech stack

- **[Astro](https://astro.build)** — static site, file-based routing, content layer.
- **[Bun](https://bun.sh)** — package manager and task runner.
- **[UnoCSS](https://unocss.dev)** with `presetWind4` — atomic styling + design tokens.
- **[Svelte 5](https://svelte.dev)** — the theme toggle island (runes).
- **[SolidJS](https://www.solidjs.com)** — the search/filter platform explorer island.
- **[Lucide](https://lucide.dev)** icons via UnoCSS `presetIcons`.
- Self-hosted variable fonts (Bricolage Grotesque + Inter) via Fontsource — no
  external font requests.

## 🚀 Project structure

```
src/
 ├── content.config.ts     # Content collections (glob loaders) + Zod schemas
 ├── content/
 │    ├── platforms/        # Platform data, grouped by publisher
 │    └── subjects/         # Subject data
 ├── lib/
 │    ├── grades.ts         # School phases + grade helpers (the "Skoleår" model)
 │    ├── subjects.ts       # Subject accent colour + Lucide icon (add subjects here)
 │    ├── platforms.ts      # Platform queries + enriched, serializable items
 │    └── publishers.ts     # Publisher logos
 ├── components/
 │    ├── ThemeToggle.svelte # Light/dark toggle (Svelte 5)
 │    ├── PlatformExplorer.tsx# Search + filter + grouped cards (SolidJS)
 │    ├── PlatformCard.tsx   # Platform card (SolidJS)
 │    ├── GradeRail.astro     # The Skoleår spectrum rail (signature)
 │    ├── SubjectTiles.astro  # Browse-by-subject tiles
 │    ├── Header.astro / Footer.astro
 ├── layouts/Layout.astro
 ├── pages/                 # /, /grade/[id], /fag/[subject], /other, 404
 └── styles/global.css       # Theme tokens (light/dark) + phase spectrum
uno.config.ts                # Presets, semantic tokens, shortcuts
```

## 📝 Adding a platform

Create a JSON file in `src/content/platforms/[publisher]/`:

```json
{
  "name": "Platformnavn",
  "publisher": "Gyldendal",
  "grades": [4, 5, 6],
  "url": "https://platform-url.dk",
  "subject": "dansk",
  "isActive": true,
  "description": "Kort beskrivelse vist på kortet.",
  "longDescription": "Længere beskrivelse vist når man klikker \"Mere info\"."
}
```

- `subject` must be one of the slugs in `src/content.config.ts`.
- `grades: []` (empty) places the platform under **Andre platforme** (`/other`).
- The file is validated against the Zod schema at build time.

## 🎨 Adding or restyling a subject

1. Add a JSON file in `src/content/subjects/` (`name`, `displayName`, `order`).
2. Add the matching slug to `subjectSlugs` in `src/content.config.ts`.
3. Add an accent colour + Lucide icon in `src/lib/subjects.ts`.

Subject identity (colour + icon) lives in code so a new subject is a one-line change.

## 💻 Development

```bash
bun install      # install dependencies
bun run dev      # start the dev server
bun run check    # type + diagnostics (astro check)
bun run build    # build the static site to dist/
bun run preview  # preview the production build
```

## ⚖️ License

Original code in Portaler is licensed under the GNU Affero General Public License,
version 3 or (at your option) any later version (`AGPL-3.0-or-later`) — see
[LICENSE](LICENSE). Third-party code, dependencies, and artwork retain their
respective licenses and notices.

<div align="center">
	<a href="https://www.gnu.org/licenses/agpl-3.0.en.html">
		<img src="src/assets/agplv3_icon.png" alt="GNU AGPLv3">
	</a>
</div>

## Biome configuration

`biome.json` uses the pinned Biome version, Git ignore rules, recommended lint and
import-organizing rules, and the repository's two-space, 100-column style. Run
`bun run lint` to check or `bun run lint:fix` to apply formatting and safe fixes.

Svelte and Astro formatting and markup checks use Biome's experimental HTML
support. Keep `bun run check` as the framework/type check.
