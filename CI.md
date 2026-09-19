# Development CI and Renovate

`ci` runs for every PR, default-branch push and manual dispatch. GitHub branch
protection must require the exact `ci / required` aggregate and the separate
`policy / ci / policy` check from GitHub Actions, with branches up to date and no
merge bypass. The aggregate directly requires guard, quality and smoke. Policy
checks Conventional Commit titles, author-matching DCO sign-offs, holds and reviews;
label and review events refresh it independently of application CI.

Renovate is the sole ongoing dependency merge owner. Automerge remains explicitly
disabled during the v3 canary, until enforcement and a real native Renovate merge
are proven. The retired Actions merger and `/merge` commands are no longer used.
PR and final-CI dispatches still verify the requested current revision at both gates.

Locally run `bun install --frozen-lockfile`, `bash .github/scripts/check.sh`, then
`bash .github/scripts/smoke.sh`. CI uses the committed Bun version, read-only
Biome, complementary prek hygiene, Astro and Svelte checks, eight Bun fixtures,
one production build and the existing four HTTP route probes. The ordinary CI
smoke job and Pages reuse that build artifact. Standalone smoke dispatch builds its own artifact
locally instead of downloading a missing same-run artifact. Shared smoke support
owns startup, readiness, assertion deadlines and process cleanup in CI; the same
four caller-owned route assertions remain mandatory. Five Python deployment
fixtures reject absent, stale, failed and wrong-provenance CI. CI rejects
tracked-file mutations. The Zod URL deprecation is an existing hint. Browser hydration/search interactions and live
third-party platform availability remain manual coverage gaps.

Fixtures cover school grade boundaries, parity between subject data/schema/style
metadata/issue choices, real issue headings, checked grades, multiline text, unsafe
URL protocols, missing fields and safe generated paths. The issue form now offers
only supported subject slugs. Platform requests remain restricted to `edbfi`.
The writer treats issue text as data, rejects duplicate names/URLs and existing
paths, formats only the generated JSON and proposes a signed-off PR per issue.
It explicitly dispatches application CI for the exact PR SHA with `GITHUB_TOKEN`;
failures report manual recovery inputs. That token can suppress PR events, so its
generated head remains blocked until a supported App/user update also starts the
required PR policy check. Dispatching application CI does not bypass policy.
Enable **Allow GitHub Actions to create and approve pull requests**. No live issue, comment, PR or catalog addition is created in local
tests. GitHub Pages publishes only a successful default-branch CI artifact, with
the `portaler.edb.fi` domain. Successful default-branch CI starts the publisher
through `workflow_run`. The publisher verifies the event repository, branch, workflow, newest run and attempt
for the exact current main commit, then downloads that run's validated artifact.
Both automatic and manual publication recheck the current default revision and
same successful CI attempt immediately before publish. PR CI cannot trigger a
production deployment.

The versioned `edbfi/automation` preset centralizes dependency managers and
update grouping. TypeScript updates exercise both Astro and Svelte checks without
a separate version cap. All actions use full version tags. The official Biome
version manager handles schema versions, and the isolated repair workflow performs
migrations/safe formatting before dispatching full CI on the repair commit.
Repair is restricted to Portaler's actual source, scripts, tests and root framework
configuration files; unrelated extension paths are excluded.

Repair recovery has an explicit disabled policy in `.github/repair-policy.json`,
preserving the previous absence of an opt-in. The existing Biome App repair
workflow remains installed; its publication must produce both required CI and
policy checks. Shared workflows, actions and Renovate policy are pinned to v3.0.0.
