# /kickoff Skill

Interactive Q&A to configure and bootstrap a new project from the saas-blueprint.

## Trigger

```
/kickoff [project-name]
```

**Examples:**
- `/kickoff my-saas-app`
- `/kickoff customer-dashboard`
- `/kickoff` (will prompt for name)

## Purpose

Guides through project setup with a structured Q&A to:
1. Gather project requirements and constraints
2. Select relevant blueprint domains
3. Configure technology choices
4. Generate initial project files
5. Create a customized PRD ready for Ralph

## Output

After completing kickoff, generates:

```
[project-name]/
├── ralph/
│   ├── ralph.config.json    # Configured from answers
│   ├── prd.md               # Assembled from selected domains
│   └── progress.txt         # Initialized
├── CLAUDE.md                # Project conventions
└── .claude/
    └── settings.json        # Claude Code configuration
```

## Q&A Flow

### Section 1: Project Identity

```
╔══════════════════════════════════════════════════════╗
║  PROJECT KICKOFF - Section 1/5: Project Identity     ║
╚══════════════════════════════════════════════════════╝

Q1. Project name (for directories, repo, package.json):
    Default: [current directory name]
    > my-saas-app

Q2. Display name (for UI, documentation):
    Default: My Saas App
    > My SaaS Application

Q3. Description (one sentence):
    > A multi-tenant dashboard for managing customer analytics

Q4. Repository location:
    a) GitHub (github.com/[username]/[repo])
    b) GitLab
    c) Bitbucket
    d) Self-hosted / Other
    e) No repository yet
    > a

Q5. GitHub organization or username:
    > feelgreatfoodie

Q6. Author name (for commits, package.json):
    > Christian Bourlier

Q7. Author email (for commits):
    > christian@example.com
```

### Section 2: Scope & Domains

```
╔══════════════════════════════════════════════════════╗
║  PROJECT KICKOFF - Section 2/5: Scope & Domains      ║
╚══════════════════════════════════════════════════════╝

Q8. What type of application?
    a) SaaS Dashboard (multi-tenant)
    b) Internal Tool (single-tenant)
    c) Public Website
    d) API-only Backend
    e) Other
    > a

Q9. Multi-tenant architecture?
    a) Yes - each customer has isolated data
    b) No - single shared database
    > a

Q10. Which domains should we include? (select all that apply)
    [x] auth        - Authentication, authorization, RBAC
    [x] database    - Data layer, schemas, security rules
    [x] api         - API routes, middleware, validation
    [x] ui          - Components, forms, layouts
    [ ] realtime    - WebSockets, live updates
    [ ] notifications - In-app, email, push
    [ ] compliance  - GDPR, audit logging
    [ ] testing     - Unit, integration, E2E

    > auth, database, api, ui

Q11. MVP or Full scope?
    a) MVP - Core features only (faster to build)
    b) Full - Complete feature set
    > a

Estimated effort based on selections:
├── auth:     12-18 hours
├── database:  8-12 hours
├── api:      18-26 hours
└── ui:       28-42 hours
─────────────────────────
Total:        66-98 hours
```

### Section 3: Tech Stack

```
╔══════════════════════════════════════════════════════╗
║  PROJECT KICKOFF - Section 3/5: Tech Stack           ║
╚══════════════════════════════════════════════════════╝

Q12. Frontend Framework:
    a) Next.js 14+ (App Router) [Recommended]
    b) Next.js (Pages Router)
    c) React (Vite)
    d) Other
    > a

Q13. Database:
    a) Firebase Firestore [Recommended for rapid development]
    b) Supabase (PostgreSQL)
    c) PostgreSQL (self-managed)
    d) MongoDB
    e) Other
    > a

Q14. Authentication Provider:
    a) Firebase Auth [Recommended with Firestore]
    b) Auth.js (NextAuth)
    c) Clerk
    d) Custom JWT
    > a

Q15. Styling Approach:
    a) Tailwind CSS [Recommended]
    b) CSS Modules
    c) styled-components
    d) Sass/SCSS
    > a

Q16. State Management:
    a) Zustand [Recommended for simplicity]
    b) Redux Toolkit
    c) Jotai
    d) React Context only
    > a

Q17. Email Provider (for notifications):
    a) Resend [Recommended]
    b) SendGrid
    c) AWS SES
    d) Skip for now
    > a
```

### Section 4: Execution Preferences

```
╔══════════════════════════════════════════════════════╗
║  PROJECT KICKOFF - Section 4/5: Execution Prefs      ║
╚══════════════════════════════════════════════════════╝

Q18. How should Claude work on this project?
    a) Fully autonomous - minimal interruptions [Recommended]
    b) Checkpointed - pause after each major phase
    c) Interactive - check in frequently
    > a

Q19. Quality gates to enforce:
    [x] TypeScript strict mode
    [x] ESLint on commit
    [x] Prettier formatting
    [ ] Unit test coverage
    [ ] E2E tests must pass
    [x] Build must succeed

    > TypeScript, ESLint, Prettier, Build

Q20. Commit strategy:
    a) Per user story - one commit per story
    b) Atomic - many small commits
    c) Batched - commit at end of sessions
    > a
```

### Section 5: Output Preferences

