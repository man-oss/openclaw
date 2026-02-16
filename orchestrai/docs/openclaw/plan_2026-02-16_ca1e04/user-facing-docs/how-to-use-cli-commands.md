# How to Use CLI Commands

OpenClaw provides a comprehensive command-line interface (CLI) for managing AI agents, configuring services, and controlling the gateway. This guide covers the essential commands and patterns you'll use in daily operations.

## Getting Started with the CLI

### Basic Command Structure

All OpenClaw commands follow this pattern:

```bash
openclaw <command> [subcommand] [options]
```

Commands are organized into logical groups like `agent`, `agents`, `configure`, `gateway`, and more.

### Getting Help

Display help information for any command:

```bash
# General help
openclaw --help

# Command-specific help
openclaw agent --help
openclaw configure --help
```

Use the `--help` flag with any command to see available options and usage examples.

### Viewing Documentation

Open the documentation in your browser:

```bash
openclaw docs
```

This provides quick access to guides, tutorials, and reference materials.

## Working with Agents

### Running an Agent

Start an interactive agent session:

```bash
openclaw agent
```

This launches an agent that you can interact with directly in your terminal.

### Managing Multiple Agents

List all configured agents:

```bash
openclaw agents list
```

Add a new agent:

```bash
openclaw agents add <agent-name>
```

Remove an agent:

```bash
openclaw agents delete <agent-name>
```

View agent identity information:

```bash
openclaw agents identity <agent-name>
```

## Configuration Commands

### Initial Setup Wizard

Run the interactive setup wizard to configure OpenClaw:

```bash
openclaw configure wizard
```

The wizard guides you through:
- Provider authentication setup
- Gateway configuration
- Channel settings
- Daemon installation

### Managing Configuration

View current configuration:

```bash
openclaw config list
```

Set a configuration value:

```bash
openclaw config set <key> <value>
```

Get a specific configuration value:

```bash
openclaw config get <key>
```

### Gateway Configuration

Configure the gateway service:

```bash
openclaw configure gateway
```

Set up gateway authentication:

```bash
openclaw configure gateway-auth
```

Configure daemon settings:

```bash
openclaw configure daemon
```

Set up communication channels:

```bash
openclaw configure channels
```

## Gateway Operations

### Starting and Stopping

Start the gateway service:

```bash
openclaw gateway start
```

Stop the gateway service:

```bash
openclaw gateway stop
```

Restart the gateway:

```bash
openclaw gateway restart
```

### Monitoring Gateway Status

Check gateway status:

```bash
openclaw gateway status
```

This displays:
- Running state
- Active connections
- Service health
- Resource usage

View gateway logs:

```bash
openclaw logs gateway
```

Follow logs in real-time:

```bash
openclaw logs gateway --follow
```

## Working with Channels

### Managing Communication Channels

View channel status:

```bash
openclaw channels status
```

Add a new channel:

```bash
openclaw channels add <channel-type>
```

Remove a channel:

```bash
openclaw channels remove <channel-name>
```

### Channel Authentication

Authenticate with a channel service:

```bash
openclaw channels auth <channel-name>
```

This typically opens a browser window for OAuth authentication or prompts for API credentials.

## Model Management

### Listing Available Models

View all available AI models:

```bash
openclaw models list
```

This shows models from configured providers with details like:
- Model names
- Provider
- Capabilities
- Context limits

### Setting Default Models

Configure your preferred model:

```bash
openclaw config set model <model-name>
```

## Daemon Management

### Installing the Daemon

Install OpenClaw as a background service:

```bash
openclaw daemon install
```

This configures the system to automatically start OpenClaw services.

### Daemon Control

Start the daemon:

```bash
openclaw daemon start
```

Stop the daemon:

```bash
openclaw daemon stop
```

Check daemon status:

```bash
openclaw daemon status
```

View daemon logs:

```bash
openclaw daemon logs
```

## Memory and Knowledge Management

### Working with Agent Memory

Search agent memory:

```bash
openclaw memory search <query>
```

View memory statistics:

```bash
openclaw memory stats
```

Clear memory for an agent:

```bash
openclaw memory clear <agent-name>
```

## Diagnostic and Maintenance Commands

### Running Health Checks

Run comprehensive diagnostics:

```bash
openclaw doctor
```

This checks:
- Configuration validity
- Service connectivity
- Authentication status
- System dependencies
- Security settings

Run in automatic fix mode:

```bash
openclaw doctor --yes
```

### Viewing Logs

View application logs:

```bash
openclaw logs
```

Filter logs by level:

```bash
openclaw logs --level error
openclaw logs --level info
```

