# Development CI and Renovate

`ci` runs for every PR, default-branch push and manual dispatch. GitHub branch
protection must require the exact `ci / required` aggregate and the separate
`policy / ci / policy` check from GitHub Actions, with branches up to date and no
merge bypass. The aggregate directly requires quality and smoke. Policy
checks Conventional Commit titles, author-matching DCO sign-offs, holds and reviews;
label and review events refresh it independently of application CI.

Renovate is the sole ongoing dependency merge owner. After release ages, it arms
GitHub auto-merge with the rebase strategy through the shared `automerge.json`
preset; merging still requires complete current-head CI and policy checks,
up-to-date branches, review requirements and hold labels. The TypeScript 7 hold remains
in place; shared automation configuration updates remain manual. The retired
Actions merger and `/merge` commands are no longer used. After a pass, policy
re-runs the other event's older failed verdict for the same head (`actions: write`),
so a withdrawn objection clears without a manual re-run.

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

Fixtures cover school grade boundaries and parity between subject data, schema
and style metadata. GitHub Pages publishes only a successful default-branch CI artifact, with
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
migrations/safe formatting. Its App-authored push starts the normal `pull_request`
CI and policy runs on the repair commit; nothing is dispatched.
Repair is restricted to Portaler's actual source, scripts, tests and root framework
configuration files; unrelated extension paths are excluded.

The existing Biome App repair workflow remains installed; its publication must
produce both required CI and policy checks. Shared workflows, actions and Renovate
policy are pinned to v4.0.0.

## TypeScript compiler compatibility

`typescript` retains the 6.x JavaScript compiler API for framework tooling.
`@typescript/native` aliases the stable TypeScript 7 package for the documented
`svelte-check --tsgo` path. The required `check` command runs both the existing
checker and native mode; neither may fail or be skipped. Keep the direct TS7
replacement PR on hold: replacing `typescript` removes the API used by the
existing tooling. Native checker updates are independently locked and frozen.

Upstream setup: https://github.com/sveltejs/language-tools/tree/master/packages/svelte-check#typescript-7-supports
