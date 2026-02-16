# How to Use Multi-Channel Messaging

OpenClaw connects your AI assistant to all your favorite messaging apps, so you can chat with it wherever you are. This guide shows you how to set up and use these connections.

## Supported Messaging Platforms

OpenClaw works with these messaging platforms:

- **WhatsApp** - Chat from your phone or WhatsApp Web
- **Telegram** - Use your existing Telegram account
- **Slack** - Connect to your workspace channels
- **Discord** - Add to your Discord servers
- **Google Chat** - Integrate with Google Workspace
- **Signal** - Private, encrypted messaging
- **iMessage** - Message from your iPhone or Mac (via BlueBubbles)
- **Microsoft Teams** - Connect to your work Teams
- **Matrix** - Decentralized messaging (via extension)
- **Zalo** - Popular in Vietnam (via extension)
- **WebChat** - Built-in web interface

## Getting Started

### First Time Setup

Before connecting any messaging platform, you need OpenClaw running on your computer. If you haven't installed it yet:

1. Open your terminal
2. Run the setup wizard by typing `openclaw onboard`
3. Follow the prompts to complete the initial configuration

The wizard guides you through connecting your first messaging platform.

### Security and Privacy

OpenClaw includes security features to protect your conversations:

- **Pairing codes** - New contacts must enter a code before chatting
- **Approved contacts** - You control who can message your assistant
- **Private by default** - Only people you approve can start conversations

## Setting Up Each Platform

### WhatsApp

Connect OpenClaw to WhatsApp to message your assistant from your phone:

1. Make sure OpenClaw is running
2. Type `openclaw channels login` in your terminal
3. A QR code appears on your screen
4. Open WhatsApp on your phone
5. Tap the menu (three dots) and select "Linked Devices"
6. Tap "Link a Device" and scan the QR code
7. WhatsApp is now connected

Your assistant will respond to messages you send in WhatsApp, just like chatting with a friend.

**Approving contacts**: By default, only you can message the assistant. To allow others:
- They'll receive a pairing code when they first message
- Check your OpenClaw logs for the code
- Approve them by typing `openclaw pairing approve whatsapp <code>`

### Telegram

Set up a Telegram bot to chat with your assistant:

1. Open Telegram and search for "BotFather"
2. Start a chat with BotFather and type `/newbot`
3. Follow the prompts to name your bot
4. BotFather gives you a token (a long string of numbers and letters)
5. Copy this token
6. Create or edit your OpenClaw configuration file
7. Add this section (replace YOUR_TOKEN with your actual token):

```json
{
  "channels": {
    "telegram": {
      "botToken": "YOUR_TOKEN"
    }
  }
}
```

8. Restart OpenClaw
9. Find your bot in Telegram and start chatting

**Group chats**: To use the bot in Telegram groups, add it to the group and mention it with @ to get its attention.

### Slack

Connect OpenClaw to your Slack workspace:

1. Go to api.slack.com and create a new app
2. Enable "Socket Mode" in your app settings
3. Copy the Bot Token and App Token from the settings
4. Add them to your OpenClaw configuration:

```json
{
  "channels": {
    "slack": {
      "botToken": "YOUR_BOT_TOKEN",
      "appToken": "YOUR_APP_TOKEN"
    }
  }
}
```

5. Restart OpenClaw
6. Invite the bot to your Slack channels
7. Message the bot directly or mention it in channels

### Discord

Add OpenClaw as a bot to your Discord server:

1. Visit discord.com/developers and create a new application
2. Go to the "Bot" section and create a bot
3. Copy the bot token
4. Add it to your OpenClaw configuration:

```json
{
  "channels": {
    "discord": {
      "token": "YOUR_BOT_TOKEN"
    }
  }
}
```

5. Generate an invite link in the Discord developer portal
6. Use the link to add the bot to your server
7. Chat with the bot in direct messages or mention it in channels

### Google Chat

Connect to Google Chat through your Google Workspace:

1. Configure a Google Chat API project in the Google Cloud Console
2. Set up service account credentials
3. Add the credentials to your OpenClaw configuration
4. Install the app in your Google Workspace

This setup requires administrator access to your Google Workspace.

### Signal

Use Signal for private, encrypted conversations:

1. Install signal-cli on your computer
2. Register or link a phone number with signal-cli
3. Configure OpenClaw to use signal-cli
4. Restart OpenClaw

Signal integration requires command-line setup through signal-cli.

### iMessage (via BlueBubbles)

Chat through iMessage from any device:

1. Set up BlueBubbles on a Mac that stays running
2. Note the server URL and password from BlueBubbles
3. Add them to your OpenClaw configuration:

```json
{
  "channels": {
    "bluebubbles": {
      "serverUrl": "YOUR_SERVER_URL",
      "password": "YOUR_PASSWORD"
    }
  }
}
```

4. Restart OpenClaw
5. Send messages through iMessage as normal

BlueBubbles requires a Mac computer to stay running and connected.

### Microsoft Teams

Connect to Microsoft Teams in your organization:

