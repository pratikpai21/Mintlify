# oneCommerce Help

The help site for oneCommerce inbox users, live at **https://docs.onecommerce.tech**.

## Changing it

Any of these publish by themselves about a minute after saving to `main`:

- **Claude Code:** ask for the change in a session; it edits, checks and pushes.
- **Mintlify web editor:** dashboard.mintlify.com → Editor.
- **GitHub website:** open a page, edit, commit.

## Rules

Client help only. No code, servers, technology, costs or secrets: see `AGENTS.md`. The firewall `scripts/check-secrets.sh` runs before every commit and push, and on GitHub, and blocks anything that breaks these rules. After cloning, run `git config core.hooksPath scripts/hooks` once.

## Preview on a Mac

```
npx mint dev
```

Then open http://localhost:3000.
