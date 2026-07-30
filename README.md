# README

Here I am building the website for our Kinderladen Kila Hildegarten.

The main website is: [https://kila-hildegarten.de](https://kila-hildegarten.de)

## Note

Using Cloudflare to securely connect with the domain provider required redirecting from HTTP to HTTPS.
This does not work correctly with Devise since the request header is not changed from HTTP to HTTPS.
Following this [Rails issue #22965](https://github.com/rails/rails/issues/22965), I implemented the recommendation by **TonyTonyJan**.

Turbolinks are disabled for links in the Materialize sidenav bar.
If they are enabled, the links will not work after first-time triggering.

---

## Technical Specifications

- Security policies are managed via the **SecureHeaders** gem. Policies are controlled through `config/initializers/secure_headers.rb`.
- The app is hosted on [**Scalingo**](https://scalingo.com/). 
- There is also an API connection to **Webling**.
- **Redis** (Scalingo Redis) is used to cache Webling photos for previews.
- Photos are stored on **Dropbox**, using a custom Dropbox connection gem updated for current compatibility.

---

# Kila Hildegarten – Website

This repository contains the Ruby on Rails application for the **Kinderladen Kila Hildegarten** website.
It serves both the public website and an internal admin integration with [Webling](https://www.webling.eu/).

🌐 **Production:** [https://kila-hildegarten.de](https://kila-hildegarten.de)
🧪 **Staging (Scalingo):** [https://kila-hildegarten.osc-fr1.scalingo.io/](https://kila-hildegarten.osc-fr1.scalingo.io/)

---

## Overview

The app provides a CMS-like interface. It allows admins to log in and update website content and photos stored on **Dropbox**.

For our Webling Kila management software, we use a secured page `/webling_photos` for managing photo previews, content pages, and member information synced from Webling.
Only admins with the correct access token can access this page.
It uses **Cloudinary** for asset storage and **Redis** caching for photo previews.

The stack is intentionally lightweight and optimized for hosting on **Scalingo** with **Cloudflare** as CDN and SSL proxy.

---

## Technical Specifications

### Framework & Hosting

- **Ruby on Rails** (7.x)
- **Ruby version:** specify your current version (e.g. `3.2.3`)
- **Database:** PostgreSQL (Scalingo managed)
- **Cache:** Redis (Scalingo Redis)
- **Website Hosting:** Scalingo.com
- **SSL:** via Cloudflare
- **Domain:** managed via `one.com`

---

### Asset Management

- Assets (images, CSS, JS) are served via the **Rails Asset Pipeline (Sprockets)**.
- On deploy, assets are precompiled with fingerprints (e.g. `placeholder-<hash>.png`).
- The placeholder image lives in: `app/assets/images/placeholder.png`

**Example usage:**
```haml
= image_tag('placeholder.png', onerror: "this.src='#{image_path('placeholder.png')}'")
```

If assets 404 in production:
```bash
scalingo --app kila-hildegarten run rails assets:clobber
scalingo --app kila-hildegarten run rails assets:precompile
```

---

### Storage

- **Dropbox** is used to store original photo files for the website (via a custom Dropbox connection gem).
- **Cloudinary** is used by ActiveStorage for image transformations (`resize_to_limit`, etc.).
  Images are cached and served lazily to improve load times.

---

### Security Headers (CSP)

CSP and `X-Frame-Options` are managed manually in `config/application.rb` via
`config.action_dispatch.default_headers` to avoid the SecureHeaders gem mangling `https://` URLs.

The SecureHeaders gem is still used for other minor security headers, but opts out of CSP
and X-Frame-Options (`config/initializers/secure_headers.rb`).

**Key iframe setting** — allows `/webling_photos` to be embedded in Webling:
```ruby
"frame-ancestors 'self' https://hildegarten.webling.eu"
```

If the iframe ever breaks again, check the actual headers first:
```bash
curl -I https://kila-hildegarten.de/
```
Look for `content-security-policy` and `x-frame-options` in the output.

---

### Webling Integration

Integrates with the Webling API to fetch folders, files, and member information.
API results are cached in Redis to reduce requests.
Webling file objects are wrapped via `WeblingFile` ActiveRecord models.
The `/webling_photos` page is embedded into the third-party Webling app via iframe.

#### Caching

Redis is used for caching photo previews and metadata.
Cached photos are refreshed periodically when Webling data changes.

---

## Authentication

Uses **Devise** for user authentication.
Because Cloudflare acts as an HTTPS proxy, Devise must recognize the original protocol correctly.
Configuration follows [Rails issue #22965](https://github.com/rails/rails/issues/22965) (credit: **TonyTonyJan**).

---

## Frontend

Built with **MaterializeCSS**.
Turbolinks are disabled for sidenav links to prevent reinitialization issues.

**Example:**
```haml
= link_to 'Gallery', photos_path, data: { turbolinks: false }
```

---

# Architecture Overview

The Kila Hildegarten app integrates several external services to deliver optimized photo content and a secure web experience.

## High-Level Architecture

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
                      │  (Scalingo)                 │
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
  │  Cloudinary CDN        │◄─────┼──────│  Redis              │
  │  Stores image variants │             │  Cached previews    │
  └────────────────────────┘             └────────────────────┘
                                  │
                                  │
                                  ▼
                      ┌──────────────────────────┐
                      │  Cloudflare Proxy/CDN    │
                      │  • HTTPS + Caching layer │
                      │  • Enforces SSL redirect │
                      └──────────┬───────────────┘
                                 │
                                 │ HTTPS / HTTP2
                                 ▼
                      ┌──────────────────────────┐
                      │        Browser            │
                      │  (Parent or Member view)  │
                      │                          │
                      │ - Loads Materialize CSS   │
                      │ - Lazy-loads images       │
                      │ - Falls back to           │
                      │   `placeholder.png` if    │
                      │   image fails to load     │
                      └──────────────────────────┘
```

---

## Data Flow Summary

- **Webling → Rails:** Fetch photo metadata and folder info from the Webling API.
- **Rails → Dropbox:** Retrieve original photo files via Dropbox gem.
- **Rails → Cloudinary:** Store and serve image variants (resized previews).
- **Rails → Redis:** Cache photo metadata and Cloudinary URLs.
- **Rails → Cloudflare → Browser:** Serve all content securely via Cloudflare.
- **Browser:** MaterializeCSS frontend with lazy loading and placeholder fallback.

---

## Key Features

- CSP is managed manually in application.rb, allowing Dropbox and Cloudinary image sources.
- **Resilient image loading** using lazy `data-src` and fallback placeholders.
- **HTTPS enforcement** via Cloudflare and trusted proxy config.
- **Lightweight integration** — Webling acts as backend data source.

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

Deploy to Scalingo:

```bash
git push scalingo main
scalingo --app kila-hildegarten run rails db:migrate
```

Rebuild all assets:

```bash
scalingo --app kila-hildegarten run rails assets:clobber
scalingo --app kila-hildegarten run rails assets:precompile
```

---

## Maintenance Checklist

| **Task** | **Command** |
|-----------|-------------|
| Clear Redis cache | `scalingo --app kila-hildegarten redis-console` → then type `FLUSHALL` |
| Rebuild assets | `scalingo --app kila-hildegarten run rails assets:clobber && scalingo --app kila-hildegarten run rails assets:precompile` |
| Restart app | `scalingo --app kila-hildegarten restart` |
| Run database migrations | `scalingo --app kila-hildegarten run rails db:migrate` |
| Open Rails console | `scalingo --app kila-hildegarten run rails console` |
| Check logs | `scalingo --app kila-hildegarten logs -f` |
| Check env variables | `scalingo --app kila-hildegarten env` |


---

## Known Caveats

| **Issue** | **Description** | **Solution** |
|------------|-----------------|---------------|
| Devise login redirects incorrectly (HTTP/HTTPS) | Cloudflare proxy affects request scheme | Use `config.force_ssl = true` and trust proxy headers |
| Placeholder 404 | Asset pipeline not refreshed | Run `scalingo --app kila-hildegarten run rails assets:clobber` and `scalingo --app kila-hildegarten run rails assets:precompile` |
| Cloudinary images blocked | CSP restriction | Add `https://res.cloudinary.com` to `img_src` in `secure_headers.rb` |
| iframe blocked in Webling | SecureHeaders gem strips `https://` from `frame-ancestors`, and `x-frame-options: sameorigin` also blocks embedding | CSP and X-Frame-Options are set manually in `application.rb`; do not move them back to `secure_headers.rb` |

---

## License & Credits

Developed by **Theresa Mannschatz** for *Kinderladen Kila Hildegarten e.V.*
https://theresamannschatz.design
© 2025 — All rights reserved.
