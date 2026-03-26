---
applyTo: "**"
---
# Performance Optimization

## Model Selection Strategy

**gpt-4o-mini** (fast, cost-efficient):
- Lightweight agents with frequent invocation
- Documentation generation
- Worker agents in multi-agent systems

**gpt-4o** (best all-round):
- Main development work
- Orchestrating multi-agent workflows
- Complex coding tasks

**claude-3.5-sonnet** (deep reasoning):
- Complex architectural decisions
- Maximum reasoning requirements
- Research and analysis tasks

## Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## Plan Mode

For complex tasks requiring deep reasoning:
1. Enable **Plan Mode** for structured approach
2. Use multiple critique rounds for thorough analysis
3. Use split role sub-agents for diverse perspectives

## Build Troubleshooting

If build fails:
1. Analyze error messages
2. Fix incrementally
3. Verify after each fix
