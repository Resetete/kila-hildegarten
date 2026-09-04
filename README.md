# Kila Hildegarten – Website

Ruby on Rails application for the website of **Kinderladen Kila Hildegarten**.

Production website: **https://kila-hildegarten.de**

The application contains the public website, an administration area for managing website content, and an integration with Webling for displaying and managing photos.

---

## Overview

The application is a Ruby on Rails website with a small administration interface.

The public website contains pages such as:

- Home
- Team
- Parents
- Photos
- Contact
- Imprint

Administrators can log in and manage website content, team members and images through the Rails administration area.

The application also provides a Webling integration for displaying photos from the Kila's Webling account. The Webling photo area is designed to be embedded into Webling itself as an iframe.

---

## Technology Stack

### Backend

- Ruby 3.2.2 (note: `.ruby-version` may still contain `2.7.0` — keep these in sync)
- Ruby on Rails `~> 6.1.7`
- PostgreSQL
- Devise
- Haml
- Sprockets / Rails Asset Pipeline

### Frontend

- Haml
- Materialize CSS
- JavaScript / Webpacker 5.4.3
- Turbolinks
- jQuery
- Font Awesome

### Image and file handling

- Active Storage
- Cloudinary
- Dropbox
- MiniMagick
- Image Processing
- CarrierWave (for website team member photos)

### Webling integration

- Webling API
- WeblingPhotoCacheService
- Redis

### Hosting and infrastructure

- Scalingo (`osc-fr1` region)
- PostgreSQL (Scalingo managed)
- Redis (Scalingo addon)
- Cloudflare (proxy, HTTPS, CDN)
- one.com (domain)

---

## Versions

| Component          | Version                 |
|--------------------|-------------------------|
| Ruby               | 3.2.2                   |
| Rails              | `~> 6.1.7`              |
| Puma               | `~> 5.6`                |
| Webpacker          | `~> 5.4`                |
| Turbolinks         | `~> 5`                  |
| Devise             | `~> 4.9`                |
| PostgreSQL adapter | `pg >= 1.1`             |
| Cloudinary         | `~> 1.24`               |
| RSpec Rails        | `~> 5.1`                |

| JavaScript Component | Version           |
|----------------------|-------------------|
| Node.js              | 22.x              |
| Yarn                 | `>=1.22.19 <1.23` |
| Webpacker            | 5.4.3             |
| Materialize CSS      | 1.0.0             |
| Turbolinks           | 5.2.0             |
| jQuery               | 3.7.1             |
| JSZip                | 3.10.1            |

> ⚠️ The `Gemfile` specifies Ruby 3.2.2, while `.ruby-version` may still contain `ruby-2.7.0`. These files must be kept in sync when the Ruby version is changed.

---

## Required Environment Variables

Production credentials are provided through environment variables. **Never commit these to Git.**
All credentials are stored in the **Kila Bitwarden**.

| Variable           | Purpose                                                                  |
|--------------------|--------------------------------------------------------------------------|
| `RAILS_MASTER_KEY` | Decrypts `config/credentials.yml.enc`                                    |
| `CLOUDINARY_URL`   | `cloudinary://API_KEY:API_SECRET@CLOUD_NAME` — takes priority over credentials file |
| `WEBLING_API_KEY`  | Authentication for the Webling API — set on Scalingo, not only in credentials |
| `REDIS_URL`        | Set automatically by the Scalingo Redis addon                            |

> **Important:** `CLOUDINARY_URL` and `WEBLING_API_KEY` must be set as Scalingo env vars. The credentials file contains old Heroku-era values and must not be relied upon for these two variables.

Inspect the current Scalingo environment:
```bash
scalingo --app kila-hildegarten env
```

---

## Application Structure

```text
app/
├── assets/
├── controllers/
├── helpers/
├── javascript/
├── models/
├── services/
└── views/

config/
├── environments/
├── initializers/
├── application.rb       ← CSP and X-Frame-Options configured here
├── routes.rb
└── storage.yml

db/
├── migrate/
└── schema.rb

lib/
└── middleware/
       └── cloudflare.rb

public/
spec/
```

---

## Routes

Public routes:

```text
/
├── /contact
├── /team
├── /parents
├── /photos
└── /imprint
```

Webling integration:

```text
/webling_photos
/webling_photos/:id
POST /webling_photos/zip_download
```

Administration:

```text
/team_members
/contents
/images
```

---

## Administration

The admin area uses **Devise** for authentication. Authorized users can manage:

- Team members (name, description, photo)
- Website content (text pages)
- Images
- Webling photos

### Team Members

Team members are displayed in the order they were created — the first created appears at the top. To change the order, a team member must be deleted and re-created.

Photos uploaded for team members are automatically cropped to **300 × 400 px (portrait, 3:4)** from the centre of the image. Recommended minimum upload size: **600 × 800 px**. Allowed formats: JPG, JPEG, GIF, PNG.

---

## Webling Photo Integration

### Background

Webling is used to manage Kila families. The board uploads photos to Webling and makes them available to families in the Webling member portal. Webling has no native photo preview — families only see a list of filenames and must click each one individually.

