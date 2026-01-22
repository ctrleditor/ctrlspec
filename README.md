# Portolan

_Chart your codebase for AI coding assistants_

Portolan provides documentation templates that give AI tools (Claude Code, Cursor) the context they need to understand your project. Named after medieval navigation charts that guided sailors through uncharted waters, Portolan helps AI navigate your codebase.

## Quick Start

```bash
# One-line installation
curl -fsSL https://raw.githubusercontent.com/oheriko/portolan/main/install.sh | sh
```

That's it! The script downloads templates, creates symlinks, and sets up MCP configuration.

## What You Get

- 🗺️ **docs/llm.md** - Guide for AI assistants
- 📋 **docs/requirements.md** - Business requirements
- 🏗️ **docs/architecture.md** - Technical design
- ⚠️ **docs/constraints.md** - Hard limitations
- 💡 **docs/decisions.md** - Decision log index
- 🧪 **docs/testing.md** - Testing strategy
- 🚀 **docs/deployment.md** - Deployment guide
- 🔗 **Symlinks** - Automatic setup for Claude, Cursor
- 🔌 **MCP Config** - Ready for Atlassian, Fathom AI integrations

## Philosophy

AI coding assistants work best with context. Portolan provides:
- **Business context** (why we're building this)
- **Technical context** (how it's built)
- **Constraints** (what we can't do)
- **Decisions** (why we made certain choices)

Like the medieval portolan charts that evolved through communal knowledge sharing, your documentation becomes a living map that guides AI through your codebase.

## MCP Integration

Portolan includes configuration for MCP servers to auto-populate your docs:
- **Atlassian MCP** - Pull requirements from Jira/Confluence
- **Fathom AI MCP** - Search meeting transcripts and extract decisions

See `.mcp.json` for configuration details.

## Structure

```
your-project/
├── .mcp.json              # MCP server configuration
├── README.md              # Project overview
├── CHANGELOG.md           # Version history
├── CLAUDE.md -> docs/llm.md
├── AGENTS.md -> docs/llm.md
├── .cursorrules -> docs/llm.md
├── .cursor/
│   ├── rules -> ../docs/llm.md
│   └── mcp.json -> ../.mcp.json
├── .config/
│   └── claude/
│       └── mcp_config.json -> ../../.mcp.json
└── docs/
    ├── llm.md
    ├── requirements.md
    ├── architecture.md
    ├── constraints.md
    ├── decisions.md
    ├── testing.md
    └── deployment.md
```

## Contributing

See [docs/llm.md](docs/llm.md) for development guidelines and conventions.

## License

MIT
