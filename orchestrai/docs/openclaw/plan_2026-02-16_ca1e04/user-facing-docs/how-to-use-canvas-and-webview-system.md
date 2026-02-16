# How to Use Canvas and WebView System

OpenClaw provides an interactive canvas system that displays AI-generated visual content and interfaces directly within the application. This guide explains how to use the canvas features effectively on both mobile and desktop platforms.

## Understanding the Canvas System

The canvas system allows you to view and interact with visual content that the AI creates during conversations. When you're connected to an AI service, the canvas automatically displays interactive interfaces, visualizations, and other rich content beyond simple text responses.

The canvas uses web technology to render content, which means it can display:
- Interactive user interfaces
- Visual data representations
- Dynamic forms and controls
- Custom layouts and designs created by the AI

## Automatic Canvas Behavior

### When Connected to AI Services

When you connect to an AI service, OpenClaw automatically attempts to display the interactive canvas interface. The system:

1. **Checks for available canvas content** - The application looks for a canvas host URL from your connected AI service
2. **Verifies connectivity** - Before loading canvas content, the system performs a quick connection test (2.5 seconds) to ensure the host is reachable
3. **Loads the canvas automatically** - If content is available and the connection is successful, the canvas displays automatically

### When Disconnected

When you disconnect from an AI service or if no connection is available, the canvas automatically switches to a default local view. This ensures you always see a functional interface, even without an active AI connection.

## Canvas on Different Platforms

### Mobile (iOS)

On iOS devices, the canvas system includes special handling for mobile environments:

- **Platform detection** - The canvas automatically identifies that it's running on iOS and adjusts accordingly
- **Network awareness** - The system is particularly careful about network connectivity on mobile, avoiding attempts to load content from unreachable hosts
- **Connection testing** - Before loading remote canvas content, the app tests the connection to prevent error messages from appearing if the server isn't accessible
- **Smooth transitions** - When switching between connected and disconnected states, the canvas transitions smoothly between remote and local content

### Desktop

On desktop platforms, the canvas functions similarly but may have more screen space for displaying complex interfaces and visualizations.

## Using Interactive Canvas Features

### Viewing AI-Generated Content

When the AI creates visual content for you:

1. The canvas automatically updates to show the new content
2. You can interact with any controls, buttons, or interactive elements the AI has created
3. The canvas remains responsive while you continue your conversation

### Navigation

The canvas may update its content during your session:

- **Automatic updates** - When connecting to a service, the canvas navigates to the appropriate interface automatically
- **Persistent state** - The system remembers your last canvas URL to avoid unnecessary reloading
- **Smart refreshing** - The canvas only refreshes when necessary, preventing disruptions to your workflow

## Troubleshooting Canvas Display Issues

### Canvas Shows Default View Instead of AI Content

If you're connected to an AI service but seeing the default canvas view instead of interactive content:

**Possible causes:**
- The AI service may not have a canvas interface available
- The canvas host may be unreachable from your current network
- The connection test timed out (after 2.5 seconds)

**What to try:**
- Check your internet connection
- Ensure you can access the AI service through other means
- Try disconnecting and reconnecting to the service
- Wait a moment for the automatic connection retry

### Canvas Shows "Could Not Connect" Error

The canvas system actively prevents this error by:
- Testing connections before attempting to load content
- Automatically falling back to the default view if a host is unreachable
- Avoiding navigation to localhost or loopback addresses when running remotely

If you still see this error:
- The connection may have been lost after the canvas loaded
- Try disconnecting and reconnecting to refresh the canvas
- Check if your network connection changed during the session

### Canvas Not Updating

If the canvas content seems stuck or not responding to AI interactions:

- The canvas may be waiting for content from the AI service
- Check if your conversation is still active
- Try sending a new message to trigger a canvas update
- Disconnect and reconnect if the issue persists

### Blank Canvas Display

A blank canvas usually means:
- You're not currently connected to an AI service (working as intended)
- The default local canvas is loading
- Canvas content is loading but hasn't appeared yet

Wait a moment for content to load, or connect to an AI service to enable interactive features.

## Network and Connectivity Considerations

### Connection Testing

The canvas system performs automatic connection testing to ensure smooth operation:

- **Fast timeouts** - Connection tests timeout after 2.5 seconds to avoid long waits
- **Background checks** - Testing happens automatically without requiring your interaction
- **Graceful fallbacks** - If a test fails, the system shows local content instead of error messages

### Localhost and Loopback Handling

For security and reliability, the canvas system:

- Detects localhost and loopback addresses (127.0.0.1, ::1, 0.0.0.0)
- Prevents loading canvas content from these addresses when inappropriate
- Automatically uses local content instead when remote hosts aren't available

This prevents issues when running in environments where localhost references won't work correctly.

## Best Practices for Canvas Usage

### Optimize Your Experience

- **Maintain stable connectivity** - A reliable internet connection ensures smooth canvas updates
- **Allow automatic loading** - The system is designed to manage canvas content automatically; let it work
- **Be patient during connections** - Initial connection and canvas loading may take a few seconds

### Understanding Canvas States

The canvas can be in several states:

1. **Default local view** - Shown when disconnected or when no remote canvas is available
2. **Loading remote content** - Brief state while connecting to AI service canvas
3. **Active interactive canvas** - Fully loaded and ready for interaction with AI-generated content

Each state transition happens automatically based on your connection status and available content.

## Privacy and Data Handling

### What the Canvas Accesses

The canvas system:
- Connects to the canvas host URL provided by your AI service
- Loads visual content and interfaces from that host
- Does not share additional data beyond what your AI service connection already provides

### Platform Information

The canvas includes basic platform detection (iOS vs other platforms) to optimize the display and interaction patterns for your device. This information helps ensure the canvas works well on your specific platform.