To provide a photo preview with batch download, a protected page (`/webling_photos`) was created on the Kila website. This page is **not publicly accessible** — it requires a separate admin login. It is embedded as an iframe inside the Webling member portal so families see the photo gallery directly in their personal Webling area.

### How it works

1. `WeblingApiService` fetches folder and photo metadata from the Webling API (folder ID 295 — "Öffentliche Fotos")
2. `WeblingPhotoCacheService` downloads each photo from Webling and uploads it to Cloudinary via ActiveStorage
3. Cloudinary stores the image variant; the URL is cached in Redis for fast subsequent loads
4. Families see a photo gallery with individual download and ZIP batch download

### Folder Structure in Webling

> ⚠️ **Only direct subfolders of the root folder (ID 295) are shown — subfolders of subfolders are ignored.**

**Correct — will be displayed:**
```
📁 Öffentliche Fotos (ID 295)
   📁 2026-01 Fotos Januar
   📁 2026-02 Fotos Februar
   📁 2026-03 Fotos März
```

**Incorrect — will NOT be displayed:**
```
📁 Öffentliche Fotos (ID 295)
   📁 2026
      📁 Fotos Januar    ← ignored
      📁 Fotos Februar   ← ignored
```

**Automatic sorting:** Folders are sorted newest-first when the folder name starts with `YYYY-MM` (e.g. `2026-01 Fotos Januar`). This naming convention is strongly recommended.

### Webling Photo Cache Components

```text
WeblingPhotoCacheService
WeblingFile (ActiveRecord model)
Redis
Active Storage
Cloudinary
```

General flow:

```text
Webling API
    │
    ▼
WeblingApiService (fetches folder + photo metadata)
    │
    ▼
WeblingPhotoCacheService (downloads + uploads to Cloudinary)
    │
    ├── WeblingFile (database record)
    ├── Redis (metadata cache)
    └── Active Storage → Cloudinary (image storage)
```

---

## Webling iframe

The `/webling_photos` page is embedded into Webling using an iframe. The Rails application's Content Security Policy must explicitly allow the relevant Webling origins.

Current configuration (in `config/application.rb`):

```text
frame-ancestors 'self' https://hildegarten.webling.eu https://hildegarten.webling.ch
```

> ⚠️ Do not move CSP or `X-Frame-Options` into `config/initializers/secure_headers.rb` — the SecureHeaders gem strips `https://` from `frame-ancestors` URLs, which breaks the iframe.

---

## Security Headers

CSP and `X-Frame-Options` are configured **manually** in `config/application.rb` via `config.action_dispatch.default_headers`. This is intentional — see Webling iframe section above.

The SecureHeaders gem (`config/initializers/secure_headers.rb`) remains active for other minor security headers but opts out of CSP and X-Frame-Options.

If the iframe stops loading, check the actual response headers first:
```bash
curl -I https://kila-hildegarten.de/
```

Look for `content-security-policy` and `x-frame-options`.

---

## Cloudflare

Cloudflare sits in front of the production application and handles HTTPS, reverse proxying, CDN and SSL termination.

Because requests pass through Cloudflare before reaching Rails, proxy-related configuration is required — particularly for correct HTTP/HTTPS handling with Devise:

```text
lib/middleware/cloudflare.rb
```

---

## Local Development

### Requirements

- Ruby 3.2.2
- Bundler
- Node.js 22.x
- Yarn 1.22.x
- PostgreSQL

### Setup

```bash
bundle install
yarn install
bin/rails db:setup
bin/rails s
```

Run in production mode locally:
```bash
RAILS_ENV=production bin/rails assets:precompile
bin/rails s -e production
```

---

## Testing

```bash
bundle exec rspec
```

Test dependencies: RSpec, Capybara, Selenium WebDriver, Shoulda Matchers, Database Cleaner, Faker, Factory Girl Rails.

---

## Deployment

```bash
git push scalingo main
scalingo --app kila-hildegarten run rails db:migrate
```

---

## Scalingo Commands

| Task                      | Command                                                                |
|---------------------------|------------------------------------------------------------------------|
| Show logs                 | `scalingo --app kila-hildegarten logs -f`                              |
| Show environment          | `scalingo --app kila-hildegarten env`                                  |
| Rails console             | `scalingo --app kila-hildegarten run rails console`                    |
| Run migrations            | `scalingo --app kila-hildegarten run rails db:migrate`                 |
| Restart application       | `scalingo --app kila-hildegarten restart`                              |
| Redis console             | `scalingo --app kila-hildegarten redis-console`                        |
| Rebuild assets            | `scalingo --app kila-hildegarten run rails assets:clobber`             |
| Precompile assets         | `scalingo --app kila-hildegarten run rails assets:precompile`          |
| Reset Webling photo cache | see Webling Photo Cache Maintenance below                              |

---

## Webling Photo Cache Maintenance

If the photo cache needs to be completely rebuilt:

```bash
scalingo --app kila-hildegarten run 'rails runner "WeblingFile.all.each { |f| f.file.purge rescue nil; f.destroy }"'
```

