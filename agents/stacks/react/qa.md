## Stack: React

### Test Commands

```bash
# Run all tests (CI mode, no watch)
npm test -- --watchAll=false

# With coverage report
npm test -- --coverage --watchAll=false

# Single file
npm test -- src/components/Button.test.tsx --watchAll=false

# TypeScript check
npm run type-check

# Lint
npm run lint

# Production build (catches type and import errors)
npm run build
```

### React-Specific QA Checks

- [ ] `npm run type-check` — zero TypeScript errors
- [ ] `npm run lint` — zero ESLint errors (warnings are advisory)
- [ ] `npm run build` — production build completes without errors or warnings
- [ ] No `console.error` or `console.warn` output during test runs (indicates React warnings)
- [ ] No `act()` warnings in test output (indicates unhandled async state updates)

### Test Quality Checks

- [ ] Tests query by role, label, or visible text — not by CSS class or arbitrary `data-testid`
- [ ] User interactions use `userEvent`, not `fireEvent`
- [ ] API calls are mocked at the fetch/axios level, not by patching component internals
- [ ] No snapshots used purely for coverage — every snapshot is intentional and reviewed on change

### Accessibility Spot Checks

- [ ] All form inputs have an associated `<label>` (`htmlFor`) or `aria-label`
- [ ] Interactive elements (`button`, `a`, custom controls) are reachable by Tab and activated by Enter/Space
- [ ] Images and icons have meaningful `alt` text (or `alt=""` if purely decorative)
- [ ] Color contrast meets WCAG AA minimum (4.5:1 for normal text, 3:1 for large text)
