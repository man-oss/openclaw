# Your First AI Conversation - Quick Start

Get OpenClaw running and experience your first AI conversation in under 15 minutes. This guide walks you through the onboarding wizard that sets up everything you need.

## What You'll Accomplish

By the end of this guide, you'll have:
- A running AI assistant that responds to your messages
- Your preferred messaging app connected (WhatsApp, Telegram, Slack, or others)
- Authentication configured with Anthropic or OpenAI
- Your first successful conversation with the AI

## Prerequisites

- **Node.js 22 or later** installed on your system
- **macOS, Linux, or Windows** (Windows requires WSL2)
- A messaging account you want to connect (WhatsApp, Telegram, Slack, Discord, etc.)
- An Anthropic or OpenAI account for AI capabilities

## Step 1: Start the Onboarding Wizard

The onboarding wizard guides you through every step of setup. Open your terminal and run:

```bash
npx openclaw@latest onboard
```

If you prefer to install OpenClaw globally first:

```bash
npm install -g openclaw@latest
openclaw onboard
```

The wizard will welcome you and explain each step as you go.

## Step 2: Configure the Gateway

The gateway is the control center that coordinates everything. The wizard will ask you to configure:

### Choose Your Gateway Port

You'll be asked which port the gateway should use. The default is **18789**. Unless you have a specific reason to change it, press Enter to accept the default.

### Set Up Gateway Security

For local use, you can start without authentication. The wizard offers three options:

- **No authentication** (for local testing only)
- **Token-based** (generates a secure token automatically)
- **Password-based** (you create a password)

For your first setup, choosing "no authentication" makes it easier to get started quickly. You can add security later.

### Install the Background Service (Optional)

The wizard asks if you want to install OpenClaw as a background service that starts automatically. This is recommended so the gateway stays running even when you close your terminal.

Say **yes** when prompted, and the wizard will set up the service for your system (launchd on macOS, systemd on Linux).

## Step 3: Configure Your Workspace

The workspace is where OpenClaw stores your assistant's personality, tools, and conversation history.

### Choose Your Workspace Location

The wizard suggests `~/.openclaw/workspace` as the default location. This keeps everything organized in your home directory. Press Enter to accept, or specify a different path if you prefer.

### Initialize Workspace Files

The wizard creates several files that define your assistant:

- **AGENTS.md**: Defines your assistant's capabilities and behavior
- **SOUL.md**: Sets your assistant's personality and communication style
- **TOOLS.md**: Lists available tools and how to use them

These files are created with sensible defaults, so you don't need to edit them to get started.

## Step 4: Connect a Messaging Channel

Now you'll connect your first messaging app so you can talk to your assistant.

### Select Your Preferred Channel

The wizard presents a list of supported messaging platforms:

- WhatsApp (via Baileys)
- Telegram
- Slack
- Discord
- Google Chat
- Signal
- iMessage (via BlueBubbles)
- Microsoft Teams
- And more

Use your arrow keys to highlight your choice and press Enter.

### Follow Platform-Specific Setup

Each platform has slightly different setup steps:

#### For WhatsApp:
1. The wizard starts the pairing process
2. A QR code appears in your terminal
3. Open WhatsApp on your phone
4. Go to Settings > Linked Devices > Link a Device
5. Scan the QR code displayed in your terminal
6. Wait for "Connection successful" message

#### For Telegram:
1. You'll need a bot token from BotFather
2. Open Telegram and message @BotFather
3. Send `/newbot` and follow the prompts
4. Copy the token BotFather gives you
5. Paste the token when the wizard asks for it

#### For Slack:
1. You'll need to create a Slack app first
2. The wizard provides a link to Slack's app creation page
3. Create an app and enable Socket Mode
4. Copy your Bot Token and App Token
5. Paste them when the wizard prompts you

#### For Other Channels:
The wizard provides specific instructions for each platform, including any tokens, webhooks, or configuration you need.

## Step 5: Authenticate with an AI Provider

Your assistant needs access to an AI model to generate responses. OpenClaw supports Anthropic (Claude) and OpenAI (GPT).

### Choose Your Provider

The wizard asks which AI provider you want to use:

- **Anthropic** (Recommended - Claude Opus 4 works exceptionally well)
- **OpenAI** (GPT-4 and GPT-5 models)

### Complete Authentication

#### Using OAuth (Recommended):
1. The wizard opens your web browser automatically
2. Sign in to your Anthropic or OpenAI account
3. Authorize OpenClaw to use your subscription
4. The wizard confirms when authentication succeeds

#### Using API Keys (Alternative):
1. Choose "API key" when prompted
2. Visit your provider's API keys page:
   - Anthropic: https://console.anthropic.com/settings/keys
   - OpenAI: https://platform.openai.com/api-keys
3. Generate a new API key
4. Paste the key when the wizard asks for it
5. The key is stored securely in `~/.openclaw/credentials`

