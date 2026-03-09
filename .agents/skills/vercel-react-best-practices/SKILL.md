---
name: vercel-react-best-practices
description: React and Next.js performance optimization guidelines from Vercel Engineering. Use when writing, reviewing, or refactoring React/Next.js code to reduce waterfalls, bundle size, and rerender overhead.
license: MIT
metadata:
  author: vercel
  version: "1.0.0"
---

# Vercel React Best Practices

Apply high-impact React/Next.js performance rules during implementation and review.

## When to Use
- Building or refactoring React components/pages
- Reviewing performance-sensitive frontend code
- Optimizing data fetching and bundle loading
- Reducing rerenders and hydration cost

## Priority Order
1. Eliminate waterfalls (`async-*`)
2. Optimize bundle size (`bundle-*`)
3. Improve server-side performance (`server-*`)
4. Improve client-side data fetching (`client-*`)
5. Reduce rerenders (`rerender-*`)
6. Improve rendering performance (`rendering-*`)
7. Improve JavaScript hot paths (`js-*`)
8. Apply advanced patterns only when needed (`advanced-*`)

## Operating Rule
- Prefer the highest-impact fix first.
- Avoid micro-optimizations until waterfall/bundle issues are resolved.
- For code review, report concrete file:line findings and a minimal patch direction.

## Source
- Repository: `https://github.com/vercel-labs/agent-skills`
- Skill path: `skills/react-best-practices`
- Full guideline (agent-focused): `https://raw.githubusercontent.com/vercel-labs/agent-skills/main/skills/react-best-practices/AGENTS.md`