1. Register a bot in the Azure Bot Framework
2. Configure the Microsoft Teams channel
3. Add the bot credentials to OpenClaw
4. Install the bot in your Teams organization

This requires Microsoft Azure and Teams administrator access.

### WebChat

The simplest option - use the built-in web interface:

1. Make sure OpenClaw is running
2. Open your web browser
3. Go to the address shown in the OpenClaw startup logs (usually something like http://localhost:18789)
4. Click on "WebChat" in the interface
5. Start chatting

No additional setup needed - WebChat works immediately.

## Managing Conversations

### Sending Messages

Just message your assistant like you would any contact:

- **Direct messages** work on all platforms
- **Group chats** require mentioning the bot (on Telegram, Slack, Discord)
- **Commands** start with / and control the assistant's behavior

### Using Commands

Type these commands in any conversation to control your assistant:

- `/status` - Check the current session status
- `/new` or `/reset` - Start a fresh conversation
- `/compact` - Summarize the conversation to save space
- `/think <level>` - Adjust how much the assistant thinks (off, minimal, low, medium, high, xhigh)
- `/verbose on` or `/verbose off` - Control detailed responses
- `/usage off`, `/usage tokens`, or `/usage full` - Show usage information

### Platform-Specific Features

Each platform has unique capabilities:

**WhatsApp & Telegram**:
- Send images and the assistant can see them
- Send voice messages for transcription
- Works on mobile and desktop

**Slack & Discord**:
- Threaded conversations
- Rich formatting in responses
- Integration with workspace tools

**Google Chat & Teams**:
- Enterprise security features
- Calendar and meeting integration
- Organization-wide deployment

**Signal**:
- End-to-end encryption
- Maximum privacy
- Disappearing messages

**WebChat**:
- No app installation needed
- Works in any browser
- Direct access to all features

### Limitations by Platform

**WhatsApp**:
- QR code expires and needs re-scanning occasionally
- May disconnect if phone is off for extended periods

**Telegram**:
- Bots cannot initiate conversations
- Some features limited in group chats

**Slack & Discord**:
- Rate limits on message sending
- May require permissions for certain channels

**Signal**:
- Requires signal-cli setup
- More technical to configure

**iMessage**:
- Requires Mac computer always running
- BlueBubbles server must stay connected

## Troubleshooting

### Connection Issues

**Platform won't connect**:
1. Check that OpenClaw is running
2. Verify your configuration settings are correct
3. Look at the OpenClaw logs for error messages
4. Restart OpenClaw after configuration changes

**Messages not appearing**:
1. Confirm the bot is online on the platform
2. Check if you need to mention the bot in group chats
3. Verify you're approved to message (check pairing status)

**QR code problems (WhatsApp)**:
1. Make sure the QR code is fully visible
2. Try scanning with better lighting
3. Generate a fresh QR code by restarting the login process

### Pairing and Approval

**Someone can't message the assistant**:
1. They'll receive a pairing code in response
2. Check the OpenClaw logs to see the code
3. Approve them: `openclaw pairing approve <platform> <code>`

**Removing access**:
1. Edit your configuration file
2. Remove the contact from the approved list
3. Restart OpenClaw

### Performance Issues

**Slow responses**:
- Check your internet connection
- Verify the AI model service is responding
- Review rate limits on your platform

**Messages getting stuck**:
- Restart OpenClaw
- Check platform status pages for outages
- Review logs for specific errors

## Advanced Features

### Multiple Accounts

You can connect multiple accounts on the same platform:
- Run separate OpenClaw instances
- Use different configuration files
- Keep each instance isolated

### Group Management

Control how the assistant behaves in groups:

**Telegram groups**:
- Bot only responds when mentioned with @
- Set activation mode with `/activation mention` or `/activation always`

**Slack channels**:
- Configure which channels the bot monitors
- Set mention requirements per channel

**Discord servers**:
- Control permissions per channel
- Set up role-based access

### Custom Responses

Customize how the assistant responds on each platform:
- Adjust message length limits
- Configure typing indicators
- Set platform-specific behavior

## Best Practices

### Security

1. **Use pairing codes** - Don't disable this security feature
2. **Review approved contacts** regularly
3. **Use encryption** when available (Signal, WhatsApp)
4. **Keep tokens secret** - Never share bot tokens publicly

### Organization

1. **Choose your main platform** - Where you check most often
2. **Use WebChat for testing** - Quick access without platform setup
3. **Set up groups thoughtfully** - Control where the bot can respond
4. **Monitor usage** - Check `/status` to track conversation costs

### Reliability

1. **Keep OpenClaw running** - Set it up as a background service
2. **Monitor connections** - Watch logs for disconnections
3. **Update regularly** - New versions fix bugs and add features
4. **Back up configurations** - Save your settings file

## Getting Help

If you encounter issues:

1. Check the OpenClaw logs for detailed error messages
2. Run `openclaw doctor` to diagnose common problems
3. Review platform-specific documentation for setup details
4. Visit the OpenClaw documentation website for guides
5. Join the community Discord for support

Your assistant is now ready to chat across all your favorite platforms. Start a conversation on any connected platform and your AI assistant will respond wherever you are.