### Select Your Default Model

After authentication, the wizard shows available models from your provider:

- **Anthropic**: claude-opus-4-6, claude-sonnet-3-5, etc.
- **OpenAI**: gpt-4o, gpt-5.2, o1, etc.

Choose your preferred model using the arrow keys. You can always change this later.

## Step 6: Complete Setup and Start the Gateway

The wizard confirms your configuration and offers to start the gateway immediately.

### Review Your Configuration

The wizard displays a summary:
- Gateway settings (port, authentication)
- Workspace location
- Connected messaging channels
- AI provider and model

### Start the Gateway

When you confirm, the wizard:
1. Saves all configuration to `~/.openclaw/openclaw.json`
2. Starts the gateway service
3. Connects your messaging channels
4. Confirms everything is running

You'll see messages like:
```
✓ Gateway started on port 18789
✓ WhatsApp connected
✓ Anthropic authentication verified
✓ Ready to receive messages
```

## Step 7: Send Your First Message

Now for the exciting part—having your first conversation!

### Send a Message Through Your Connected Channel

Open the messaging app you connected:

- **WhatsApp**: Send a message to your linked device number
- **Telegram**: Message your bot directly
- **Slack**: Message your bot in any channel where it's invited
- **Discord**: Message your bot or mention it in a channel

### Example First Messages

Try something simple to verify everything works:

```
Hello! Can you introduce yourself?
```

```
What can you help me with?
```

```
Tell me a joke
```

### Watch Your Assistant Respond

Within seconds, you should see:
1. A typing indicator (if your messaging platform supports it)
2. A complete, thoughtful response from your assistant
3. Natural, conversational language

The response should feel like talking to a knowledgeable, helpful person rather than a robot.

## Step 8: Try More Capabilities

Once your first message works, explore what your assistant can do:

### Ask Questions

```
What's the weather like today in San Francisco?
```

```
Explain quantum computing in simple terms
```

### Request Tasks

```
Help me brainstorm names for a coffee shop
```

```
Write a professional email requesting a meeting
```

### Use Tools

If you configured the browser tool during setup:

```
Search for the latest news about AI
```

```
Look up the definition of 'epistemology'
```

## What You've Learned

Congratulations! You've successfully:

- ✅ Installed OpenClaw and ran the onboarding wizard
- ✅ Configured the gateway control center
- ✅ Set up your workspace
- ✅ Connected your first messaging channel
- ✅ Authenticated with an AI provider
- ✅ Had your first successful AI conversation

## Next Steps

### Add More Channels

Run the wizard again to connect additional messaging apps:

```bash
openclaw onboard
```

Select "Add another channel" when prompted.

### Customize Your Assistant

Edit the workspace files to change your assistant's personality:

```bash
# Open your workspace
cd ~/.openclaw/workspace

# Edit the personality file
nano SOUL.md
```

### Access the Dashboard

View your assistant's status and activity in the web dashboard:

```bash
openclaw dashboard
```

Then open http://localhost:18789 in your browser.

### Explore Advanced Features

- **Voice conversations** using Voice Wake and Talk Mode
- **Visual workspace** with the Canvas feature
- **Automation** through cron jobs and webhooks
- **Multiple assistants** with isolated workspaces

### Check System Health

Run a diagnostic to ensure everything is configured correctly:

```bash
openclaw doctor
```

This command checks your configuration, connections, and suggests improvements.

## Troubleshooting

### Gateway Won't Start

If you see "Port already in use":
1. Check if OpenClaw is already running: `openclaw status`
2. Stop existing instance: `openclaw stop`
3. Try starting again: `openclaw gateway`

### Messages Not Reaching the Assistant

If your messages aren't getting responses:

1. Verify the gateway is running: `openclaw status`
2. Check your channel connection: `openclaw channels status`
3. Review logs for errors: `openclaw logs`

### Authentication Failed

If AI provider authentication fails:

1. Verify your internet connection
2. Check your subscription status on the provider's website
3. Try re-authenticating: `openclaw auth` and select your provider

### QR Code Not Appearing (WhatsApp)

If the WhatsApp QR code doesn't display:

1. Make sure your terminal supports unicode characters
2. Try resizing your terminal window
3. Use the alternative login method when prompted

## Getting Help

If you encounter issues:

- **Documentation**: Visit https://docs.openclaw.ai
- **Community**: Join the Discord at https://discord.gg/clawd
- **Diagnostics**: Run `openclaw doctor` for automated troubleshooting
- **GitHub**: Report issues at https://github.com/openclaw/openclaw

## Summary

You've completed your first AI conversation setup! The onboarding wizard handled:
- Gateway installation and configuration
- Workspace initialization
- Channel connection and authentication
- AI provider setup
- Your first successful message exchange

Your assistant is now ready for conversations across your connected messaging platforms, with the flexibility to add more channels, customize behavior, and explore advanced features as you become more comfortable with the system.