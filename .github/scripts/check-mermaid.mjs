// Parses every ```mermaid block in the given markdown files; exits 1 on any syntax error.
// Usage: node check-mermaid.mjs README.md docs/architecture.md
import { readFileSync } from 'node:fs';
import { JSDOM } from 'jsdom';

const { window } = new JSDOM('<body></body>');
globalThis.window = window;
globalThis.document = window.document;
const mermaid = (await import('mermaid')).default;

let failed = false;
for (const file of process.argv.slice(2)) {
  const blocks = [...readFileSync(file, 'utf8').matchAll(/```mermaid\n([\s\S]*?)```/g)];
  for (const [i, [, source]] of blocks.entries()) {
    try {
      await mermaid.parse(source);
    } catch (err) {
      failed = true;
      console.error(`${file} (block ${i + 1}): ${String(err.message).split('\n')[0]}`);
    }
  }
}
process.exit(failed ? 1 : 0);