> ✅ **This is safe** — `WeblingFile` is a cache only. Original photos remain on Webling and are re-fetched automatically on the next page load. No data is lost.
>
> 🔒 **Access required** — this command requires Scalingo account access (credentials in Kila Bitwarden). It cannot be run by Webling users.

---

## Troubleshooting

### Webling photos are not loading

Check the logs:
```bash
scalingo --app kila-hildegarten logs -f
```

Look for errors related to `Webling`, `WeblingPhotoCacheService`, `Cloudinary`, `Active Storage`, or `Redis`.

Check the Cloudinary configuration:
```bash
scalingo --app kila-hildegarten env | grep CLOUDINARY
scalingo --app kila-hildegarten run 'rails runner "puts Cloudinary.config.cloud_name"'
```

If the cloud name shown is wrong (old account), verify that `CLOUDINARY_URL` is set as an env var and that `config/initializers/cloudinary.rb` and `config/storage.yml` both prioritise `ENV["CLOUDINARY_URL"]` over the credentials file.

### Webling iframe is blocked

Check the response headers:
```bash
curl -I https://kila-hildegarten.de/
```

Verify that `content-security-policy` contains:
```text
https://hildegarten.webling.eu
https://hildegarten.webling.ch
```

Also check `x-frame-options`. Both are configured in `config/application.rb`.

### Login redirects incorrectly between HTTP and HTTPS

Check `lib/middleware/cloudflare.rb`. The application runs behind Cloudflare, so the original request protocol must be handled correctly (see [Rails issue #22965](https://github.com/rails/rails/issues/22965)).

### Images or assets return 404

```bash
scalingo --app kila-hildegarten run rails assets:clobber
scalingo --app kila-hildegarten run rails assets:precompile
```

---

## Known Caveats

| Issue | Description | Solution |
|-------|-------------|----------|
| iframe blocked in Webling | SecureHeaders gem strips `https://` from `frame-ancestors`; `x-frame-options: sameorigin` also blocks embedding | CSP and X-Frame-Options set manually in `application.rb` — do not move back to `secure_headers.rb` |
| Webling iframe from `.ch` domain | Webling uses both `.eu` and `.ch` domains | Both origins listed in `frame-ancestors` in `application.rb` |
| Webling photos not showing (500) | `CLOUDINARY_URL` missing or Cloudinary account disabled | Set `CLOUDINARY_URL` on Scalingo; verify cloud name with rails runner |
| Old Cloudinary URLs served after account change | Credentials file loaded before env var in `cloudinary.rb` and `storage.yml` | Both files now prioritise `ENV["CLOUDINARY_URL"]` |
| Devise login redirects incorrectly | Cloudflare proxy affects request scheme | Handled in `lib/middleware/cloudflare.rb` |
| Placeholder image 404 | Asset pipeline not refreshed | Run `assets:clobber` then `assets:precompile` on Scalingo |
| Webling subfolder photos not shown | Only direct subfolders of folder ID 295 are fetched — nested folders are ignored | Keep all photo folders at the top level; use `YYYY-MM` naming for automatic sorting |
| Ruby version mismatch | `Gemfile` specifies 3.2.2, `.ruby-version` may say 2.7.0 | Keep both files in sync |

---

## Important Files

| File / Directory                        | Purpose                                              |
|-----------------------------------------|------------------------------------------------------|
| `config/routes.rb`                      | Application routes                                   |
| `config/application.rb`                 | Main Rails configuration, including CSP and X-Frame-Options |
| `config/storage.yml`                    | Active Storage / Cloudinary configuration            |
| `config/initializers/cloudinary.rb`     | Cloudinary initializer — env var takes priority      |
| `config/initializers/secure_headers.rb` | SecureHeaders — opts out of CSP and X-Frame-Options  |
| `lib/middleware/cloudflare.rb`          | Cloudflare/proxy handling for Devise                 |
| `app/services/webling_api_service.rb`   | Fetches folder and photo metadata from Webling API   |
| `app/services/webling_photo_cache_service.rb` | Downloads photos from Webling, uploads to Cloudinary |
| `app/models/webling_file.rb`            | ActiveRecord model for cached Webling photos         |
| `app/uploaders/picture_uploader.rb`     | CarrierWave uploader for team member photos          |
| `db/migrate/`                           | Database migrations                                  |
| `db/schema.rb`                          | Current database schema                              |

---

## External Services

| Service    | Purpose                                          |
|------------|--------------------------------------------------|
| GitHub     | Source code and version control                  |
| Scalingo   | Production hosting (EU, GDPR-compliant)          |
| PostgreSQL | Application database                             |
| Redis      | Cache for Webling photo metadata                 |
| Cloudflare | Proxy, HTTPS and CDN                             |
| one.com    | Domain management                                |
| Webling    | Member management and photo source               |
| Cloudinary | Image storage and processing for Webling photos  |
| Dropbox    | Website photo storage (public website)           |

All access credentials are stored in the **Kila Bitwarden**.

---

## Repository

**https://github.com/Resetete/kila-hildegarten**

---

## License & Credits

Developed by **Theresa Mannschatz** for *Kinderladen Kila Hildegarten e.V.*
https://theresamannschatz.design
© 2026 — All rights reserved.
