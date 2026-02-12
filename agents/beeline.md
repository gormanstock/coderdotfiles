# AI Agent Workflows for Beeline

> **Purpose:** Guidelines for using AI coding assistants effectively on the Beeline Django/Python routing application.

## Project Context

**Beeline** is a Django 1.9.2 application hosting routing optimization algorithms using Google OR-Tools constraint solver. Core functionality includes TSP (Traveling Salesman Problem), VRP (Vehicle Routing Problem), and service pattern optimization for logistics routing.

**Tech Stack:**

- Python 3.6.15 (upgrading from 3.5.10)
- Django 1.9.2
- Google OR-Tools 8.2.8710 (constraint solver)
- Celery 4.1.0 (async tasks)
- PostgreSQL database

**Critical Directories:**

- `honeyswarm/or_routing/` - Core routing algorithms (TSP, VRP, evaluators)
- `recalc/` - Route recalculation logic
- `api/` - Django REST API endpoints
- `beeline/` - Django app configuration

## Workflow Patterns

### 1. Deep Analysis Workflow (Complex Tasks)

**When to use:** Multi-step technical investigations, upgrade planning, architecture reviews

**Pattern:**

1. **Gather Context First** - Pull all relevant tickets, PRs, related issues
2. **Create Planning Document** - Make a markdown file early (e.g., `OT-XXX_ANALYSIS_AND_PLAN.md`)
3. **Progressive Enhancement** - Update the document as you discover new information
4. **Link Everything** - Connect Jira issues, GitHub PRs, related commits
5. **Historical Investigation** - Check failed attempts (look for reverted PRs, closed issues)

**Example (OT-508 Python Upgrade):**

```
1. Pull Jira issue details
2. Create OT-508_ANALYSIS_AND_PLAN.md
3. Retrieve fix PR #406 
4. Analyze diff (58 files)
5. Search codebase for OR-Tools usage
6. Find failed PR #365 for context
7. Update document with routing-specific risks
8. Add comprehensive testing plan
```

**Key Insight:** For Beeline, always check if changes affect routing algorithms - these are mission-critical.

### 2. OR-Tools Development Pattern

**When to use:** Working with routing solvers, evaluators, constraints

**Critical Knowledge:**

- **RoutingIndexManager** is required in OR-Tools 8.x+ (converts between indices and nodes)
- **Callbacks** must be registered via `RegisterTransitCallback()` or `RegisterUnaryTransitCallback()`
- **Evaluators** need the manager instance to convert indices to nodes
- **Breaking changes** happen between major versions (6.x → 8.x was massive)

**Prompting Strategy:**

```
"I need to modify the DistanceEvaluator in honeyswarm/or_routing/evaluators.py.
Context: We're using OR-Tools 8.2.8710 with RoutingIndexManager.
All callbacks receive indices and must convert to nodes using manager.IndexToNode().
Show me the change."
```

**Common Pitfalls:**

- Forgetting to convert indices to nodes in callbacks
- Using old `RoutingModel(num_locations, ...)` constructor instead of `RoutingModel(manager)`
- Not registering callbacks before using them in dimensions
- Assuming OR-Tools 6.x patterns still work

### 3. Testing Strategy for Routing Changes

**When to use:** Any change touching `honeyswarm/or_routing/*` or `recalc/*`

**Priority Levels:**

**PRIORITY 0 (BLOCKING):**

- Routing produces valid solutions
- No cycles in TSP tours (the "2x distance bug")
- VRP respects vehicle capacity constraints
- Time windows are honored
- Routes are geometrically sensible

**PRIORITY 1:**

- Unit tests pass for all evaluators
- Regression tests for known bugs pass
- Distance calculations match expected values
- Service time calculations correct

**PRIORITY 2:**

- Integration tests with real route data
- Performance benchmarks (solution time)
- Memory usage checks

**Test File Pattern:**

```python
# Always test helper methods separately
def test_distance_helper(self):
    # Test the pure calculation logic
    
def test_distance_evaluator_callback(self):
    # Test the OR-Tools callback integration
    # Verify IndexToNode conversion happens
```

### 4. Dependency Upgrade Pattern

**When to use:** Updating Python, OR-Tools, or other critical libraries

**Checklist:**

1. ✅ Check if dependency has breaking changes (read CHANGELOG)
2. ✅ Search codebase for usage patterns: `grep -r "from ortools" .`
3. ✅ Look for previous failed upgrade attempts (check closed/reverted PRs)
4. ✅ Identify affected files before making changes
5. ✅ Create comprehensive test plan BEFORE coding
6. ✅ Add regression tests for known issues
7. ✅ Document the "why" not just the "what"

