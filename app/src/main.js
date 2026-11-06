// The call an assistant writes when you ask it to "talk to the AI provider from
// the app". It needs the key at run time, in the browser, so the key has to
// travel to the browser.
const withPrefix = import.meta.env.VITE_PROVIDER_KEY;
const withoutPrefix = import.meta.env.PROVIDER_KEY;

async function ask(prompt) {
  const r = await fetch('https://api.example.invalid/v1/chat', {
    method: 'POST',
    headers: { Authorization: `Bearer ${withPrefix}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ prompt }),
  });
  return r.json();
}

const out = document.getElementById('out');
const btn = document.createElement('button');
btn.textContent = 'Ask';
btn.addEventListener('click', async () => {
  out.textContent = 'asking...';
  try { out.textContent = JSON.stringify(await ask('hello')); }
  catch (e) { out.textContent = `request failed: ${e.message}`; }
});
document.body.append(btn);

out.textContent = `provider key reached the browser: ${withPrefix ? 'yes' : 'no'}`
  + ` · unprefixed one: ${withoutPrefix ? 'yes' : 'no'}`;