Specify a time range:

```bash
openclaw logs --since 1h
openclaw logs --since "2024-01-01"
```

### System Information

Display system information:

```bash
openclaw system info
```

Check for updates:

```bash
openclaw update check
```

## Global Options and Flags

### Common Options

These options work with most commands:

**Verbose output:**
```bash
openclaw <command> --verbose
```

**Quiet mode (minimal output):**
```bash
openclaw <command> --quiet
```

**JSON output format:**
```bash
openclaw <command> --json
```

**Configuration file path:**
```bash
openclaw <command> --config /path/to/config.json
```

**Skip confirmations:**
```bash
openclaw <command> --yes
```

### Profile Selection

Use a specific configuration profile:

```bash
openclaw <command> --profile production
```

This allows you to maintain separate configurations for different environments.

## Environment Variables

### Configuration via Environment

OpenClaw respects these environment variables:

**Configuration directory:**
```bash
export OPENCLAW_CONFIG_DIR=/path/to/config
```

**Default profile:**
```bash
export OPENCLAW_PROFILE=production
```

**Log level:**
```bash
export OPENCLAW_LOG_LEVEL=debug
```

**Disable compile cache:**
```bash
export NODE_DISABLE_COMPILE_CACHE=1
```

### Provider API Keys

Set provider credentials via environment:

```bash
export ANTHROPIC_API_KEY=your_key_here
export OPENAI_API_KEY=your_key_here
export GOOGLE_API_KEY=your_key_here
```

## Shell Completion

### Enabling Auto-Complete

Generate completion script for your shell:

**Bash:**
```bash
openclaw completion bash >> ~/.bashrc
```

**Zsh:**
```bash
openclaw completion zsh >> ~/.zshrc
```

**Fish:**
```bash
openclaw completion fish > ~/.config/fish/completions/openclaw.fish
```

After adding the completion script, restart your shell or source the configuration file.

## Common Workflows

### First-Time Setup

1. Run the configuration wizard:
   ```bash
   openclaw configure wizard
   ```

2. Verify your setup:
   ```bash
   openclaw doctor
   ```

3. Start your first agent:
   ```bash
   openclaw agent
   ```

### Daily Operations

1. Check gateway status:
   ```bash
   openclaw gateway status
   ```

2. Start an agent session:
   ```bash
   openclaw agent
   ```

3. View recent logs if needed:
   ```bash
   openclaw logs --since 1h
   ```

### Troubleshooting Issues

1. Run diagnostics:
   ```bash
   openclaw doctor
   ```

2. Check relevant logs:
   ```bash
   openclaw logs --level error
   ```

3. Verify configuration:
   ```bash
   openclaw config list
   ```

4. Restart services:
   ```bash
   openclaw gateway restart
   ```

### Switching Between Configurations

1. Create a new profile:
   ```bash
   openclaw configure wizard --profile development
   ```

2. Use the profile:
   ```bash
   openclaw agent --profile development
   ```

3. List available profiles:
   ```bash
   openclaw config list --all-profiles
   ```

## Tips and Best Practices

### Command Efficiency

- Use command aliases in your shell for frequently used commands
- Leverage tab completion to discover available options
- Use `--json` output for scripting and automation
- Combine `--yes` flag with commands in scripts to avoid prompts

### Output Formatting

Commands support different output formats:
- Default: Human-readable text with colors
- `--json`: Machine-parseable JSON output
- `--quiet`: Minimal output, errors only
- `--verbose`: Detailed operation logs

### Getting Detailed Information

Most list commands support additional detail flags:

```bash
openclaw agents list --verbose
openclaw models list --details
openclaw gateway status --full
```

### Safe Operations

For destructive operations, OpenClaw prompts for confirmation unless you use `--yes`:

```bash
# Will prompt for confirmation
openclaw agents delete my-agent

# Skips confirmation
openclaw agents delete my-agent --yes
```

## Exit Codes

OpenClaw commands return standard exit codes:

- `0`: Success
- `1`: General error
- `2`: Configuration error
- `130`: Interrupted by user (Ctrl+C)

Use these in scripts to handle errors:

```bash
if openclaw gateway status; then
    echo "Gateway is running"
else
    echo "Gateway is not running"
    openclaw gateway start
fi
```

## Getting More Help

### In-App Documentation

Access detailed help for any command:

```bash
openclaw <command> --help
```

### Online Resources

Open the documentation site:

```bash
openclaw docs
```

### Version Information

Check your OpenClaw version:

```bash
openclaw --version
```

This helps when reporting issues or checking compatibility with features.