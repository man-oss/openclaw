# How to Use the Onboarding Wizard

The onboarding wizard provides a guided, step-by-step setup experience for OpenClaw. It configures the Gateway, workspace, channels, and authentication in one streamlined process.

## Starting the Wizard

### First-Time Setup

Run the wizard with daemon installation:

```bash
openclaw onboard --install-daemon
```

This command:
- Launches the interactive setup wizard
- Installs the Gateway as a system service (launchd on macOS, systemd on Linux)
- Ensures the Gateway starts automatically on system boot

### Manual Wizard Start

If you already have OpenClaw installed and want to reconfigure:

```bash
openclaw onboard
```

### Skip Daemon Installation

To run the wizard without installing the daemon service:

```bash
openclaw onboard --no-daemon
```

## Wizard Walkthrough

The wizard guides you through several configuration steps in sequence. Each step validates your input before proceeding.

### Step 1: Gateway Configuration

**What it does:** Sets up the Gateway control plane that manages all channels and sessions.

**You'll configure:**
- Gateway bind address (default: `127.0.0.1` for local-only access)
- Gateway port (default: `18789`)
- Authentication mode (token or password)
- Whether to enable Tailscale Serve/Funnel for remote access

**Example interaction:**
```
Gateway bind address? [127.0.0.1]
Gateway port? [18789]
Enable authentication? [yes]
Authentication mode? (token/password) [token]
```

**What happens:**
- The wizard creates or updates `~/.openclaw/openclaw.json` with your Gateway settings
- If you enabled daemon installation, it configures the system service

### Step 2: Model Provider Selection

**What it does:** Configures your AI model provider and authentication.

**Supported providers:**
- Anthropic (Claude models - recommended)
- OpenAI (GPT models)
- OpenRouter
- HuggingFace
- Custom API providers
- Local models (vLLM, Ollama)

**You'll configure:**
- Which provider to use
- API key or OAuth authentication
- Default model selection
- Optional: model failover configuration

**Example interaction:**
```
Select your AI provider:
1. Anthropic (Claude)
2. OpenAI (GPT)
3. OpenRouter
4. Other
Choice? [1]

Enter your Anthropic API key: [hidden input]
Select default model:
1. claude-opus-4-6 (recommended)
2. claude-sonnet-4
3. claude-haiku-4
Choice? [1]
```

**What happens:**
- API credentials are stored securely in `~/.openclaw/credentials`
- Model configuration is written to your config file
- The wizard tests the connection to verify credentials

### Step 3: Workspace Setup

**What it does:** Creates your agent workspace directory and initializes core prompt files.

**You'll configure:**
- Workspace location (default: `~/.openclaw/workspace`)
- Whether to use default agent prompts or customize them
- Skills directory setup

**Example interaction:**
```
Workspace directory? [~/.openclaw/workspace]
Initialize with default agent prompts? [yes]
Enable ClawHub skill registry? [yes]
```

**What happens:**
- Creates the workspace directory structure
- Generates `AGENTS.md`, `SOUL.md`, and `TOOLS.md` prompt files
- Sets up the `skills/` subdirectory for skill management
- Configures skill allowlists if you opted in

### Step 4: Channel Configuration

**What it does:** Sets up messaging channels where you'll interact with your assistant.

**Available channels:**
- WhatsApp (via Baileys)
- Telegram (bot-based)
- Slack
- Discord
- Google Chat
- Signal
- iMessage (BlueBubbles recommended, legacy imsg supported)
- Microsoft Teams
- Matrix (extension)
- WebChat (built-in web interface)

**For each channel you enable, you'll configure:**
- Authentication credentials (bot tokens, API keys)
- Access controls (who can send messages)
- Group policies (mention requirements, activation modes)
- Channel-specific settings

**Example WhatsApp setup:**
```
Enable WhatsApp? [yes]
WhatsApp will require device pairing.
Allowed phone numbers (comma-separated):
+1234567890

Enable group support? [yes]
Require mentions in groups? [yes]
```

**Example Telegram setup:**
```
Enable Telegram? [yes]
Telegram bot token: 123456:ABC-DEF...
Enable webhook mode? [no]
Allowed usernames (comma-separated, or * for all):
@yourusername
```

