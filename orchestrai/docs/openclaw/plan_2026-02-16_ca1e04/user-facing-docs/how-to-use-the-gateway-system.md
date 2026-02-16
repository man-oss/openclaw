# How to Use the Gateway System

The Gateway is OpenClaw's central control plane that coordinates all communication between your AI assistant, messaging channels, and connected devices. Think of it as the hub that connects everything together.

## Understanding the Gateway's Role

The Gateway serves as the communication center for your OpenClaw assistant. It:

- Manages conversations across all your messaging apps (WhatsApp, Telegram, Slack, Discord, and others)
- Coordinates with connected devices like your iPhone, Android phone, or Mac
- Handles voice commands and speech responses
- Manages the visual canvas interface
- Tracks conversation history and context

All communication flows through the Gateway, making it possible to seamlessly interact with your assistant from any connected device or messaging platform.

## Starting the Gateway

### Quick Start

To launch the Gateway for the first time, open your terminal and run:

```bash
openclaw gateway
```

The Gateway will start and display its status. By default, it listens at `http://127.0.0.1:18789`.

### Starting with Custom Settings

You can customize how the Gateway runs:

```bash
# Use a different port
openclaw gateway --port 18789

# See detailed activity logs
openclaw gateway --verbose

# Specify a custom configuration file
openclaw gateway --config /path/to/openclaw.json
```

### Running the Gateway Automatically

For the best experience, set up the Gateway to start automatically when your computer boots:

```bash
openclaw onboard --install-daemon
```

This creates a background service that keeps the Gateway running. On macOS, it uses launchd; on Linux, it uses systemd.

## Stopping the Gateway

To stop the Gateway, you have several options:

### From the Terminal

Press `Ctrl+C` in the terminal window where the Gateway is running.

### Using Commands

```bash
# Stop the Gateway service
openclaw gateway stop

# Restart the Gateway
openclaw gateway restart
```

### From the macOS Menu Bar App

If you're using the macOS companion app, click the menu bar icon and select "Stop Gateway" or "Restart Gateway."

## Monitoring Gateway Status

### Check Connection Status

To see if the Gateway is running and accepting connections:

```bash
openclaw gateway status
```

This shows:
- Whether the Gateway is online
- Which port it's using
- How many devices and channels are connected
- Current health status

### View Connected Devices

To see all devices (like your iPhone or Android phone) connected to the Gateway:

```bash
openclaw nodes list
```

This displays each connected device, its capabilities, and connection status.

### Monitor Activity

When running the Gateway with `--verbose`, you'll see real-time activity including:
- Incoming messages from your messaging apps
- Requests from connected devices
- AI responses being generated
- Any connection issues or errors

### Access the Dashboard

Open your web browser and go to:

```
http://localhost:18789
```

The dashboard provides a visual overview of:
- Active conversations and sessions
- Connected channels and devices
- Gateway health and performance
- Recent activity logs

## Configuring Gateway Settings

### Location of Configuration

Your Gateway configuration is stored in:

```
~/.openclaw/openclaw.json
```

### Basic Configuration

Edit this file to customize the Gateway. Here's a minimal example:

```json
{
  "gateway": {
    "port": 18789,
    "bind": "loopback"
  },
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  }
}
```

### Common Settings

**Change the Port**

```json
{
  "gateway": {
    "port": 8080
  }
}
```

**Enable Remote Access**

To access the Gateway from other devices on your network:

```json
{
  "gateway": {
    "bind": "0.0.0.0",
    "auth": {
      "mode": "password"
    }
  }
}
```

**Configure Authentication**

Set a password for accessing the Gateway:

```json
{
  "gateway": {
    "auth": {
      "mode": "password",
      "password": "your-secure-password"
    }
  }
}
```

**Set Up Tailscale Access**

For secure remote access through Tailscale:

```json
{
  "gateway": {
    "tailscale": {
      "mode": "serve"
    }
  }
}
```

Options:
- `serve`: Accessible only within your Tailscale network
- `funnel`: Public HTTPS access (requires password authentication)
- `off`: No Tailscale integration (default)

### Applying Configuration Changes

After editing your configuration file, restart the Gateway for changes to take effect:

```bash
openclaw gateway restart
```

