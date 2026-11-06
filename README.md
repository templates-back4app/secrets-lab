# secrets-lab

[![Deploy on Back4app](https://img.shields.io/badge/Deploy%20on-Back4app-1568B8?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTEyIDJMMiA3djEwbDEwIDUgMTAtNVY3eiIvPjwvc3ZnPg==)](https://www.back4app.com/signup?utm_source=github&utm_medium=repo&utm_campaign=secrets-lab)

Where a secret ends up when a build tool is involved, and what removing it
afterwards actually removes. Three measurements: a real vite production build, a
throwaway git repository, and a provider that behaves like a real one.

**Measured with vite 7.1.5 in node:22-alpine, git, and Docker 29.4.3,
29 October 2026. Identical across two consecutive clean runs.**

> **Read the article:** [The API Key in Your Frontend Is Already Public: What Removing It Does and Does Not Fix](https://www.back4app.com/blog/api-key-in-frontend-code?utm_source=github&utm_medium=repo&utm_campaign=secrets-lab)

## Run it

```
./run.sh
```

Needs Docker and Node 22. Nothing touches your repositories: the git phase builds
and destroys its own.

## What it found

### The name that works is the name that leaks

```
which of those files contain each secret:
  VITE_PROVIDER_KEY           assets/index-BRB5O7a8.js
  PROVIDER_KEY (no prefix)    not in any shipped file

and what the app does with each one:
  VITE_PROVIDER_KEY           the request carries the key — the feature works
  PROVIDER_KEY (no prefix)    undefined in the browser — the feature does not work
```

Both keys sit in the same `.env`. The prefix is not a safety label, it is the
instruction to copy the value into the bundle — which is why adding it is what
made the feature start working.

### Deleting the commit removes nothing

```
the key is in the files as they stand now:        no
the key is in the repository's history:           yes
retrievable by object id, after the deletion:     yes — git cat-file -p 743dad90c62b
```

### Redeploying does not end the exposure

```
the leaked key, before you notice:                accepted — still spending your money
you delete it from the code and redeploy:         the bundle no longer contains it
the leaked key, after that deploy:                accepted — still spending your money
you rotate the key at the provider:               the old one is revoked, a new one issued
the leaked key, after rotation:                   refused (401)
```

**Rotation is the only step that changed anything outside our own copy.**

## The pieces

| file | what it does |
| --- | --- |
| `app/` | a small vite app that calls a provider from the browser |
| `app/.env.example` | the two secrets, copied into place by `frontend.sh` — a repository about not committing secrets does not commit a `.env` |
| `frontend.sh` | builds it for production and searches the shipped files |
| `history.sh` | commits a key, removes it, and asks whether it is gone |
| `rotate.mjs` | a provider that accepts a key until it is rotated |

`history.sh` counts matches rather than using `grep -q`: under `pipefail`, `-q`
exits on the first hit, kills `git log` with SIGPIPE and turns a hit into a
reported miss.
