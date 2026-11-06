// "I removed the key and redeployed." Is the exposure over?
//
// A provider that behaves like a real one: it accepts a key until that key is
// rotated, and has no idea whether your repository still mentions it.
import { createServer } from 'node:http';

const LEAKED = 'sk-lab-2222-committed-by-mistake';
let valid = new Set([LEAKED]);

const provider = createServer((req, res) => {
  const key = (req.headers.authorization ?? '').replace('Bearer ', '');
  const ok = valid.has(key);
  res.writeHead(ok ? 200 : 401, { 'content-type': 'application/json' });
  res.end(JSON.stringify(ok ? { answer: 'hello' } : { error: 'invalid key' }));
});
await new Promise((r) => provider.listen(0, '127.0.0.1', r));
const base = `http://127.0.0.1:${provider.address().port}`;

const tryKey = async (k) => (await fetch(base, { headers: { Authorization: `Bearer ${k}` } })).status;
const line = (q, a) => console.log(`    ${q.padEnd(50)}${a}`);
const leaked = (s) => (s === 200 ? 'accepted — still spending your money' : `refused (${s})`);
const plain  = (s) => (s === 200 ? 'accepted' : `refused (${s})`);

console.log('');
line('the leaked key, before you notice:', leaked(await tryKey(LEAKED)));
line('you delete it from the code and redeploy:', 'the bundle no longer contains it');
line('the leaked key, after that deploy:', leaked(await tryKey(LEAKED)));

valid = new Set(['sk-lab-3333-the-new-one']);
line('you rotate the key at the provider:', 'the old one is revoked, a new one issued');
line('the leaked key, after rotation:', leaked(await tryKey(LEAKED)));
line('the new key, which was never published:', plain(await tryKey('sk-lab-3333-the-new-one')));
console.log('');
provider.close();