**What happens:**
- Channel credentials are stored in `~/.openclaw/credentials`
- Channel configuration is written to your config file
- For WhatsApp, prepares for QR code pairing on first launch
- For bot-based channels, validates tokens immediately

### Step 5: Security & Access Controls

**What it does:** Configures security policies for your assistant.

**You'll configure:**
- DM (direct message) policy: `pairing` (default, requires approval) or `open` (accepts all)
- Elevated bash permissions (for `system.run` commands)
- Sandbox mode for group/channel sessions
- Per-agent tool allowlists and denylists

**Example interaction:**
```
DM policy for unknown senders?
1. Pairing required (secure - recommended)
2. Open (accept all messages)
Choice? [1]

Enable sandboxing for non-main sessions? [yes]
This runs group/channel commands in Docker containers.

Allow elevated bash commands? [no]
Warning: Only enable for trusted users.
```

**What happens:**
- Sets `dmPolicy: "pairing"` (or `"open"`) for applicable channels
- Configures `agents.defaults.sandbox.mode: "non-main"` if you enabled sandboxing
- Updates tool allowlists in your config

### Step 6: Completion & Next Steps

**What it does:** Finalizes configuration and starts the Gateway.

**The wizard will:**
- Save all configuration to `~/.openclaw/openclaw.json`
- Start the Gateway daemon (if you installed it)
- Display next steps for channel pairing
- Show the dashboard URL

**Example output:**
```
✓ Configuration saved to ~/.openclaw/openclaw.json
✓ Gateway daemon installed and started

Next steps:
1. WhatsApp: Run 'openclaw channels login' to pair your device
2. Dashboard: http://127.0.0.1:18789
3. WebChat: http://127.0.0.1:18789/webchat

Run 'openclaw doctor' to verify your setup.
```

## Customizing Wizard Behavior

### Non-Interactive Mode

Run the wizard with pre-configured values:

```bash
openclaw onboard --yes
```

This accepts all default values without prompting. Useful for scripted installations.

### Specify Individual Options

Override specific settings via CLI flags:

```bash
openclaw onboard \
  --port 19000 \
  --model anthropic/claude-opus-4-6 \
  --no-daemon
```

### Configuration File Pre-Seeding

Create `~/.openclaw/openclaw.json` before running the wizard with your preferred defaults. The wizard will detect existing settings and offer to preserve or update them.

## Skipping or Repeating Steps

### Skip Specific Sections

The wizard detects existing configuration and offers to skip completed sections:

```
Existing Gateway configuration found.
Keep current settings? [yes]
```

Answer `no` to reconfigure that section.

### Re-run Individual Configuration

After completing the wizard, reconfigure specific areas:

**Gateway only:**
```bash
openclaw configure gateway
```

**Channels only:**
```bash
openclaw configure channels
```

**Re-run full wizard:**
```bash
openclaw onboard
```

The wizard preserves existing settings by default unless you choose to overwrite them.

### Skip Channel Pairing

If you want to configure channels later:

1. Complete the wizard without enabling channels
2. Manually add channel configuration to `~/.openclaw/openclaw.json`
3. Run `openclaw channels login` when ready to pair

## Troubleshooting

### Wizard Fails to Start

**Problem:** `openclaw: command not found`

**Solution:** Ensure OpenClaw is installed globally:
```bash
npm install -g openclaw@latest
# or
pnpm add -g openclaw@latest
```

**Problem:** Permission errors during daemon installation

**Solution (macOS):**
```bash
# The wizard needs to write to ~/Library/LaunchAgents
# Ensure you have write permissions
ls -la ~/Library/LaunchAgents
```

**Solution (Linux):**
```bash
# The wizard needs to write to ~/.config/systemd/user
mkdir -p ~/.config/systemd/user
```

### Configuration Not Saved

**Problem:** Wizard completes but configuration doesn't persist

**Solution:** Check file permissions on `~/.openclaw/`:
```bash
ls -la ~/.openclaw/
# Ensure openclaw.json is writable
chmod 600 ~/.openclaw/openclaw.json
```

**Problem:** Changes revert after wizard completion

**Solution:** Verify no other process is writing to the config file. Stop the Gateway before re-running the wizard:
```bash
openclaw gateway stop
openclaw onboard
```

### Channel Authentication Fails

**Problem:** Invalid token errors during Telegram/Discord setup

