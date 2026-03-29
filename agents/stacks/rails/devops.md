## Stack: Rails 8 / Ruby

### Deployment: Kamal

```bash
# Deploy to production
bin/kamal deploy

# View running containers
bin/kamal app details

# Open Rails console in production
bin/kamal console

# Rollback to previous release
bin/kamal rollback

# View logs
bin/kamal app logs
```

### Database Migrations in Production

```bash
# Run pending migrations (via Kamal exec)
bin/kamal app exec --reuse "bin/rails db:migrate"

# Check migration status
bin/kamal app exec --reuse "bin/rails db:migrate:status"
```

### Migration Safety Checklist

Before deploying a migration to production:
- [ ] Migration is backwards-compatible (old app code can run against the new schema)
- [ ] `ALTER TABLE` on large tables uses a safe approach — add column + backfill job, not direct transform
- [ ] Indexes on large tables use `algorithm: :concurrently` to avoid locking
- [ ] No `change_column` that changes column type — use explicit `up`/`down` instead
- [ ] `down` method exists and is correct, or migration uses a `reversible` block

### Required Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `RAILS_MASTER_KEY` | Decrypts `credentials.yml.enc` | (32-byte hex string) |
| `DATABASE_URL` | Primary PostgreSQL connection | `postgres://user:pass@host/db` |
| `DATABASE_URL_CACHE` | Solid Cache database | `postgres://user:pass@host/db_cache` |
| `DATABASE_URL_QUEUE` | Solid Queue database | `postgres://user:pass@host/db_queue` |
| `DATABASE_URL_CABLE` | Solid Cable database | `postgres://user:pass@host/db_cable` |
| `RAILS_ENV` | Runtime environment | `production` |
| `WEB_CONCURRENCY` | Puma worker count | `2` |

### CI Pipeline (GitHub Actions)

Standard job order:
1. `scan_ruby` — Brakeman static analysis + bundler-audit
2. `scan_js` — importmap audit
3. `lint` — RuboCop
4. `test` — RSpec models + requests
5. `system-test` — RSpec system specs with Capybara (saves failure screenshots as artifacts)
