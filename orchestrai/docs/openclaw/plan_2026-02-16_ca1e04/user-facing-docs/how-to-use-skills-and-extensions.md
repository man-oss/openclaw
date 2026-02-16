# How to Use Skills and Extensions

OpenClaw is built around a powerful extensibility system that allows you to add new capabilities through skills and extensions. This guide will help you discover, install, and manage these add-ons to customize OpenClaw for your needs.

## Understanding Skills vs Extensions

OpenClaw provides two types of add-ons that extend its capabilities:

**Skills** are individual tools and capabilities that OpenClaw can use to perform tasks. Think of them as specific abilities—like checking the weather, managing your notes, controlling smart home devices, or generating images. When you ask OpenClaw to do something, it uses the appropriate skills to help you.

**Extensions** are larger integrations that enable OpenClaw to work with different communication platforms and services. Extensions allow OpenClaw to connect to messaging apps like Discord, Slack, or Telegram, or add authentication methods for AI services. They provide the infrastructure for OpenClaw to interact with the outside world.

## Available Skills

OpenClaw comes with over 50 built-in skills covering various categories:

### Productivity & Note-Taking
- **Apple Notes** - Manage notes in Apple's Notes app
- **Apple Reminders** - Create and manage reminders
- **Bear Notes** - Work with Bear note-taking app
- **Notion** - Integrate with Notion workspace
- **Obsidian** - Manage Obsidian vault notes
- **Trello** - Organize tasks and boards

### Communication
- **iMessage** - Send messages through iMessage
- **BlueBubbles** - Alternative iMessage integration
- **Discord** - Send Discord messages
- **Slack** - Communicate via Slack

### Smart Home & Hardware
- **OpenHue** - Control Philips Hue lights
- **Camsnap** - Take webcam snapshots
- **Peekaboo** - Monitor camera feeds

### Media & Entertainment
- **Spotify Player** - Control Spotify playback
- **Sonos CLI** - Manage Sonos speakers
- **SongSee** - Identify and explore music

### Development & Technical
- **GitHub** - Interact with GitHub repositories
- **Coding Agent** - Assist with programming tasks
- **Tmux** - Manage terminal sessions

### AI & Content Generation
- **Gemini** - Access Google's Gemini AI
- **OpenAI Image Generation** - Create images with DALL-E
- **OpenAI Whisper** - Transcribe audio to text
- **Summarize** - Generate content summaries

### Utilities
- **Weather** - Check weather forecasts
- **1Password** - Access password manager
- **Canvas** - Work with visual canvases
- **GifGrep** - Search and find GIFs

## Available Extensions

OpenClaw includes numerous extensions for platform integration:

### Messaging Platforms
- **Telegram** - Connect to Telegram bots
- **Discord** - Run OpenClaw as a Discord bot
- **Slack** - Deploy as a Slack bot
- **WhatsApp** - Integrate with WhatsApp messaging
- **Signal** - Connect to Signal messenger
- **Matrix** - Join Matrix chat networks

### Communication Services
- **Google Chat** - Integrate with Google Chat
- **Microsoft Teams** - Connect to Teams
- **Mattermost** - Join Mattermost servers
- **IRC** - Access IRC networks
- **Twitch** - Interact in Twitch chat

### Device & Network
- **Device Pair** - Connect multiple OpenClaw instances
- **Voice Call** - Enable voice calling features
- **Phone Control** - Manage phone functionality

### AI Authentication
- **Google Gemini CLI Auth** - Authenticate with Gemini
- **Google Antigravity Auth** - Alternative Google auth
- **Qwen Portal Auth** - Access Qwen AI models
- **Minimax Portal Auth** - Connect to Minimax services

### Memory & Data
- **Memory Core** - Enhanced memory capabilities
- **Memory LanceDB** - Vector database for memories

## Finding Available Skills and Extensions

You can browse available skills and extensions in several ways:

1. **Check the installation directory** - All available skills are located in the `skills/` folder, and extensions are in the `extensions/` folder of your OpenClaw installation.

2. **Ask OpenClaw** - Simply ask "What skills do you have?" or "What can you do?" to get information about installed capabilities.

3. **Review documentation** - Each skill and extension typically includes a README file with details about what it does and how to use it.

## Installing Skills

Skills in OpenClaw are designed to be easy to install and manage. Here's how to add new capabilities:

### Automatic Installation

Many skills are already bundled with OpenClaw and just need to be enabled. OpenClaw will automatically detect available skills in the `skills/` directory.

### Manual Installation

To manually add a new skill:

1. Place the skill folder in the `skills/` directory of your OpenClaw installation
2. Restart OpenClaw to detect the new skill
3. Enable the skill through configuration if needed

Skills are self-contained folders that include everything needed to function. Each skill directory contains its implementation and configuration files.

## Installing Extensions

Extensions follow a similar pattern to skills:

