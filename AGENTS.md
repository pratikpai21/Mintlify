# oneCommerce Help: house rules

This repo is the public help site at docs.onecommerce.tech, built with Mintlify. Every push to `main` goes live in about a minute.

## Who it is for

Only people who use the oneCommerce inbox: our clients, their admins and their team members. Never developers.

## Never write here (the owner's standing rule)

- How the product works inside: code, file or folder names, technology or library names, databases, how WhatsApp linking works under the hood.
- Anything about servers, hosting, backups, commands, ports, addresses other than onecommerce.tech / app.onecommerce.tech, keys or secrets.
- Our costs, suppliers, AI models, other clients' names, or internal plans and roadmap.
- An API reference, developer guide, or "build on top of oneCommerce" page.

`scripts/check-secrets.sh` blocks the most common of these. It runs on every push (GitHub Actions) and should be run before every commit. If it flags a word, rewrite the sentence; don't weaken the check.

## How to write

- Plain, friendly English for shop owners and their staff. Short steps. Say what to click and what happens.
- Only describe features that exist in the inbox today. The product's own in-app guide is the reference for wording.
- Use the same button names as the inbox (✨ Summarise, I'm done, Close, ↩️ Return …).
- Generic examples only ("Main shop", "Asha from the team"); never a real client.
- Support: support@onecommerce.tech or WhatsApp +91 98203 69727.

## Files

- `docs.json`: site settings and the left menu. A new page must be added there.
- Pages are `.mdx` files with a `title` and `description` at the top.
- Brand: Deep Green #00463C, Vivid Green #40DC3A, font Inter.
- Preview on a Mac: `npx mint dev`, then open http://localhost:3000.
