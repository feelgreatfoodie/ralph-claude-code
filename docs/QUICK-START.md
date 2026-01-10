# Quick Start Guide

Get Ralph up and running in 5 minutes.

---

## Prerequisites Checklist

Before starting, make sure you have:

- [ ] **Git** installed (`git --version`)
- [ ] **Claude Code CLI** installed (`claude --version`)
- [ ] **Claude Code authenticated** (`claude auth login`)

Don't have these? See the [main README](../README.md#prerequisites) for installation instructions.

---

## Step 1: Install Ralph

Run this command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/feelgreatfoodie/ralph-claude-code/main/install.sh | bash
```

Then add Ralph to your PATH:

```bash
echo 'export PATH="$HOME/.ralph:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## Step 2: Create a Project

```bash
mkdir my-app
cd my-app
git init
```

---

## Step 3: Initialize Ralph

```bash
~/.ralph/ralph-init.sh
```

---

## Step 4: Describe What You Want to Build

Open `./ralph/transcript.txt` and write what you want:

```
Build a REST API for a todo list application.

Features:
- Create todos with title and description
- List all todos
- Mark todos as complete
- Delete todos

Use Node.js and Express.
Store data in memory.
Include input validation.
```

---

## Step 5: Generate PRD

```bash
claude
```

Inside Claude, type:
```
/prd
```

Review `./ralph/prd.md`. Edit if needed.

---

## Step 6: Convert to JSON

Still in Claude:
```
/ralph-convert
```

---

## Step 7: Run Ralph!

Exit Claude (Ctrl+C or type `exit`), then:

```bash
~/.ralph/ralph.sh
```

**That's it!** Ralph will now build your application autonomously.

---

## What Happens Next

Ralph will:
1. Create a git branch for your feature
2. Work through each task one by one
3. Run quality checks after each task
4. Commit working code
5. Continue until everything is done

Watch the terminal to see progress, or come back later!

---

## Quick Commands Reference

| Command | What it does |
|---------|--------------|
| `~/.ralph/ralph-init.sh` | Initialize Ralph in current project |
| `claude` then `/prd` | Generate PRD from notes |
| `claude` then `/ralph-convert` | Convert PRD to JSON |
| `~/.ralph/ralph.sh` | Run autonomous implementation |
| `~/.ralph/ralph.sh 30` | Run with custom iteration limit |

---

## Next Steps

- Read the [full README](../README.md) for detailed documentation
- Check [Configuration Options](../README.md#configuration-options) to customize Ralph
- See [Troubleshooting](TROUBLESHOOTING.md) if you run into issues