## Troubleshooting Common Issues

### Gateway Won't Start

**Port Already in Use**

If you see an error about the port being unavailable:

1. Check if another Gateway is already running:
   ```bash
   openclaw gateway status
   ```

2. Try using a different port:
   ```bash
   openclaw gateway --port 18790
   ```

**Permission Issues**

If the Gateway can't access certain files:

1. Check that the configuration directory exists:
   ```bash
   ls -la ~/.openclaw
   ```

2. Ensure you have write permissions:
   ```bash
   chmod -R u+w ~/.openclaw
   ```

### Gateway Keeps Disconnecting

**Check Network Connectivity**

Verify your internet connection is stable. The Gateway needs consistent connectivity to communicate with AI services.

**Review Logs**

Look at recent activity to identify connection patterns:

```bash
openclaw gateway --verbose
```

Watch for repeated connection attempts or error messages.

**Restart the Gateway**

Sometimes a simple restart resolves temporary issues:

```bash
openclaw gateway restart
```

### Devices Won't Connect

**Verify Gateway is Running**

Confirm the Gateway is active:

```bash
openclaw gateway status
```

**Check Network Settings**

Ensure devices are on the same network if using local connections. For remote access, verify Tailscale is configured correctly.

**Review Device Pairing**

Some devices require pairing codes. Check for pairing requests:

```bash
openclaw pairing list
```

Approve any pending requests:

```bash
openclaw pairing approve <channel> <code>
```

### Messages Not Getting Through

**Verify Channel Configuration**

Check that your messaging channels are properly configured in `openclaw.json`. Each channel (WhatsApp, Telegram, etc.) needs valid credentials.

**Check Permissions**

Ensure the Gateway has permission to access messaging services. Some channels require tokens or API keys.

**Review Session Status**

Active conversations are tracked as sessions. List current sessions:

```bash
openclaw sessions list
```

If a session appears stuck, you can reset it by sending `/reset` in the conversation.

### Performance Issues

**Gateway Running Slowly**

If responses are delayed:

1. Check CPU and memory usage on your computer
2. Reduce the number of concurrent conversations
3. Consider running the Gateway on a more powerful machine

**High Memory Usage**

The Gateway maintains conversation context in memory. To reduce usage:

1. Enable session pruning in your configuration
2. Limit the maximum conversation history length
3. Periodically clear old sessions

### Getting Help

**Run the Doctor Tool**

OpenClaw includes a diagnostic tool that checks for common issues:

```bash
openclaw doctor
```

This scans your configuration and suggests fixes for problems it finds.

**Check Logs**

Detailed logs are stored in:

```
~/.openclaw/logs/
```

Review recent log files for error messages and stack traces.

**Configuration Validation**

Verify your configuration file is valid:

```bash
openclaw config validate
```

This checks for syntax errors and invalid settings.

## Best Practices

### Security

- Always use password authentication when enabling remote access
- Keep your configuration file secure (it may contain API keys)
- Regularly update OpenClaw to get security fixes
- Use Tailscale for secure remote access rather than exposing ports directly

### Reliability

- Set up the Gateway as a background service for automatic startup
- Monitor Gateway health regularly
- Keep logs for troubleshooting
- Back up your configuration file periodically

### Performance

- Run the Gateway on a reliable machine with good internet connectivity
- Avoid running too many resource-intensive tasks simultaneously
- Clear old conversation history that you no longer need
- Use appropriate session settings for your usage patterns

## Advanced Topics

### Remote Gateway Access

You can run the Gateway on a separate machine (like a Linux server) and connect to it from your devices. This is useful for:

- Running on more powerful hardware
- Maintaining 24/7 availability
- Centralized management of all conversations

To enable remote access, configure authentication and either use Tailscale or set up an SSH tunnel.

### Multiple Agents

The Gateway supports running multiple AI agents simultaneously, each with different personalities or capabilities. Configure this in the agents section of your configuration file.

### Custom Integrations

The Gateway provides WebSocket and HTTP APIs for building custom integrations. Access the API documentation through the dashboard or visit the developer documentation.

### Monitoring and Logging

For production deployments, configure structured logging and health monitoring to track Gateway performance and detect issues early.