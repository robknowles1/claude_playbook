## Stack: React

### Project Conventions

- **React 18+** — functional components and hooks only; no class components
- **TypeScript** — strict mode; no `any` except at documented external boundaries
- **Tailwind CSS** — utility-first; no custom CSS files for layout or spacing
- **Testing** — Jest + React Testing Library (RTL); no Enzyme

### Project Structure

```
src/
  components/     # Reusable, presentational components
  features/       # Feature-scoped components and their hooks
  hooks/          # Shared custom hooks
  pages/          # Route-level components
  types/          # Shared TypeScript interfaces and types
  utils/          # Pure utility functions (no side effects, no React)
```

### Component Conventions

- One component per file; filename matches component name (PascalCase: `UserCard.tsx`)
- Define props interface directly above the component: `interface UserCardProps { ... }`
- No business logic in presentational components — lift it to custom hooks or feature components
- Keep components small: if a component is doing more than one thing, split it

### Hooks Conventions

- Custom hooks are prefixed with `use`: `useAuth`, `useFormState`, `useDebounce`
- Hooks extract logic from components — they return data and callbacks, they do not render
- Keep `useEffect` dependency arrays accurate — do not suppress the `exhaustive-deps` lint rule without a documented reason
- Prefer multiple focused `useEffect`s over one large one

### TypeScript Conventions

- Prefer `interface` for object shapes; `type` for unions, intersections, and aliases
- No `any` — use `unknown` + type narrowing at system boundaries (API responses, external data)
- Props, hook return types, and API response shapes must be explicitly typed
- Use generics rather than `any` for reusable utilities

### Tailwind CSS Conventions

- Apply utility classes directly in JSX — no separate CSS files for layout or spacing
- Extract repeated class combinations into a component, not a CSS class
- Mobile-first responsive design: base → `sm:` → `md:` → `lg:`
- Use `dark:` variants if the project supports dark mode

### Testing with React Testing Library

```tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'

it('submits the form with valid input', async () => {
  const user = userEvent.setup()
  const onSubmit = jest.fn()

  render(<LoginForm onSubmit={onSubmit} />)

  await user.type(screen.getByLabelText('Email'), 'test@example.com')
  await user.type(screen.getByLabelText('Password'), 'password123')
  await user.click(screen.getByRole('button', { name: /sign in/i }))

  expect(onSubmit).toHaveBeenCalledWith({
    email: 'test@example.com',
    password: 'password123',
  })
})
```

**Testing rules:**
- Query by role, label, or visible text — not by class name or `data-testid` unless no accessible alternative exists
- Test what the user sees and does, not internal component state
- Mock at the API/network boundary (fetch, axios), not inside components
- Use `userEvent` for interactions, not `fireEvent` (more realistic async handling)

### Common Commands

```bash
npm test                              # run all tests (watch mode)
npm test -- --watchAll=false          # run once (CI mode)
npm test -- --coverage --watchAll=false  # with coverage report
npm run lint                          # ESLint
npm run type-check                    # TypeScript compiler check, no emit
npm run build                         # production build
```