**Solution:**
- Verify the token is correct (no extra spaces or characters)
- For Telegram: Ensure the bot token format is `123456:ABC-DEF...`
- For Discord: Use the bot token, not the client secret
- Test the token manually via the provider's API before entering it

**Problem:** WhatsApp pairing times out

**Solution:**
- Complete the wizard first, then run pairing separately:
  ```bash
  openclaw channels login
  ```
- Ensure your phone is connected to the internet during QR code scanning
- Try restarting the Gateway if the QR code doesn't appear

### Model Provider Connection Issues

**Problem:** "Failed to connect to provider" during wizard

**Solution:**
- Verify your API key is valid and active
- Check your internet connection
- For Anthropic/OpenAI: Ensure you have API credits available
- Test the API key manually:
  ```bash
  curl https://api.anthropic.com/v1/messages \
    -H "x-api-key: YOUR_KEY" \
    -H "anthropic-version: 2024-10-22" \
    -H "content-type: application/json" \
    -d '{"model":"claude-opus-4-6","max_tokens":10,"messages":[{"role":"user","content":"test"}]}'
  ```

**Problem:** Model selection shows no available models

**Solution:** The wizard couldn't fetch the model list. Manually specify your model:
```bash
openclaw onboard --model anthropic/claude-opus-4-6
```

### Daemon Installation Problems

**Problem:** Daemon fails to start after installation (macOS)

**Solution:**
```bash
# Check launchd service status
launchctl list | grep openclaw

# View logs
tail -f ~/Library/Logs/openclaw-gateway.log

# Manually load the service
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

**Problem:** Daemon fails to start after installation (Linux)

**Solution:**
```bash
# Check systemd status
systemctl --user status openclaw-gateway

# View logs
journalctl --user -u openclaw-gateway -f

# Manually start the service
systemctl --user start openclaw-gateway
```

### Wizard Hangs or Freezes

**Problem:** Wizard stops responding during a step

**Solution:**
- Press `Ctrl+C` to cancel the wizard
- Review `~/.openclaw/openclaw.json` to see what was partially configured
- Delete the config file to start fresh, or manually fix the incomplete section
- Re-run the wizard

**Problem:** Wizard loops on a specific question

**Solution:**
- This indicates invalid input. Read the prompt carefully for format requirements
- For credentials: Ensure no hidden characters (copy-paste issues)
- For paths: Use absolute paths or ensure relative paths are valid
- For lists: Follow the format specified (e.g., comma-separated values)

### Verification After Setup

After completing the wizard, verify your configuration:

```bash
# Run health checks
openclaw doctor

# Verify Gateway is running
openclaw gateway status

# Test a simple message
openclaw agent --message "Hello" --dry-run

# Check channel status (for configured channels)
openclaw channels status
```

The `openclaw doctor` command provides detailed diagnostics and suggests fixes for common issues.

## Advanced Configuration

After completing the wizard, you can manually edit `~/.openclaw/openclaw.json` for advanced settings not covered by the wizard:

- **Gateway bind to network interfaces:** Change `gateway.bind` from `"loopback"` to `"0.0.0.0"` (with proper authentication)
- **Custom workspace prompts:** Edit `AGENTS.md`, `SOUL.md`, and `TOOLS.md` in your workspace
- **Per-agent configuration:** Add multiple agent profiles under `agents`
- **Advanced routing:** Configure `routing` rules for channel-to-agent mapping
- **Tool restrictions:** Fine-tune `sandbox.allow` and `sandbox.deny` lists

Refer to the full configuration reference for all available options: https://docs.openclaw.ai/gateway/configuration

## Next Steps After Onboarding

1. **Pair messaging channels:** Run `openclaw channels login` for WhatsApp/Signal
2. **Access the dashboard:** Open the URL shown at wizard completion (default: http://127.0.0.1:18789)
3. **Send your first message:** Use WebChat or send a message from a configured channel
4. **Explore skills:** Visit ClawHub (if enabled) to discover available skills
5. **Review security:** Run `openclaw doctor` to verify your security posture
6. **Read the docs:** Visit https://docs.openclaw.ai for in-depth guides

The onboarding wizard gets you from zero to a working assistant in minutes, with sensible defaults for security and functionality. All settings can be adjusted later as your needs evolve.