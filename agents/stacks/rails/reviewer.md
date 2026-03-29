## Stack: Rails 8 / Ruby

### Rails-Specific Review Points

**Security**
- Strong parameters on every controller action that accepts user input (`params.require(...).permit(...)`)
- No `params[:id]` used directly in database queries without scoping to the current user's records
- No redirect to a user-supplied URL without validation (open redirect)
- ERB output is escaped by default — flag any `html_safe` or `raw` usage and verify it is safe

**Performance**
- Controller `index` and `show` actions eager-load associations used in the view (`.includes`, `.eager_load`)
- New query patterns have a supporting index in the migration
- No `Model.all` or unbounded queries in controller actions — scope or paginate
- Heavy work in request paths should be moved to a Solid Queue job

**Hotwire**
- Turbo Frame `id` attributes are stable and unique — not derived from dynamic content that changes between renders
- Turbo Stream responses target the correct, existing DOM IDs
- Stimulus controllers are small, handle one behavior, and disconnect cleanly (`disconnect()` cleans up event listeners if added manually)

**Rails Conventions**
- `bin/rubocop` is clean — no new offenses introduced
- Business logic belongs in models (or explicit service objects when justified), not in views or helpers
- No raw SQL unless justified and properly parameterized
- Migrations are reversible; `dependent:` option set on associations where the child row would become orphaned
- Background jobs inherit from `ApplicationJob` and are idempotent

**ERB / Tailwind**
- No logic-heavy ERB — extract to helpers or view objects if complex
- Tailwind utility classes used directly; no custom CSS for standard layout/spacing patterns
- Responsive breakpoints applied consistently across the feature
