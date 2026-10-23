# oneCommerce Help: house rules

This repo is the public help site at docs.onecommerce.tech, built with Mintlify. Every push to `main` goes live in about a minute.

## Who it is for

Only people who use the oneCommerce inbox: our clients, their admins and their team members. Never developers.

## Never write here (the owner's standing rule)

- How the product works inside: code, file or folder names, technology or library names, databases, how WhatsApp linking works under the hood.
- Anything about servers, hosting, backups, commands, ports, addresses other than onecommerce.tech / app.onecommerce.tech, keys or secrets.
- Our costs, suppliers, AI models, other clients' names, or internal plans and roadmap.
- An API reference, developer guide, or "build on top of oneCommerce" page.

`scripts/check-secrets.sh` is a hard firewall: it blocks banned words, code, keys, links to other sites, API settings and any file type outside its allowlist. It runs before every commit and push (`git config core.hooksPath scripts/hooks`) and on GitHub. Never skip it (`--no-verify`) and never weaken it. If it flags something, rewrite it for clients; if something new must stay out, add it to the list.

Screenshots: only from fake test data. No real customer, phone number or client, ever.

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
