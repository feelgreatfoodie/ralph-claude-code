# Ralph for Claude Code

> **Build complete applications autonomously using AI — from meeting notes to working code.**

Ralph is an automation system that runs Claude Code (Anthropic's AI coding assistant) repeatedly to implement entire software projects without manual intervention. You describe what you want to build, and Ralph handles the rest.

---

## Table of Contents

1. [What is Ralph?](#what-is-ralph)
2. [How It Works](#how-it-works)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Quick Start Guide](#quick-start-guide)
6. [Detailed Walkthrough](#detailed-walkthrough)
7. [Configuration Options](#configuration-options)
8. [Sharing with Teammates](#sharing-with-teammates)
9. [Troubleshooting](#troubleshooting)
10. [FAQ](#faq)
11. [Contributing](#contributing)

---

## What is Ralph?

Imagine you have a meeting where your team discusses a new feature. Someone takes notes. Normally, a developer would then spend hours or days turning those notes into working code.

**Ralph changes this.**

With Ralph, you:
1. Paste your meeting notes into a file
2. Run a few commands
3. Walk away while Ralph builds your application

Ralph breaks your project into small, manageable tasks and completes them one by one — writing code, running tests, fixing errors, and committing changes to git. Each task is done with a fresh perspective, preventing the AI from getting confused or making compounding mistakes.

### Key Benefits

- **Autonomous**: Runs without supervision until complete
- **Quality-focused**: Automatically runs linting, type checking, and tests
- **Knowledge-preserving**: Documents learnings for future iterations
- **Portable**: Easy to share with teammates
- **Iterative**: You can review, adjust, and re-run at any time

---

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   📝 Meeting Notes / Feature Description                        │
│                                                                 │
│   "We need a task manager with CRUD operations..."              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   📋 PRD Generation (claude /prd)                               │
│                                                                 │
│   Transforms notes into structured requirements                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   🔄 JSON Conversion (claude /ralph-convert)                    │
│                                                                 │
│   Creates machine-readable task list                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   🤖 Autonomous Execution (ralph.sh)                            │
│                                                                 │
│   For each task:                                                │
│   ├── Start fresh Claude instance                               │
│   ├── Read current state from files                             │
│   ├── Implement one task                                        │
│   ├── Run quality checks (lint, test, build)                    │
│   ├── Commit changes to git                                     │
│   ├── Document learnings                                        │
│   └── Mark task complete                                        │
│                                                                 │
│   Repeat until all tasks are done!                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   ✅ Complete Application                                        │
│                                                                 │
│   All code written, tested, and committed                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The Secret: Fresh Context

The key innovation is that **each task runs with fresh context**.

When you use AI tools manually for a long time, they can get confused — mixing up old code with new, forgetting what was changed, or making the same mistake repeatedly.

Ralph avoids this by:
- Starting a completely new Claude instance for each task
- Forcing all important information to be written to files
- Letting each instance read the current state fresh

This means task #10 is just as accurate as task #1.

---

## Prerequisites

Before installing Ralph, you'll need a few things set up on your computer.

### 1. Claude Code CLI

Claude Code is Anthropic's command-line AI coding assistant. Ralph uses it to do the actual coding work.

**Installation:**
1. Visit [claude.ai/download](https://claude.ai/download) or the official documentation
2. Download and install Claude Code for your operating system
3. Open your terminal and run: `claude --version`
4. If you see a version number, you're good!

**Authentication:**
```bash
claude auth login
```
Follow the prompts to log in with your Anthropic account.

### 2. Git

Git tracks changes to your code. Ralph uses it to save progress after each task.

**Check if installed:**
```bash
git --version
```

**If not installed:**
- **Mac**: Install Xcode Command Line Tools: `xcode-select --install`
- **Windows**: Download from [git-scm.com](https://git-scm.com/download/win)
- **Linux**: `sudo apt install git` (Ubuntu/Debian) or `sudo yum install git` (CentOS/RHEL)

### 3. A Terminal

You'll run commands in a terminal application:
- **Mac**: Terminal (built-in) or iTerm2
- **Windows**: PowerShell, Command Prompt, or Windows Terminal
- **Linux**: Your default terminal

### 4. A Text Editor (Optional but Helpful)

For reviewing and editing files:
- [VS Code](https://code.visualstudio.com/) (free, recommended)
- Any text editor you're comfortable with

---

## Installation

### Option A: One-Line Install (Recommended)

Open your terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/feelgreatfoodie/ralph-claude-code/main/install.sh | bash
```

This downloads and sets up Ralph automatically.

### Option B: Manual Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/feelgreatfoodie/ralph-claude-code.git
   cd ralph-claude-code
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

3. **Add Ralph to your PATH** (so you can run it from anywhere):

   For **Zsh** (default on Mac):
   ```bash
   echo 'export PATH="$HOME/.ralph:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

   For **Bash**:
   ```bash
   echo 'export PATH="$HOME/.ralph:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Verify installation:**
   ```bash
   ls ~/.ralph
   ```
   You should see files like `ralph.sh`, `prompt.md`, etc.

---

## Quick Start Guide

Here's the fastest way to get Ralph running on a new project:

### Step 1: Create or Navigate to Your Project

```bash
# Create a new project folder
mkdir my-awesome-app
cd my-awesome-app

# Initialize git (required)
git init
```

### Step 2: Initialize Ralph

```bash
~/.ralph/ralph-init.sh
```

This creates a `./ralph/` folder in your project with configuration files.

### Step 3: Add Your Feature Description

Open `./ralph/transcript.txt` in your text editor and replace the placeholder with your feature description or meeting notes.

**Example:**
```
We need to build a simple task manager API.

Features:
- Create tasks with a title and description
- List all tasks
- Mark tasks as complete
- Delete tasks

Technical requirements:
- Use Node.js and Express
- Store data in memory (no database for now)
- Include basic input validation
```

### Step 4: Generate the PRD

In your terminal, start Claude Code:
```bash
claude
```

Then type:
```
/prd
```

Claude will read your notes and generate a structured Product Requirements Document at `./ralph/prd.md`. Review it to make sure it captured your intent.

### Step 5: Convert to JSON

Still in Claude Code, type:
```
/ralph-convert
```

This creates `./ralph/prd.json` — the machine-readable task list that Ralph will execute.

### Step 6: Run Ralph!

Exit Claude Code (type `exit` or press Ctrl+C), then run:

```bash
~/.ralph/ralph.sh
```

**That's it!** Ralph will now work through each task autonomously. You can watch the progress in your terminal, or come back later to see the finished result.

---

## Detailed Walkthrough

Let's walk through a complete example from start to finish.

### Scenario: Building a Task Manager API

You had a meeting with your team, and someone wrote down these notes:

```
Meeting Notes - Task Manager App
================================

Alice: We need a simple API for managing tasks.

Bob: Yeah, basic CRUD - create, read, update, delete.

Alice: Each task should have a title, description, and status.

Bob: Status should be like... todo, in-progress, done?

Alice: Perfect. Let's use Node.js since that's what we know.

Bob: Should we add a database?

Alice: Not yet. Let's start with in-memory storage and add a
database later. Keep it simple.

Bob: What about tests?

Alice: Yes, we need tests. Can't ship without them.
```

### Step-by-Step Execution

#### 1. Set Up the Project

```bash
# Create project folder
mkdir task-manager-api
cd task-manager-api

# Initialize git
git init

# Initialize Ralph
~/.ralph/ralph-init.sh
```

Output:
```
╔══════════════════════════════════════════════════════════════╗
║            Ralph Init - Project Setup                        ║
╚══════════════════════════════════════════════════════════════╝

[init] Creating ./ralph directory...
[init] Creating configuration...
[init] Creating progress.txt...
[init] Creating transcript placeholder...
[init] Detecting tech stack...
[init] Could not auto-detect tech stack

════════════════════════════════════════════════════════════════
Ralph initialized for: task-manager-api
════════════════════════════════════════════════════════════════
```

#### 2. Add Meeting Notes

Open `./ralph/transcript.txt` and paste in your meeting notes (the ones above).

#### 3. Generate PRD

```bash
claude
```

Inside Claude Code:
```
/prd
```

Claude reads your transcript and creates `./ralph/prd.md`:

```markdown
# Task Manager API - Product Requirements Document

## Overview
A simple REST API for managing tasks, supporting CRUD operations
with in-memory storage.

## User Stories

### US-001: Initialize Node.js project
**Priority:** 1 (Critical)
...

### US-002: Create task data model
**Priority:** 1 (Critical)
...
```

#### 4. Review the PRD

Open `./ralph/prd.md` and review it. Make sure:
- All features are captured
- Stories are in the right order (dependencies first)
- Nothing important is missing

Edit if needed!

#### 5. Convert to JSON

In Claude Code:
```
/ralph-convert
```

This creates `./ralph/prd.json`. You'll see a summary:

```
PRD converted to JSON: ./ralph/prd.json

Project: task-manager-api
Branch: ralph/task-manager-api
Stories: 7 total (0 completed)

Story Summary:
  [P1] US-001: Initialize Node.js project
  [P1] US-002: Create task data model
  [P2] US-003: Add create task endpoint
  [P2] US-004: Add list tasks endpoint
  [P2] US-005: Add update task endpoint
  [P3] US-006: Add delete task endpoint
  [P3] US-007: Add test suite
```

#### 6. Exit Claude and Run Ralph

```bash
exit  # or Ctrl+C to leave Claude Code
~/.ralph/ralph.sh
```

Output:
```
╔══════════════════════════════════════════════════════════════╗
║          Ralph for Claude Code - Autonomous Agent Loop       ║
╚══════════════════════════════════════════════════════════════╝

[ralph] Using PRD: ./ralph/prd.json
[ralph] Initialized progress.txt
[ralph] Creating new branch: ralph/task-manager-api from main
[ralph] Stories remaining: 7

[ralph] ══════════════════════════════════════════════════════════
[ralph] ITERATION 1 / 20
[ralph] ══════════════════════════════════════════════════════════
[ralph] Running Claude iteration...
```

Ralph will now:
1. Pick the first task (US-001)
2. Implement it
3. Run quality checks
4. Commit the changes
5. Mark it complete
6. Move to the next task

This continues until all tasks are done!

#### 7. Check the Results

When Ralph finishes:
```
[ralph] ══════════════════════════════════════════════════════════
[ralph] RALPH COMPLETE - All stories implemented!
[ralph] ══════════════════════════════════════════════════════════
```

Your project now has:
- Working code in the appropriate files
- Git commits for each task
- A complete API ready to test

```bash
# See what was created
ls -la

# See the git history
git log --oneline

# Run the application (example for Node.js)
npm start
```

---

## Configuration Options

Ralph's behavior can be customized through `./ralph/ralph.config.json`.

### Full Configuration Reference

```json
{
  "project": "my-project",

  "git": {
    "strategy": "single-branch",
    "baseBranch": "main",
    "branchPrefix": "ralph/"
  },

  "quality": {
    "autoDetect": true,
    "commands": {
      "lint": null,
      "typecheck": null,
      "test": null,
      "build": null
    }
  },

  "iterations": {
    "max": 20,
    "delaySeconds": 2
  },

  "claude": {
    "model": "sonnet"
  }
}
```

### Configuration Explained

#### Project Name
```json
"project": "my-project"
```
The name of your project. Used for branch names and logging.

#### Git Settings

```json
"git": {
  "strategy": "single-branch",
  "baseBranch": "main",
  "branchPrefix": "ralph/"
}
```

- **strategy**: How Ralph handles git branches
  - `"single-branch"`: All tasks on one branch (recommended)
  - `"branch-per-story"`: Each task gets its own branch

- **baseBranch**: The branch to create the Ralph branch from (usually `main` or `master`)

- **branchPrefix**: Prefix for Ralph's branch names (e.g., `ralph/my-feature`)

#### Quality Gates

```json
"quality": {
  "autoDetect": true,
  "commands": {
    "lint": null,
    "typecheck": null,
    "test": null,
    "build": null
  }
}
```

- **autoDetect**: If `true`, Ralph will automatically detect your project type and use appropriate commands

- **commands**: Override specific commands (set to `null` for auto-detection):
  ```json
  "commands": {
    "lint": "npm run lint:fix",
    "typecheck": "npm run typecheck",
    "test": "npm test",
    "build": "npm run build"
  }
  ```

#### Iteration Settings

```json
"iterations": {
  "max": 20,
  "delaySeconds": 2
}
```

- **max**: Maximum number of iterations before Ralph stops (safety limit)
- **delaySeconds**: Pause between iterations (helps with rate limits)

#### Claude Settings

```json
"claude": {
  "model": "sonnet"
}
```

- **model**: Which Claude model to use
  - `"sonnet"`: Faster, cheaper (recommended for most tasks)
  - `"opus"`: More capable, use for complex tasks

### Tech Stack Auto-Detection

Ralph automatically detects your project type and configures quality commands:

| Project Type | Detection | Lint | Typecheck | Test | Build |
|-------------|-----------|------|-----------|------|-------|
| Node.js/TypeScript | `package.json` | `npm run lint` | `npx tsc --noEmit` | `npm test` | `npm run build` |
| Python | `pyproject.toml` | `ruff check .` | `mypy .` | `pytest` | - |
| Rust | `Cargo.toml` | `cargo clippy` | `cargo check` | `cargo test` | `cargo build` |
| Go | `go.mod` | `golangci-lint run` | `go vet ./...` | `go test ./...` | `go build ./...` |

---

## Sharing with Teammates

Ralph is designed to be easily shared. Here's how to get your teammates set up.

### Creating a Portable Package

Run this command to create a shareable file:

```bash
~/.ralph/package.sh
```

This creates `ralph-portable.tar.gz` — a single file containing everything needed.

### Teammate Installation

Send the `ralph-portable.tar.gz` file to your teammate. They should:

1. **Extract the package:**
   ```bash
   tar -xzf ralph-portable.tar.gz -C ~/
   ```

2. **Install Claude Code CLI** (if they haven't already):
   - Download from the official Anthropic website
   - Run `claude auth login` with their own account

3. **Add to PATH:**
   ```bash
   echo 'export PATH="$HOME/.ralph:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

4. **Verify:**
   ```bash
   ~/.ralph/ralph.sh --help
   ```

**Important:** Each person needs their own Claude Code credentials. Ralph doesn't store or share API keys.

### Version Control for Ralph Itself

Since Ralph is just files, you can version control it:

```bash
cd ~/.ralph
git init
git add .
git commit -m "Initial Ralph setup"
git remote add origin git@github.com:your-org/ralph-config.git
git push -u origin main
```

Now teammates can clone your organization's Ralph configuration:

```bash
git clone git@github.com:your-org/ralph-config.git ~/.ralph
```

---

## Troubleshooting

### "claude: command not found"

**Problem:** The Claude Code CLI isn't installed or isn't in your PATH.

**Solution:**
1. Install Claude Code from [the official website](https://claude.ai/download)
2. Restart your terminal
3. Try again: `claude --version`

### "Not in a git repository"

**Problem:** Ralph requires git to track changes.

**Solution:**
```bash
git init
git add .
git commit -m "Initial commit"
```

### Ralph stops after a few iterations

**Problem:** A task might be failing repeatedly.

**Solution:**
1. Check `./ralph/progress.txt` for error messages
2. Look at the last few git commits: `git log --oneline -5`
3. The task might be too large — edit `./ralph/prd.json` to split it

### "Max iterations reached"

**Problem:** Ralph hit the safety limit without completing all tasks.

**Solution:**
1. Check how many tasks remain: look at `./ralph/prd.json`
2. Increase the limit: `~/.ralph/ralph.sh 50`
3. Or investigate why tasks aren't completing (check `progress.txt`)

### Tests keep failing

**Problem:** Quality gates are blocking progress.

**Solution:**
1. Check what's failing: run the test command manually
2. The AI might have introduced a bug — review recent commits
3. You may need to fix something manually, then resume

### Context window exceeded

**Problem:** A task is too complex for a single Claude session.

**Solution:**
Split the task into smaller pieces in `./ralph/prd.json`:
- Instead of "Build user authentication"
- Use: "Create user model", "Add login endpoint", "Add registration endpoint", etc.

### How to Resume After Fixing Something

If you need to manually fix code and continue:

1. Make your fixes
2. Commit them: `git add . && git commit -m "Manual fix: description"`
3. Run Ralph again: `~/.ralph/ralph.sh`

Ralph will pick up where it left off.

---

## FAQ

### Q: How much does this cost?

Ralph uses Claude Code, which requires an Anthropic account. Check [Anthropic's pricing](https://www.anthropic.com/pricing) for current rates. Costs depend on:
- Number of tasks
- Complexity of each task
- Which model you use (Sonnet is cheaper than Opus)

### Q: Can I use this for any programming language?

Yes! Ralph is language-agnostic. It works with:
- JavaScript/TypeScript
- Python
- Rust
- Go
- Ruby
- Java
- And more...

Just make sure your quality gate commands are configured correctly.

### Q: What if I don't like what Ralph built?

You have full control:
- Review each commit with `git log` and `git diff`
- Revert changes with `git revert` or `git reset`
- Edit the PRD and run again
- Make manual changes anytime

### Q: Can I run Ralph on an existing project?

Absolutely! Just:
1. Navigate to your project
2. Run `~/.ralph/ralph-init.sh`
3. Create a PRD for the new features you want
4. Run Ralph

It will create a new branch and won't touch your main code until you merge.

### Q: How do I stop Ralph mid-run?

Press `Ctrl+C` in the terminal. Ralph will stop after the current iteration completes. Your progress is saved — you can resume later.

### Q: Is my code sent to Anthropic?

Yes, Ralph uses Claude Code, which sends your code to Anthropic's servers for processing. Review [Anthropic's privacy policy](https://www.anthropic.com/privacy) for details. Don't use Ralph with code you can't share with Anthropic.

### Q: Can multiple people run Ralph on the same repo?

Yes, but coordinate:
- Each person should use a different branch
- Or work on different features
- Merge carefully to avoid conflicts

### Q: What's the largest project Ralph can handle?

Ralph works best with focused features. For large projects:
- Break work into phases
- Create separate PRDs for each phase
- Run Ralph for each phase sequentially

---

## Contributing

We welcome contributions! Here's how to help:

### Reporting Issues

Found a bug or have a suggestion?
1. Check existing issues first
2. Open a new issue with:
   - What you expected
   - What actually happened
   - Steps to reproduce
   - Your environment (OS, Claude Code version)

### Submitting Changes

1. Fork this repository
2. Create a branch: `git checkout -b my-improvement`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Areas for Contribution

- Documentation improvements
- Support for more tech stacks
- Better error messages
- New features
- Bug fixes

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Credits

- Inspired by [Ralph](https://github.com/snarktank/ralph) by Geoffrey Huntley
- Built for [Claude Code](https://claude.ai) by Anthropic
- Created by the team at [Your Organization]

---

## Getting Help

- **Documentation**: You're reading it!
- **Issues**: [GitHub Issues](https://github.com/feelgreatfoodie/ralph-claude-code/issues)
- **Discussions**: [GitHub Discussions](https://github.com/feelgreatfoodie/ralph-claude-code/discussions)

---

Happy building! 🚀
