# Kila Hildegarten – Website

Here I am building the website for our Kinderladen Kila Hildegarten.

The main **Production** website is: [https://kila-hildegarten.de](https://kila-hildegarten.de)

This repository contains the Ruby on Rails application for the **Kinderladen Kila Hildegarten** website.
It serves both the public website and an internal admin integration with [Webling](https://www.webling.eu/).

---

## Overview

The app provides a CMS-like interface. It allows admins to log in and update website content and photos stored on **Dropbox**.

For the Webling Kila management software, a secured page `/webling_photos` is used for managing photo previews synced from Webling. Only admins with the correct access token can access this page. It uses **Cloudinary** for image storage and **Redis** for caching photo previews.

The stack is intentionally lightweight and optimized for hosting on **Scalingo** with **Cloudflare** as CDN and SSL proxy.

---

## Technical Specifications

### Framework & Hosting

| | |
|---|---|
| **Framework** | Ruby on Rails 7.x |
| **Ruby version** | 2.7.x ⚠️ upgrade to 3.2.x recommended |
| **Database** | PostgreSQL (Scalingo managed) |
| **Cache** | Redis (Scalingo Redis addon) |
| **Hosting** | Scalingo (`osc-fr1` region) |
| **SSL** | Cloudflare |
| **Domain** | managed via one.com |

---

## Required Environment Variables

These must be set on Scalingo. All credentials are stored in **Kila Bitwarden**.

| Variable | Description |
|----------|-------------|
| `RAILS_MASTER_KEY` | Decrypts `config/credentials.yml.enc` |
| `CLOUDINARY_URL` | `cloudinary://API_KEY:API_SECRET@CLOUD_NAME` — takes priority over credentials file |
| `WEBLING_API_KEY` | API token for Webling — set on Scalingo or in credentials |
| `REDIS_URL` | Set automatically by Scalingo Redis addon |

> **Important:** `CLOUDINARY_URL` and `WEBLING_API_KEY` must be set as Scalingo env vars, not only in the credentials file. The credentials file contains the old Heroku-era values and should not be relied upon for these two.

Check current env vars:
```bash
scalingo --app kila-hildegarten env
```

---

## Architecture Overview

```text
                         ┌──────────────────────┐
                         │  Webling Platform    │
                         │  (member + file API) │
                         └──────────┬───────────┘
                                    │ JSON API calls
                                    │ (authenticated via token)
                                    ▼
                      ┌───────────────────────────┐
                      │  Rails Application        │
                      │  (Scalingo)               │
                      │                           │
                      │  • Fetches data from Webling
                      │  • Stores metadata in PostgreSQL
                      │  • Caches previews in Redis
                      │  • CSP managed via application.rb
                      │  • Serves assets via Asset Pipeline
                      └───────────┬────────────────┘
                                  │
       ActiveStorage              │          Cache Layer
  (with Cloudinary adapter)       │          (Redis on Scalingo)
  ┌────────────────────────┐      │      ┌────────────────────┐
  │  Cloudinary CDN        │◄─────┼──────│  Redis             │
  │  Stores image variants │             │  Cached previews   │
  └────────────────────────┘             └────────────────────┘
                                  │
                                  ▼
                      ┌──────────────────────────┐
                      │  Cloudflare Proxy/CDN    │
                      │  • HTTPS + Caching layer │
                      │  • Enforces SSL redirect │
                      └──────────┬───────────────┘
                                 │ HTTPS / HTTP2
                                 ▼
                      ┌──────────────────────────┐
                      │        Browser           │
                      │  (Parent or Member view) │
                      │                          │
                      │ - Loads Materialize CSS  │
                      │ - Lazy-loads images      │
                      │ - Falls back to          │
                      │   placeholder.png        │
                      └──────────────────────────┘
```

### Data Flow Summary

- **Webling → Rails:** Fetch photo metadata and folder info from the Webling API
- **Rails → Dropbox:** Retrieve original photo files via Dropbox gem
- **Rails → Cloudinary:** Store and serve image variants (resized previews)
- **Rails → Redis:** Cache photo metadata and Cloudinary URLs
- **Rails → Cloudflare → Browser:** Serve all content securely via Cloudflare

---

## Storage

- **Dropbox** stores original photo files for the public website (via a custom Dropbox connection gem)
- **Cloudinary** is used by ActiveStorage for image transformations (`resize_to_limit` etc.) — configured via `CLOUDINARY_URL` env var
- **Redis** caches Webling photo metadata and Cloudinary URLs to reduce API calls

---

## Webling Photo Cache

The `/webling_photos` page displays photo previews from Webling directly in the browser. It is embedded as an iframe inside the Webling member portal.

### How it works

1. When a photo is requested, `WeblingPhotoCacheService` checks if a `WeblingFile` record exists with an attached file
2. If not, it downloads the photo from the Webling API and uploads it to Cloudinary via ActiveStorage
3. The Cloudinary URL is cached in Redis for fast subsequent loads
4. The page is embedded in Webling via iframe — permitted via the `frame-ancestors` CSP directive

### If photos are not showing

Check the logs first:
```bash
scalingo --app kila-hildegarten logs -f
```

Look for `Cloudinary` or `WeblingPhotoCacheService error` entries.

If Cloudinary authorization errors appear, verify the `CLOUDINARY_URL` env var is set correctly and the Cloudinary account is active:
```bash
scalingo --app kila-hildegarten env | grep CLOUDINARY
scalingo --app kila-hildegarten run 'rails runner "puts Cloudinary.config.cloud_name"'
```

To reset the photo cache completely:
```bash
scalingo --app kila-hildegarten run 'rails runner "WeblingFile.all.each { |f| f.file.purge rescue nil; f.destroy }"'
```

> **the actions are safe** — `WeblingFile` is only a cache. The original files are hosted on Webling and are automatically fetched again is required. No photos get lost.
>
> **Access required** — the command require a login on the Scalingo account.

Photos will be re-fetched from Webling automatically on the next page load. First load will be slow — subsequent loads use the cache.

---

## Security Headers (CSP)

CSP and `X-Frame-Options` are managed **manually** in `config/application.rb` via `config.action_dispatch.default_headers` — **not** via the SecureHeaders gem. This is intentional: the SecureHeaders gem was stripping `https://` from `frame-ancestors` URLs, causing the Webling iframe to break repeatedly.

The SecureHeaders gem is still active for other minor security headers but opts out of CSP and X-Frame-Options (`config/initializers/secure_headers.rb`).

**Key iframe setting** — allows `/webling_photos` to be embedded in Webling:
```
frame-ancestors 'self' https://hildegarten.webling.eu https://hildegarten.webling.ch
```

> ⚠️ Do not move CSP or X-Frame-Options back to `secure_headers.rb` — it will break the iframe again.

If the iframe breaks again, check the actual response headers first:
```bash
curl -I https://kila-hildegarten.de/
```
Look for `content-security-policy` and `x-frame-options` in the output.

---

## Authentication

Uses **Devise** for user authentication. Because Cloudflare acts as an HTTPS proxy, Devise must recognize the original protocol correctly. Configuration follows [Rails issue #22965](https://github.com/rails/rails/issues/22965) (credit: TonyTonyJan).

---

## Frontend

Built with **MaterializeCSS**. Turbolinks are disabled for sidenav links to prevent reinitialization issues after first click.

```haml
= link_to 'Gallery', photos_path, data: { turbolinks: false }
```

---

## Asset Management

Assets (images, CSS, JS) are served via the Rails Asset Pipeline (Sprockets). On deploy, assets are precompiled with fingerprints.

The placeholder image lives in: `app/assets/images/placeholder.png`

If assets 404 in production:
```bash
scalingo --app kila-hildegarten run rails assets:clobber
scalingo --app kila-hildegarten run rails assets:precompile
```

---

## Development Setup

```bash
bundle install
bin/rails db:setup
bin/rails s
```

Run in production mode locally:
```bash
RAILS_ENV=production bin/rails assets:precompile
bin/rails s -e production
```

---

## Deployment

```bash
git push scalingo main
scalingo --app kila-hildegarten run rails db:migrate
```

---

## Maintenance Checklist

| **Task** | **Command** |
|----------|-------------|
| Check logs | `scalingo --app kila-hildegarten logs -f` |
| Check env variables | `scalingo --app kila-hildegarten env` |
| Open Rails console | `scalingo --app kila-hildegarten run rails console` |
| Run database migrations | `scalingo --app kila-hildegarten run rails db:migrate` |
| Restart app | `scalingo --app kila-hildegarten restart` |
| Rebuild assets | `scalingo --app kila-hildegarten run rails assets:clobber` then `scalingo --app kila-hildegarten run rails assets:precompile` |
| Clear Redis cache | `scalingo --app kila-hildegarten redis-console` → type `FLUSHALL` |
| Reset Webling photo cache | `scalingo --app kila-hildegarten run 'rails runner "WeblingFile.all.each { |f| f.file.purge rescue nil; f.destroy }"'` |

---

## Known Caveats

| **Issue** | **Description** | **Solution** |
|-----------|-----------------|--------------|
| iframe blocked in Webling | SecureHeaders gem strips `https://` from `frame-ancestors`; `x-frame-options: sameorigin` also blocks embedding | CSP and X-Frame-Options are set manually in `application.rb` — do not move them back to `secure_headers.rb` |
| Webling iframe from `.ch` domain | Webling uses both `.eu` and `.ch` domains | Both `https://hildegarten.webling.eu` and `https://hildegarten.webling.ch` are listed in `frame-ancestors` in `application.rb` |
| Devise login redirects incorrectly (HTTP/HTTPS) | Cloudflare proxy affects request scheme | Trusted proxy config in `lib/middleware/cloudflare.rb` following Rails issue #22965 |
| Placeholder image 404 | Asset pipeline not refreshed after deploy | Run `rails assets:clobber` then `rails assets:precompile` on Scalingo |
| Webling photos not showing (500 error) | `CLOUDINARY_URL` env var missing or Cloudinary account disabled | Set `CLOUDINARY_URL` on Scalingo; verify with `scalingo --app kila-hildegarten run 'rails runner "puts Cloudinary.config.cloud_name"'` |
| Old Cloudinary URLs still served after account change | `config/initializers/cloudinary.rb` was loading credentials before env var | Fixed: env var now takes priority in both `cloudinary.rb` initializer and `storage.yml` |

---

## External Services

| **Service** | **Link** | **Zweck** |
|-------------|----------|-----------|
| GitHub | [Resetete/kila-hildegarten](https://github.com/Resetete/kila-hildegarten) | Code-Verwaltung |
| Scalingo | [dashboard.scalingo.com](https://dashboard.scalingo.com) | Hosting (EU, DSGVO-konform) |
| Domain | [one.com](http://one.com) | Domain-Verwaltung |
| Cloudflare | [dash.cloudflare.com](https://dash.cloudflare.com) | SSL & CDN |
| Dropbox | — | Foto-Speicherung (öffentliche Webseite) |
| Cloudinary | [cloudinary.com/console](https://cloudinary.com/console) | Bild-Verarbeitung & Cache für Webling-Fotos |
| Webling | [hildegarten.webling.eu](https://hildegarten.webling.eu) | Mitgliederverwaltung |

> Alle Zugangsdaten sind im **Kila Bitwarden** gespeichert.

---

## License & Credits

Developed by **Theresa Mannschatz** for *Kinderladen Kila Hildegarten e.V.*
https://theresamannschatz.design
© 2026 — All rights reserved.
