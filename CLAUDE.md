# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Static Astro 7 site (GitHub Pages, `portaler.edb.fi`) listing school learning platforms by grade and subject. Bun is the toolchain; interactive islands are Svelte 5 (runes). README's "Astro 6" and "SolidJS / `PlatformExplorer.tsx`" lines are stale: all islands are `.svelte`.

## Commands

| Task | Command |
| --- | --- |
| Full local CI gate | `bash .github/scripts/check.sh` (biome ci, check, bun tests, Python tests, build) |
| Route smoke test (after build) | `bash .github/scripts/smoke.sh` |
| Lint (read-only) / autofix | `bun run lint` / `bun run lint:fix` |
| Typecheck | `bun run check` (astro check + svelte-check twice: TS 6 API and `--tsgo`) |
| Bun tests | `bun run test` |
| Single test file / case | `bun test tests/catalog.test.ts` / `bun test tests/catalog.test.ts -t "school phases"` |
| Python deployment tests | `python3 -B -m unittest discover -s tests -p 'test_*.py'` (one case: add `-k test_current_successful`) |
| Serve built `dist/` | `bun run scripts/serve-dist.ts` (mirrors Pages extensionless routes; `astro preview` daemonizes in Astro 7) |

Run tests from the repo root: `tests/catalog.test.ts` globs `src/content/...` relative to cwd.

## Architecture boundaries

- Data lives in content collections (`src/content.config.ts`, Zod schemas) under `src/content/platforms/<publisher>/*.json` and `src/content/subjects/*.json`. Platforms with `grades: []` render only on `/other`.
- `src/lib/platforms.ts` is the only place that reads `astro:content` for platforms. It flattens entries into the serializable `PlatformItem` that pages pass to Svelte islands. Islands must not import `astro:content`: import only `type PlatformItem` from `lib/platforms`, and add any new fields to `PlatformItem`/`enrich()`.
- Subject colour and icon come from `SUBJECT_META` in `src/lib/subjects.ts`, not from JSON. The `icon`, `color` and `iconOverwrite` keys in subject and platform JSON are legacy: the schema drops them and nothing renders them.
- Grades are fixed at 0–9 in three phases (`src/lib/grades.ts`); `/grade/[id]` paths come from `GRADES`.
- Publisher logos match on the exact `publisher` string in `PUBLISHER_LOGOS` (`src/lib/publishers.ts`). Publishers without a logo get a text chip.

## Workflows

### Add or rename a subject (all three must match; `tests/catalog.test.ts` enforces it)

1. `src/content/subjects/<slug>.json` (`name` = slug, `displayName`, `order`).
2. The `subjectSlugs` array in `src/content.config.ts`. The test parses it with a regex, so keep it a literal `const subjectSlugs = [...] as const`.
3. `SUBJECT_META` in `src/lib/subjects.ts` (OKLCH `accent`, `i-lucide-*` icon).

### Add a platform

Add `src/content/platforms/<publisher-slug>/<name-slug>.json` using the shape in README "Adding a platform".

## Gotchas

- UnoCSS only generates classes it sees as literal strings. For per-value classes, use a literal lookup map like `phaseText` in `src/pages/grade/[id].astro`, not interpolation like `text-${id}`. A `.ts` file that holds class strings needs `// @unocss-include` at the top (see `src/lib/subjects.ts`).
- For per-subject colour, set an inline `--sa` CSS var and use `text-[var(--sa)]`-style utilities (see `PlatformCard.svelte`). Semantic colour tokens are CSS vars in `src/styles/global.css` and are mapped in `uno.config.ts`.
- Write internal links without a trailing slash (`/grade/3`, `/fag/dansk`). They depend on `build.format: "file"` in `astro.config.mjs`, and changing either one breaks live URLs.
- Theme is a `.dark` class on `<html>`, set before paint by the inline script in `src/layouts/Layout.astro`, with `localStorage.theme` as the key. Style dark mode with `dark:` variants; change theme init in that inline script, not in an island.
- Keep both `typescript` (6.x) and `@typescript/native` (7.x). The TS 7 swap is on hold because the tooling needs the TS 6 API (see `CI.md`).
- CI runs `biome ci` (read-only) and then fails on any tracked-file diff. Run `bun run lint:fix` before pushing.
- Direct npm versions in `package.json` are pinned exactly (Renovate `rangeStrategy: pin`). Add dependencies with `bun add --exact`, not `^` ranges.
- Commits must use Conventional Commit titles and carry a `Signed-off-by` that matches the author (`git commit -s`). The PR policy check requires both. `prek.toml` also blocks commits to `main` and runs `bun run check` on pre-push.

## Reference

- `CI.md`: CI and deploy gates, Renovate ownership, TS 6/7 checker setup. Read before editing `.github/workflows/`, `.github/scripts/`, `renovate.json` or TypeScript deps.
- `.agents/rules/astro-svelte5-islands.md`: generic Astro 7 / Svelte 5 / UnoCSS / Biome reference (34 KB). Read before writing new components. Where it conflicts with this repo's config, the repo wins: this repo has no Vitest, no shadcn-svelte, no `--bun` scripts and no `bunfig.toml`.
