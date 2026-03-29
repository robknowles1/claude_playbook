## Stack: Rails 8 / Ruby

### Project Conventions

- **Ruby / Rails 8** — follow Rails conventions over custom abstractions
- **PostgreSQL** — use migrations for all schema changes; add DB-level constraints alongside model validations
- **Hotwire** — Turbo + Stimulus for all frontend interactivity; no separate JS framework
- **ERB** — server-rendered views with Tailwind CSS utility classes
- **Propshaft** — no asset compilation; JS managed via importmap-rails only
- **Solid Queue** — background jobs (no Sidekiq, no Redis)
- **RuboCop** — rubocop-rails-omakase style; run `bin/rubocop -a` before handoff

### Testing Stack

RSpec (not Minitest). If not yet in the Gemfile, add:

```ruby
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end
```

Then run: `bundle install && bin/rails generate rspec:install`

```bash
bundle exec rspec                               # all tests
bundle exec rspec spec/models/                  # unit tests
bundle exec rspec spec/requests/                # request/integration tests
bundle exec rspec spec/system/                  # end-to-end (Capybara + Selenium)
bundle exec rspec spec/path/to/file_spec.rb:42  # single example
```

### Code Conventions

**Models**
- Validate at the model layer; always test validations with shoulda-matchers
- Use scopes for common queries; name them for the domain concept, not the SQL
- Avoid callbacks that trigger side effects (emails, jobs) — call them explicitly in controllers or service objects

**Controllers**
- RESTful actions via `resources` routing
- Strong parameters on every action that accepts input (`params.require(...).permit(...)`)
- `before_action` for auth and record loading
- Avoid N+1 with `.includes` or `.eager_load` on associations used in views

**Views / Hotwire / Tailwind**
- Turbo Frames for partial page updates: `<turbo-frame id="...">`
- Turbo Streams for multi-target or real-time updates
- Stimulus controllers for JS behavior — one controller per behavior, keep them small
- No inline JavaScript; all JS via importmap + Stimulus
- Tailwind utility classes directly in ERB — no custom CSS for layout or spacing

**Background Jobs**
- Inherit from `ApplicationJob` (Solid Queue)
- Jobs must be idempotent — safe to retry on failure without double-processing

### Common RSpec Patterns

```ruby
# Model spec
RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to have_many(:posts).dependent(:destroy) }
end

# Request spec
RSpec.describe "POST /sessions", type: :request do
  it "signs in with valid credentials and redirects" do
    post sessions_path, params: { email: user.email, password: "correct" }
    expect(response).to redirect_to(root_path)
  end

  it "returns unprocessable entity with invalid credentials" do
    post sessions_path, params: { email: user.email, password: "wrong" }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end

# System spec
RSpec.describe "User creates a post", type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it "allows a signed-in user to submit the form and see the result" do
    sign_in create(:user)
    visit new_post_path
    fill_in "Title", with: "Hello World"
    click_button "Create Post"
    expect(page).to have_text("Post was successfully created.")
  end
end
```
