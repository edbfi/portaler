<script lang="ts">
import type { PlatformItem } from "../lib/platforms";
import PlatformCard from "./PlatformCard.svelte";

interface Props {
  platforms: PlatformItem[];
  currentGrade?: number;
  /** Heading id to associate the search region with, for screen readers. */
  searchLabel?: string;
}

let { platforms, currentGrade = undefined, searchLabel = "Søg efter platform" }: Props = $props();

let query = $state("");
let publisher = $state("");

const publishers = $derived(
  [...new Set(platforms.map((p) => p.publisher).filter(Boolean))].sort((a, b) =>
    a.localeCompare(b, "da"),
  ),
);

const filtered = $derived.by(() => {
  const q = query.trim().toLowerCase();
  const pub = publisher;
  return platforms.filter((p) => {
    if (pub && p.publisher !== pub) return false;
    if (!q) return true;
    return (
      p.name.toLowerCase().includes(q) ||
      p.publisher.toLowerCase().includes(q) ||
      p.subjectLabel.toLowerCase().includes(q) ||
      p.description.toLowerCase().includes(q)
    );
  });
});

interface SubjectGroup {
  slug: string;
  label: string;
  accent: string;
  icon: string;
  order: number;
  items: PlatformItem[];
}

const groups = $derived.by((): SubjectGroup[] => {
  const map = new Map<string, SubjectGroup>();
  for (const p of filtered) {
    let group = map.get(p.subject);
    if (!group) {
      group = {
        slug: p.subject,
        label: p.subjectLabel,
        accent: p.accent,
        icon: p.icon,
        order: p.subjectOrder,
        items: [],
      };
      map.set(p.subject, group);
    }
    group.items.push(p);
  }
  const arr = [...map.values()].sort(
    (a, b) => a.order - b.order || a.label.localeCompare(b.label, "da"),
  );
  for (const g of arr) {
    g.items.sort((a, b) => a.name.localeCompare(b.name, "da"));
  }
  return arr;
});

function reset() {
  query = "";
  publisher = "";
}
</script>

<div>
  <div class="ui-card mb-8 flex flex-col gap-3 p-4 sm:flex-row sm:items-end">
    <div class="flex-1">
      <label for="platform-search" class="mb-1.5 block text-sm font-medium text-foreground">
        {searchLabel}
      </label>
      <div class="relative">
        <span
          class="i-lucide-search pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground"
          aria-hidden="true"
        ></span>
        <input
          id="platform-search"
          type="search"
          bind:value={query}
          placeholder="Navn, fag eller forlag…"
          class="ui-focus w-full rounded-xl border border-border bg-background py-2.5 pl-10 pr-3 text-sm text-foreground placeholder:text-muted-foreground"
        >
      </div>
    </div>

    {#if publishers.length > 1}
      <div class="sm:w-56">
        <label for="publisher-filter" class="mb-1.5 block text-sm font-medium text-foreground">
          Forlag
        </label>
        <select
          id="publisher-filter"
          bind:value={publisher}
          class="ui-focus w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm text-foreground"
        >
          <option value="">Alle forlag</option>
          {#each publishers as name (name)}
            <option value={name}>{name}</option>
          {/each}
        </select>
      </div>
    {/if}
  </div>

  <p class="mb-5 text-sm text-muted-foreground" aria-live="polite">
    Viser {filtered.length} af {platforms.length}
    {platforms.length === 1 ? "platform" : "platforme"}
  </p>

  {#if groups.length > 0}
    <div class="flex flex-col gap-10">
      {#each groups as group (group.slug)}
        <section aria-label={group.label}>
          {#if groups.length > 1}
            <div class="mb-4 flex items-center gap-2.5" style={`--sa: ${group.accent}`}>
              <span
                class="flex h-8 w-8 items-center justify-center rounded-lg bg-[var(--sa)]/12 text-[var(--sa)]"
                aria-hidden="true"
              >
                <span class={`${group.icon} text-base`}></span>
              </span>
              <h2 class="font-display text-lg font-semibold text-foreground">
                {group.label}
              </h2>
              <span class="text-sm text-muted-foreground">({group.items.length})</span>
            </div>
          {/if}
          <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {#each group.items as item (item.id)}
              <PlatformCard {item} {currentGrade} />
            {/each}
          </div>
        </section>
      {/each}
    </div>
  {:else}
    <div role="status" class="ui-card flex flex-col items-center gap-3 px-6 py-16 text-center">
      <span class="i-lucide-search-x text-3xl text-muted-foreground" aria-hidden="true"></span>
      <p class="text-foreground">Ingen platforme matcher din søgning.</p>
      <button
        type="button"
        onclick={reset}
        class="ui-focus rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:opacity-90"
      >
        Ryd søgning
      </button>
    </div>
  {/if}
</div>
