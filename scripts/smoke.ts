// Smoke test of the production build: serve dist/ the way GitHub Pages does
// (scripts/serve-dist.ts) and request the main routes. Run after `bun run build`.
const port = 4321;
const routes = ["/", "/other", "/grade/3", "/fag/matematik"];
const base = `http://127.0.0.1:${port}`;
const timeout = () => AbortSignal.timeout(5_000);

const server = Bun.spawn(["bun", "run", "scripts/serve-dist.ts"], {
  env: { ...process.env, PORT: String(port) },
  stdout: "inherit",
  stderr: "inherit",
});
let exited = false;
void server.exited.then(() => {
  exited = true;
});

async function waitForServer(): Promise<void> {
  const deadline = Date.now() + 10_000;
  while (Date.now() < deadline) {
    if (exited) throw new Error(`server exited with code ${server.exitCode}`);
    try {
      await fetch(base, { signal: timeout() });
      return;
    } catch {
      await Bun.sleep(100);
    }
  }
  throw new Error(`server did not start on ${base}`);
}

const failures: string[] = [];
try {
  await waitForServer();
  for (const route of routes) {
    const response = await fetch(`${base}${route}`, { signal: timeout() });
    const html = await response.text();
    const title = html.match(/<title>([^<]*)<\/title>/)?.[1]?.trim();
    if (response.status !== 200 || !title) {
      failures.push(`${route}: status ${response.status}, title ${JSON.stringify(title)}`);
    } else {
      console.log(`ok ${route}: ${title}`);
    }
  }
} catch (error) {
  failures.push(String(error));
} finally {
  server.kill();
  await server.exited;
}

if (failures.length > 0) {
  console.error(failures.join("\n"));
  process.exit(1);
}

export {};