```
╔══════════════════════════════════════════════════════╗
║  PROJECT KICKOFF - Section 5/5: Output Preferences   ║
╚══════════════════════════════════════════════════════╝

Q21. Generate CLAUDE.md with project conventions?
    a) Yes [Recommended]
    b) No
    > a

Q22. Include security documentation?
    a) Yes - OWASP considerations, security rules
    b) No - skip for MVP
    > a

Q23. Include test templates?
    a) Yes - Jest, RTL, Playwright configs
    b) No - add testing later
    > b

Q24. Initialize git repository?
    a) Yes - with initial commit
    b) No - I'll do it manually
    > a
```

## Generated Files

### ralph/ralph.config.json

```json
{
  "version": "1.0",
  "project": {
    "name": "my-saas-app",
    "displayName": "My SaaS Application",
    "description": "A multi-tenant dashboard for managing customer analytics"
  },
  "repository": {
    "type": "github",
    "owner": "feelgreatfoodie",
    "name": "my-saas-app"
  },
  "author": {
    "name": "Christian Bourlier",
    "email": "christian@example.com"
  },
  "stack": {
    "framework": "nextjs-app-router",
    "database": "firebase-firestore",
    "auth": "firebase-auth",
    "styling": "tailwindcss",
    "state": "zustand",
    "email": "resend"
  },
  "domains": ["auth", "database", "api", "ui"],
  "scope": "mvp",
  "multiTenant": true,
  "execution": {
    "mode": "autonomous",
    "commitStrategy": "per-story",
    "qualityGates": ["typescript", "eslint", "prettier", "build"]
  },
  "createdAt": "2026-01-23T15:30:00Z"
}
```

### ralph/prd.md

Auto-generated by composing selected domains (equivalent to `/compose-prd auth database api ui`).

### CLAUDE.md

```markdown
# My SaaS Application

## Project Overview
A multi-tenant dashboard for managing customer analytics.

## Tech Stack
- **Framework**: Next.js 14 (App Router)
- **Database**: Firebase Firestore
- **Auth**: Firebase Authentication
- **Styling**: Tailwind CSS
- **State**: Zustand

## Architecture

### Multi-Tenant Design
- Each tenant has isolated data via tenantId field
- Custom claims store tenantId and role
- Security rules enforce tenant isolation

### Directory Structure
```
src/
├── app/                 # Next.js App Router pages
├── components/          # React components
│   ├── ui/             # Base UI components
│   └── features/       # Feature-specific components
├── lib/                # Utilities and helpers
│   ├── firebase/       # Firebase config and utilities
│   ├── auth/           # Authentication utilities
│   └── api/            # API client utilities
└── config/             # App configuration
```

## Critical Rules

1. **Never expose tenant data across boundaries**
   - Always filter by tenantId
   - Verify in security rules AND code

2. **Always validate on server**
   - Use Zod schemas for all API input
   - Never trust client-side validation alone

3. **Handle errors gracefully**
   - Use error boundaries in React
   - Return structured error responses from API

## Development Commands

```bash
npm run dev          # Start development server
npm run build        # Production build
npm run lint         # Run ESLint
npm run typecheck    # TypeScript check
```

## Conventions

- **Commits**: Conventional commits format
- **Branches**: feature/*, fix/*, chore/*
- **PRs**: Require passing CI before merge

---
Generated by /kickoff on 2026-01-23
```

### .claude/settings.json

```json
{
  "permissions": {
    "allowBash": ["npm", "git", "npx"],
    "allowFiles": true
  },
  "behaviors": {
    "confirmBeforeCommit": false,
    "autoFormat": true
  }
}
```

## Kickoff Summary

After completing Q&A:

```
╔══════════════════════════════════════════════════════╗
║  KICKOFF COMPLETE                                    ║
╚══════════════════════════════════════════════════════╝

Project: my-saas-app
Location: /Users/christian/projects/my-saas-app

Files Generated:
✅ ralph/ralph.config.json
✅ ralph/prd.md (19 user stories)
✅ ralph/progress.txt
✅ CLAUDE.md
✅ .claude/settings.json

Scope Summary:
├── Domains: auth, database, api, ui
├── Scope: MVP
├── Stories: 19
└── Estimate: 66-98 hours

Tech Stack:
├── Framework: Next.js (App Router)
├── Database: Firebase Firestore
├── Auth: Firebase Auth
├── Styling: Tailwind CSS
└── State: Zustand

Next Steps:
1. Review ralph/prd.md and adjust as needed
2. Run /ralph-convert to generate stories.json
3. Execute: ./ralph/ralph.sh

Ready to start building! 🚀
```

## Quick Mode

For experienced users, skip detailed Q&A:

```
/kickoff my-app --quick
```

Uses sensible defaults:
- Next.js App Router
- Firebase (Firestore + Auth)
- Tailwind CSS
- Zustand
- MVP scope
- auth + database + api + ui domains
- Fully autonomous execution

## Restart & Edit

To modify selections:

```
/kickoff my-app --edit
```

Loads previous config and allows changes.

## Templates

Kickoff can also generate starter code:

```
/kickoff my-app --with-starter
```

Adds:
- Basic Next.js project structure
- Firebase configuration
- Auth provider setup
- Sample components

## Notes

- All answers are saved in ralph.config.json for reference
- PRD can be regenerated with `/compose-prd`
- CLAUDE.md can be updated manually as project evolves
- Config drives Ralph's behavior during execution
