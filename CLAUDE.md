# Ralph for Claude Code

## Project Overview

Ralph is an autonomous code generation system that uses Claude Code to implement entire projects from meeting notes or PRDs. It breaks work into small tasks, runs each in a fresh Claude session, and commits changes incrementally.

## Repository Structure

```
ralph-claude-code/
├── scripts/                    # Core execution scripts
│   ├── ralph.sh               # Main execution loop
│   ├── ralph-init.sh          # Project initialization
│   └── package.sh             # Create shareable package
├── skills/                     # Claude Code skills (prompt templates)
│   ├── prd/                   # /prd - Generate PRD from notes
│   ├── ralph-convert/         # /ralph-convert - PRD to JSON
│   ├── compose-prd/           # /compose-prd - Merge domain PRDs
│   ├── extract-domain/        # /extract-domain - Extract from codebase
│   ├── kickoff/               # /kickoff - Interactive project setup
│   └── verify-blueprint/      # /verify-blueprint - Validate blueprint
├── saas-blueprint/             # Complete SaaS reference blueprint (separate git repo)
│   ├── domains/               # 8 domain extractions
│   ├── architecture/          # System design docs
│   ├── security/              # OWASP coverage, security patterns
│   ├── engineering/           # Best practices
│   └── questions/             # Planning frameworks
├── install.sh                  # One-line installer
└── README.md                   # User documentation
```

## Key Scripts

### ralph.sh

Main autonomous execution loop:
- Reads `./ralph/prd.json` for task list
- Runs Claude Code for each task
- Executes quality gates (lint, typecheck, test, build)
- Commits changes to git
- Updates progress tracking

### ralph-init.sh

Initializes a project for Ralph:
- Creates `./ralph/` directory
- Auto-detects tech stack
- Creates configuration files
- Sets up progress tracking

## Skills (Slash Commands)

| Skill | Purpose |
|-------|---------|
| `/prd` | Generate structured PRD from meeting notes |
| `/ralph-convert` | Convert PRD markdown to JSON task list |
| `/compose-prd` | Merge multiple domain PRD fragments |
| `/extract-domain` | Extract patterns from existing codebase |
| `/kickoff` | Interactive Q&A for new project setup |
| `/verify-blueprint` | Validate blueprint completeness |

## The saas-blueprint

A complete reference implementation extracted from a real SaaS project:

### Domains (8 total)
- **auth** - Firebase Auth, RBAC, multi-tenant
- **database** - Firestore patterns, security rules
- **api** - Next.js route handlers, middleware
- **ui** - React components, forms, state
- **realtime** - Firestore subscriptions
- **notifications** - Email, in-app alerts
- **compliance** - GDPR, audit logging
- **testing** - Jest, Playwright, Storybook

### Domain Structure
Each domain has 6 standard files:
```
domains/[name]/
├── README.md           # Overview and quick links
├── patterns.md         # Implementation patterns with code
├── deep-dive.md        # Educational: WHY these patterns work
├── questions.md        # Planning questions (15-25)
├── prd-fragment.md     # User stories for Ralph
└── templates/          # Reusable code snippets
```

## Development Conventions

### Commits
- Use conventional commits format
- Include `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` when Claude generates the change

### File Naming
- Scripts: `kebab-case.sh`
- Skills: `skill-name/prompt.md`
- Domains: lowercase single word (auth, api, ui)

### Quality Gates
When modifying scripts:
- Test with `bash -n script.sh` for syntax
- Test initialization on empty directory
- Verify quality gate detection works

### Blueprint Verification
After modifying saas-blueprint:
```bash
./saas-blueprint/scripts/verify-blueprint.sh ./saas-blueprint
```

## Critical Rules

1. **Fresh Context Per Task** - Ralph's key innovation. Each task runs in a new Claude session to prevent confusion.

2. **External State** - All important information must be in files (progress.txt, prd.json), not Claude's memory.

3. **Quality Gates** - Every task must pass lint, typecheck, test, and build before committing.

4. **Incremental Commits** - One commit per task with descriptive message.

## Testing Changes

### Test ralph-init.sh
```bash
mkdir /tmp/test-project && cd /tmp/test-project
git init
/path/to/ralph-init.sh
```

### Test ralph.sh
```bash
cd test-project
# Add a simple prd.json
~/.ralph/ralph.sh
```

### Test Blueprint Verification
```bash
./saas-blueprint/scripts/verify-blueprint.sh ./saas-blueprint
```

## Related Repositories

- `saas-blueprint/` - Separate git repo inside this project
- User projects use `./ralph/` directory (created by ralph-init.sh)

## Common Tasks

### Add a New Skill
1. Create `skills/[name]/prompt.md`
2. Document in README.md
3. Add to INDEX.md in saas-blueprint if relevant

### Add a New Domain to Blueprint
1. Use `/extract-domain` skill on source codebase
2. Verify with `/verify-blueprint`
3. Update manifest.json and INDEX.md

### Fix Blueprint Issues
1. Run verify-blueprint.sh to identify gaps
2. Fix missing files or content
3. Re-run verification
4. Commit to saas-blueprint repo

---

*Last updated: 2026-01-23*