**Example Prompt:**

```
"I'm upgrading OR-Tools from 6.10 to 8.2. 
First, search the codebase for all OR-Tools imports and usage.
Then check if there are any failed PRs related to OR-Tools or Python upgrades.
Create a list of affected files and breaking changes before we start."
```

### 5. PR Analysis Workflow

**When to use:** Reviewing large PRs, understanding changes

**Pattern:**

1. Get PR metadata first (files changed, line counts)
2. Get full diff for critical files only (not all 58 files)
3. Focus on files in `honeyswarm/or_routing/` first
4. Check test files for what's being validated
5. Look for comments/reviews with context

**Efficient Prompting:**

```
"Get PR #406 metadata and list of changed files.
Then show me the diff for these critical files:
- honeyswarm/or_routing/evaluators.py
- honeyswarm/or_routing/tsp.py
- requirements.txt
Skip generated files, migrations, and minor updates."
```

## Code Reading Strategies

### Finding Routing Logic

```bash
# All routing solver code
find honeyswarm/or_routing -name "*.py"

# Where TSP is actually called
grep -r "tsp.tsp(" --include="*.py"

# OR-Tools API usage
grep -r "pywrapcp\|RoutingModel\|RoutingIndexManager" --include="*.py"
```

### Understanding Evaluators

**Pattern:** Each evaluator calculates a cost/constraint for the routing solver

- **DistanceEvaluator** - Geographic distance between points
- **TwlEvaluator** - Time With Labor (drive time + service time)
- **CapacityEvaluator** - Truck capacity constraints
- **TimeEvaluator** - Time window constraints

**Key:** All evaluators now take `manager` parameter and use `manager.IndexToNode()` in callbacks.

### Tracing Route Calculations

```
1. API receives route request
2. Data is prepared in routing/data_models.py
3. VRP or TSP solver is called
4. Evaluators calculate costs for each edge
5. OR-Tools finds optimal solution
6. Solution is extracted and formatted
7. Response returned to API
```

## Common Agent Mistakes to Avoid

### ❌ Don't: Make changes without context

```
Agent: "I'll update evaluators.py to use the new API"
[Makes changes without checking if manager is available]
```

### ✅ Do: Gather context first

```
Agent: "Let me first read evaluators.py to see the current structure,
then check how manager is passed to these classes in vrp.py and tsp.py"
```

### ❌ Don't: Assume simple upgrades

```
User: "Upgrade Python to 3.6"
Agent: "I'll update the Dockerfile and requirements.txt"
```

### ✅ Do: Investigate dependencies

```
Agent: "Let me check requirements.txt for Python-version-specific packages.
I see OR-Tools 6.10 is installed via wheel for Python 3.5.
This won't work with Python 3.6 - let me search for compatible versions."
```

### ❌ Don't: Skip test coverage

```
Agent: "I've refactored the evaluators. The code looks good."
```

### ✅ Do: Verify with tests

```
Agent: "I've refactored the evaluators. Let me check what tests exist,
run them to ensure nothing broke, and add tests for the new helper methods."
```

## Project-Specific Prompts

### Starting a New Task

```
"I'm working on [TICKET]. Pull the Jira details, check for related PRs,
and create an analysis document at [TICKET]_ANALYSIS_AND_PLAN.md.
Include context, technical approach, risk assessment, and testing plan."
```

### Investigating Routing Issues

```
"A route is showing [SYMPTOM]. Check these in order:
1. Is the distance evaluator producing correct values?
2. Are callbacks registered correctly with OR-Tools?
3. Is IndexToNode conversion happening in callbacks?
4. Are there any cycles in the tour array?
5. Check test coverage for this scenario."
```

### Adding New Routing Features

```
"I need to add [CONSTRAINT] to the routing solver.
1. Show me similar constraints in existing evaluators
2. Explain how to register this with OR-Tools 8.2
3. Create the evaluator class following existing patterns
4. Write unit tests for the new constraint
5. Show how to integrate with VRP solver"
```

## Success Metrics

**Good AI Session:**

- Created actionable documentation
- Identified risks before coding
- Found related work (previous PRs, issues)
- Comprehensive test coverage plan
- Clear understanding of "why" not just "what"

**Great AI Session:**

- Discovered hidden complexity early
- Found previous failed attempts and learned from them
- Created reusable patterns for future work
- Left the codebase more maintainable
- Documented decisions for future developers

## Version History

- **2026-02-06**: Initial version based on OT-508 (Python 3.6 upgrade) analysis workflow
- **Maintainer**: Update this file as new patterns emerge
