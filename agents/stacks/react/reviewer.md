## Stack: React

### React-Specific Review Points

**Correctness**
- `useEffect` dependency arrays are complete — no missing deps, no suppressed `exhaustive-deps` warnings without a documented reason
- No stale closure bugs: values read inside `useEffect` or event handlers reflect current state/props
- No direct state mutation (`arr.push(item)` before `setState` — always produce a new reference)
- List keys are stable and unique — not array index for lists that can reorder or filter

**Performance**
- No unstable object or array references created inline in JSX (triggers unnecessary child re-renders)
- `useMemo` and `useCallback` used where referential stability or expensive computation genuinely matters — not applied speculatively everywhere
- No heavy computation on every render without memoization
- Large lists use virtualization (`react-window` or similar) if rendering hundreds of items

**TypeScript**
- No `any` — use `unknown` + type narrowing, or proper generics
- Props interfaces are complete and accurate for all rendered and forwarded props
- API response shapes are explicitly typed, not inferred from raw `fetch` return values

**Security**
- No `dangerouslySetInnerHTML` with unsanitized user-supplied content
- No sensitive values (auth tokens, PII) stored in `localStorage` without documented justification
- No user-controlled values interpolated into dynamic `import()` or `eval()`

**Tailwind / Styling**
- No inline `style` props for layout or spacing — use Tailwind utilities
- No Tailwind class names constructed by concatenating strings from user input (breaks purge/JIT)
- Responsive breakpoints applied consistently across the feature
- Dark mode variants (`dark:`) applied wherever the base style is set, if the project supports dark mode

**Testing**
- Tests cover the primary acceptance criteria for the component or feature
- Interactions use `userEvent`, not `fireEvent`
- Mocks are at the network boundary, not patching internal component behavior
