I'll retrieve the key source files to understand how agents are configured in OpenClaw.# How to Configure Agents

OpenClaw allows you to create and manage multiple AI agents, each with its own personality, capabilities, and workspace. This guide will help you set up and customize agents for different tasks and use cases.

## Understanding Agents

An agent in OpenClaw is an AI assistant with specific characteristics that define how it behaves and what it can do. You can configure:

- Which AI model the agent uses
- What files and tools the agent has access to
- The agent's personality and working style
- Which workspace directory the agent operates in

## Creating Your First Agent

OpenClaw comes with a default agent that's ready to use immediately. When you first start OpenClaw, it creates a workspace directory at `~/.openclaw/workspace` with essential configuration files.

### Default Agent Setup

The default agent workspace includes these key files:

- **AGENTS.md** - Describes available agents and their specialties
- **SOUL.md** - Defines the agent's personality and working style
- **TOOLS.md** - Lists what tools and commands the agent can use
- **IDENTITY.md** - Sets the agent's name and character
- **USER.md** - Contains information about you for context
- **BOOTSTRAP.md** - Initial instructions shown to new agents

When you first interact with an agent, you'll see the BOOTSTRAP.md file which guides you through customizing these settings. Once you've personalized the workspace, this onboarding guide won't appear again.

## Configuring Multiple Agents

To create additional agents with different configurations, you'll need to edit your OpenClaw configuration file (typically `~/.openclaw/config.json` or `openclaw.config.json` in your project).

### Adding Agents to Configuration

Agents are defined in the `agents.list` section of your configuration. Each agent needs a unique ID and can have custom settings:

```json
{
  "agents": {
    "list": [
      {
        "id": "coding-expert",
        "name": "Code Expert",
        "default": true,
        "workspace": "~/projects/coding-workspace",
        "model": "claude-3-5-sonnet-20241022"
      },
      {
        "id": "researcher",
        "name": "Research Assistant",
        "workspace": "~/projects/research-workspace",
        "model": "gpt-4"
      }
    ]
  }
}
```

### Agent Configuration Options

**Basic Settings:**
- `id` - Unique identifier for the agent (required)
- `name` - Friendly display name
- `default` - Set to `true` to make this your default agent

**Workspace Settings:**
- `workspace` - Path to the agent's working directory where it stores files and context

**Model Configuration:**
- `model` - Specify a single AI model (e.g., `"claude-3-5-sonnet-20241022"`)
- Or use advanced model configuration:
  ```json
  "model": {
    "primary": "claude-3-5-sonnet-20241022",
    "fallbacks": ["gpt-4", "gpt-3.5-turbo"]
  }
  ```

**Agent Storage:**
- `agentDir` - Custom directory for agent-specific data (defaults to `~/.openclaw/agents/{agent-id}/agent`)

## Customizing Agent Behavior

### Setting Up Agent Workspaces

Each agent has its own workspace directory where you can customize its behavior:

1. Navigate to the agent's workspace directory
2. Edit the configuration files:
   - Modify **SOUL.md** to change how the agent communicates
   - Update **IDENTITY.md** to adjust the agent's personality
   - Edit **TOOLS.md** to control what the agent can do
   - Customize **USER.md** with context about your preferences

### Configuring Agent Skills

You can control which skills and capabilities an agent has access to by setting the `skills` property:

```json
{
  "id": "my-agent",
  "skills": ["git", "terminal", "file-operations"]
}
```

This limits the agent to only the specified skills, making it more focused on particular tasks.

### Advanced Agent Options

**Memory Search:**
Configure how the agent searches through conversation history:
```json
"memorySearch": {
  "enabled": true
}
```

**Subagents:**
Control whether an agent can spawn helper agents:
```json
"subagents": {
  "enabled": true,
  "maxDepth": 2
}
```

**Sandbox Configuration:**
Customize the agent's execution environment:
```json
"sandbox": {
  "type": "docker",
  "image": "custom-image:latest"
}
```

## Switching Between Agents

Once you've configured multiple agents, you can switch between them when starting conversations. The method depends on how you're using OpenClaw:

- In chat interfaces, look for an agent selector dropdown
- In API calls, specify the agent ID in your session key
- The agent marked with `"default": true` will be used when you don't specify one

## Managing Agent Files and Context

Each agent maintains its own:

- **Conversation history** - Stored in the agent's directory
- **Session data** - Temporary information about ongoing tasks
- **Bootstrap files** - Core configuration that defines the agent's behavior

When you switch agents, each maintains separate context, allowing you to have specialized assistants for different types of work.

## Best Practices

**Use Multiple Agents For:**
- Separating personal and work projects
- Different programming languages or frameworks
- Specialized tasks (research vs. coding vs. writing)
- Testing different AI models or configurations

**Customize Workspaces:**
- Keep each agent's workspace focused on its specialty
- Add relevant documentation to AGENTS.md for quick reference
- Update USER.md in each workspace with context specific to that agent's tasks

**Model Selection:**
- Choose faster models for simple tasks
- Use more capable models for complex reasoning
- Configure fallback models to ensure availability

## Example: Setting Up Specialized Agents

Here's a complete example showing multiple specialized agents:

```json
{
  "agents": {
    "defaults": {
      "workspace": "~/openclaw-workspace",
      "model": {
        "primary": "claude-3-5-sonnet-20241022",
        "fallbacks": ["gpt-4"]
      }
    },
    "list": [
      {
        "id": "default",
        "name": "General Assistant",
        "default": true
      },
      {
        "id": "code-reviewer",
        "name": "Code Review Expert",
        "workspace": "~/code-review-workspace",
        "model": "gpt-4",
        "skills": ["read-file", "list-directory"]
      },
      {
        "id": "python-dev",
        "name": "Python Developer",
        "workspace": "~/python-workspace",
        "skills": ["python", "git", "terminal"],
        "model": {
          "primary": "claude-3-5-sonnet-20241022",
          "fallbacks": []
        }
      }
    ]
  }
}
```

Each agent in this setup serves a specific purpose with its own workspace and capabilities, allowing you to seamlessly switch between different types of work while maintaining appropriate context and tooling for each task.