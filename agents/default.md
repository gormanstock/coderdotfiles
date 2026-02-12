# AI Agent Workflows - Default

> **Purpose:** General guidelines for using AI coding assistants effectively across different projects.

## General Workflow Patterns

### 1. Context Gathering First

**Always start with understanding:**

- **Project structure** - Read README files, explore directory layout
- **Tech stack** - Identify languages, frameworks, build tools
- **Existing patterns** - Look at how similar features are implemented
- **Dependencies** - Check package.json, requirements.txt, etc.
- **Documentation** - Find and read project-specific docs

### 2. Incremental Development

**Make small, focused changes:**

- Start with the smallest possible change that adds value 
- Test each change before proceeding
- Use existing code patterns and conventions
- Don't refactor and add features simultaneously

### 3. Testing Strategy

**Verify your changes:**

- Run existing tests to ensure nothing breaks
- Add tests for new functionality when possible
- Check for compilation/syntax errors
- Test the actual functionality manually when appropriate

## Common Patterns

### Starting a New Task

```
"I need to [TASK DESCRIPTION].
First, let me understand the project structure and find similar existing implementations.
Then show me the relevant files and explain the current approach before making changes."
```

### Investigating Issues

```
"There's an issue with [SYMPTOM]. 
Let me:
1. Find the relevant code areas
2. Check recent changes that might be related
3. Look for similar issues in the commit history
4. Verify my understanding before proposing fixes"
```

### Adding New Features

```
"I need to add [FEATURE].
1. Show me how similar features are implemented
2. Identify the files I need to modify
3. Explain the current architecture patterns
4. Create the implementation following existing conventions"
```

## Best Practices

### ✅ Do:

- **Read before writing** - Understand existing code first
- **Follow conventions** - Match existing naming, structure, patterns
- **Ask for clarification** - When requirements are unclear
- **Test incrementally** - Verify each step works
- **Document decisions** - Explain why, not just what

### ❌ Avoid:

- **Making assumptions** - Always verify your understanding
- **Large rewrites** - Prefer incremental improvements
- **Ignoring existing patterns** - Follow the established style
- **Skipping tests** - Always verify your changes work
- **Working in isolation** - Consider impact on other components

## Project-Specific Notes

*This is a default configuration. For workspace-specific guidelines:*

- Create a `[workspace-name].md` file in the agents directory
- Include project-specific tech stack, patterns, and workflows
- Add common commands, file locations, and gotchas
- Document testing procedures and deployment steps

**Available workspace configurations:**
- `beeline.md` - Django/Python routing application with OR-Tools
- `cetus.md` - (Create for your cetus project)
- `platform.md` - (Create for your platform project)

## Getting Help

**Command to refresh agent configs:**
```bash
reload-agents
```

**Agent config location:**
```
~/.config/agents/[workspace-name].md
```

---

*Update this default configuration as you discover patterns that work well across multiple projects.*
