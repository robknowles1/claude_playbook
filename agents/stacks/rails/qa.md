## Stack: Rails 8 / Ruby

### Test Commands

```bash
# Full suite
bundle exec rspec

# By layer
bundle exec rspec spec/models/
bundle exec rspec spec/requests/
bundle exec rspec spec/system/

# Verbose (shows each example name)
bundle exec rspec --format documentation

# Single file or example
bundle exec rspec spec/path/to/file_spec.rb:42

# Lint
bin/rubocop

# Security
bin/brakeman --no-pager
bin/bundler-audit

# JS dependency audit
bin/importmap audit
```

### Rails-Specific QA Checks

- [ ] `bin/rubocop` — zero offenses (or only auto-fixable ones already resolved)
- [ ] `bin/brakeman --no-pager` — no new warnings introduced by this change
- [ ] `bin/bundler-audit` — no known gem vulnerabilities
- [ ] `bin/importmap audit` — no JS dependency vulnerabilities
- [ ] Strong parameters used in all controller actions that accept user input
- [ ] No N+1 queries (check log output during system tests; look for missing `.includes`)
- [ ] Database constraints in migration match model validations
- [ ] Migrations are reversible (have a working `down` or use `reversible` block)
- [ ] Turbo Frame `id` attributes are consistent between the response and the target frame
- [ ] No inline JavaScript in ERB templates
- [ ] Stimulus controllers are scoped correctly and clean up after themselves