### Built-in Extensions

OpenClaw includes many extensions in the `extensions/` directory. These are available for activation as needed.

### Adding New Extensions

1. Place the extension folder in the `extensions/` directory
2. Restart OpenClaw
3. Configure the extension according to its documentation

## Enabling and Configuring Skills

Once installed, skills may need configuration before use:

### Basic Configuration

Skills often require settings like API keys, credentials, or preferences. These are typically configured through:

- Environment variables for sensitive data like API keys
- Configuration files for preferences and settings
- Interactive setup when you first use the skill

### API Keys and Credentials

Many skills need external service credentials:

1. **Obtain credentials** - Sign up for the service and get API keys or access tokens
2. **Store securely** - Add credentials to your environment configuration
3. **Test access** - Try using the skill to verify it's working

Common credentials needed:
- **Weather**: Weather service API key
- **GitHub**: GitHub personal access token
- **OpenAI**: OpenAI API key
- **Spotify**: Spotify developer credentials

### Skill-Specific Setup

Some skills require additional setup:

- **Smart home skills** may need device discovery
- **Note-taking skills** may need vault or workspace paths
- **Communication skills** may need account linking

Refer to each skill's documentation for specific requirements.

## Managing Skills and Extensions

### Checking Status

You can see which skills are active by asking OpenClaw about its capabilities or checking the configuration.

### Updating

Skills and extensions are updated when you update OpenClaw. New versions may add features, fix issues, or improve performance.

### Troubleshooting

If a skill isn't working:

1. **Verify installation** - Check that the skill folder exists in the correct location
2. **Check configuration** - Ensure all required settings are provided
3. **Review credentials** - Verify API keys and tokens are valid
4. **Restart OpenClaw** - Sometimes a restart is needed to detect changes
5. **Check logs** - Look for error messages that indicate what's wrong

## Using Skills in Practice

Once installed and configured, skills work seamlessly in conversation:

- "What's the weather like today?" - Uses the weather skill
- "Create a note about my meeting" - Uses your note-taking skill
- "Turn on the living room lights" - Uses smart home controls
- "Play some jazz music" - Uses music player integration

OpenClaw automatically determines which skills to use based on what you ask. You don't need to manually invoke skills—just express what you want to accomplish.

## Skill Development Basics

You can create custom skills to add new capabilities:

### Skill Structure

A skill is a folder containing:
- Implementation code that performs the skill's function
- Metadata describing what the skill does
- Configuration schema defining required settings
- Documentation explaining usage

### Development Concepts

Skills in OpenClaw follow these principles:

- **Self-contained** - Each skill is independent and includes everything it needs
- **Tool-based** - Skills expose tools that OpenClaw can use
- **Configurable** - Skills accept configuration for customization
- **Documented** - Skills include descriptions of their capabilities

### Creating a Simple Skill

Basic steps to develop a skill:

1. **Create a folder** in the `skills/` directory
2. **Implement the functionality** - Write code that performs your desired task
3. **Define tools** - Specify what actions the skill provides
4. **Add configuration** - Define any settings your skill needs
5. **Document usage** - Explain what the skill does and how to configure it
6. **Test thoroughly** - Ensure the skill works as expected

### Extension Development

Extensions are more complex than skills as they handle platform integrations:

- **Gateway connections** - Managing communication with external platforms
- **Authentication** - Handling login and credentials
- **Message handling** - Processing incoming and outgoing messages
- **State management** - Maintaining connection state

Refer to existing extensions as examples when developing new ones.

## Advanced Features

### Skill Hooks

Skills can hook into various points in OpenClaw's operation to customize behavior at different stages.

### Custom Commands

Skills can add special commands that provide direct access to functionality.

### Skill Dependencies

Some skills may depend on others or require specific system capabilities to be available.

## Best Practices

### Security

- **Protect credentials** - Never store API keys or passwords in skill code
- **Use environment variables** - Store sensitive data securely
- **Validate inputs** - Ensure skills handle untrusted data safely
- **Follow least privilege** - Only request permissions that are needed

### Performance

- **Cache when appropriate** - Avoid repeated expensive operations
- **Handle errors gracefully** - Provide helpful messages when things go wrong
- **Optimize resource usage** - Be mindful of memory and CPU consumption

### Maintenance

- **Keep skills updated** - Install updates to get fixes and improvements
- **Monitor functionality** - Check that skills continue working as services change
- **Document customizations** - Note any special configuration you've applied

## Getting Help

If you need assistance with skills or extensions:

- Check the documentation in each skill's folder
- Review example configurations
- Look for error messages in logs
- Ask OpenClaw for help with specific features

The skills and extensions system makes OpenClaw incredibly flexible and powerful. Start with the built-in capabilities, then expand by adding new skills as you discover additional needs. The modular design ensures you only enable what you use while keeping the door open for future growth.