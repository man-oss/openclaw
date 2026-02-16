# How to Use iOS and Android Apps

OpenClaw provides native mobile applications for iOS and Android that connect to your gateway and enable voice interactions, canvas rendering, and mobile-specific features.

## Installing the iOS App

### System Requirements

- iOS device running iOS 15.0 or later
- Active OpenClaw gateway running on your network

### Getting the App

The iOS app is built from source using Xcode. You can install it on your device by:

1. Ensure you have Xcode and xcodegen installed
2. Open your terminal and navigate to the OpenClaw project
3. Generate and build the app for your iOS device or simulator

The app will appear on your device as "OpenClaw" with the standard OpenClaw branding.

## Installing the Android App

### System Requirements

- Android device running Android 8.0 (API level 26) or later
- Active OpenClaw gateway running on your network

### Getting the App

The Android app is built using Gradle. To install it on your device:

1. Connect your Android device via USB with developer mode enabled
2. The app will be installed and ready to use
3. Launch OpenClaw from your app drawer

## Connecting to Your Gateway

### First-Time Setup

When you first open the mobile app, you'll need to connect it to your OpenClaw gateway:

1. Launch the OpenClaw app on your device
2. The app will display a connection screen
3. Enter your gateway's connection details:
   - Gateway URL (the address where your gateway is running)
   - Authentication credentials if required (token or password)
4. Tap Connect

The app will attempt to connect and display "Connecting..." while establishing the connection.

### Connection Status

The app displays your connection status at the top of the screen:

- **Connected** - Successfully connected to your gateway
- **Connecting...** - Attempting to establish connection
- **Reconnecting...** - Temporarily lost connection and attempting to restore it
- **Offline** - Not connected to a gateway
- **Disconnected** - Connection was terminated

### Automatic Reconnection

The mobile app includes smart reconnection features:

- **Foreground Recovery**: When you return to the app after switching away, it automatically checks the connection health and reconnects if needed
- **Network Changes**: The app adapts when switching between WiFi and cellular networks
- **Background Resilience**: Connection state is preserved when the app moves to the background

### Connection Settings

You can customize connection behavior:

- **Auto-Reconnect**: Keep this enabled to automatically restore connections when they drop
- **Server Name**: View which gateway server you're connected to
- **Remote Address**: See the actual network address of your gateway connection

## Using the Canvas Display

### What is the Canvas?

The canvas is your primary interface for interacting with OpenClaw. It displays visual responses, interactive controls, and agent outputs in a web-based view.

### Canvas Behavior

When you connect to a gateway:

- The canvas automatically loads the gateway's interface
- Interactive elements respond to touch input
- The display fills your entire screen for maximum usability
- Buttons and controls are touch-optimized for mobile use

### Canvas Actions

You can interact with elements displayed on the canvas by:

- Tapping buttons to trigger actions
- Scrolling through content
- Filling out forms
- Viewing images and media

When you tap an interactive element, the app sends the action to your gateway for processing. Responses appear directly in the canvas.

### Default Canvas

When not connected to a gateway, the app shows a default local canvas with connection instructions and status information.

## Voice Features

### Voice Wake

Voice wake lets you activate OpenClaw with spoken trigger words:

1. Open Settings in the app
2. Enable Voice Wake
3. The app will listen continuously for your trigger words
4. When detected, your command is sent to the gateway

**Note**: Voice wake uses your device's microphone continuously when enabled. Battery usage may be higher.

### Managing Trigger Words

Set custom wake words for activating voice commands:

1. Your trigger words are synchronized with your gateway
2. Changes made on any device update across all connected devices
3. Speak clearly and allow brief pauses between the wake word and your command

### Talk Mode

Talk mode provides push-to-talk voice interaction:

1. Enable Talk Mode in Settings
2. Press and hold the talk button to record your voice
3. Release to send your recording to the gateway
4. Receive spoken or visual responses

**Important**: Talk mode and voice wake cannot run simultaneously. Enabling talk mode automatically pauses voice wake to avoid microphone conflicts.

## Mobile-Specific Features

### Camera Integration

Grant camera access to enable visual features:

1. When OpenClaw requests camera access, approve the permission
2. The gateway can request photos or video clips through the camera
3. Visual feedback appears on screen when capturing media:
   - "Taking photo..." indicator during photo capture
   - "Recording..." indicator during video recording
   - "Photo captured" or "Clip captured" confirmation when complete

### Location Services

Enable location access for location-aware features:

1. Choose your preferred location mode:
   - **Off**: No location access
   - **While Using**: Location available only when app is open
   - **Always**: Location available even in background
2. Toggle precise location for higher accuracy
3. The gateway can request your current location when needed

### Notifications

OpenClaw can send you notifications:

1. Grant notification permission when prompted
2. The gateway can send you alerts and messages
3. Notifications appear even when the app is closed
4. Tap notifications to open the app

### Screen Recording

On iOS, the gateway can capture screen recordings:

- The system will ask for permission before recording begins
- A recording indicator appears in your status bar
- Recording automatically stops after the requested duration

### Device Information

The gateway can access device information to provide context-aware responses:

- Battery level and charging status
- Available storage space
- Device model and system version
- Network connectivity status

## Permission Management

### Understanding Permissions

OpenClaw requests permissions only when needed for specific features:

- **Camera**: For photo and video capture
- **Microphone**: For voice wake and talk mode
- **Location**: For location-based features
- **Notifications**: For alerts and messages
- **Contacts**: For contact-related features (if used)
- **Calendar/Reminders**: For scheduling features (if used)
- **Motion**: For activity tracking (if used)
- **Photos**: For accessing your photo library (if used)

### Managing Permissions

On iOS:
1. Open Settings → OpenClaw
2. Toggle individual permissions on or off
3. Changes take effect immediately

On Android:
1. Open Settings → Apps → OpenClaw → Permissions
2. Adjust permissions as needed

### Background Restrictions

Some features require the app to be in the foreground:

- Camera capture
- Screen recording  
- Canvas interactions
- Push-to-talk recording

If you try to use these features while the app is in the background, you'll see an error message.

## Troubleshooting Connection Issues

### "Gateway not connected" Error

If you see this error:

1. Check that your gateway is running and accessible
2. Verify you're on the same network as the gateway (or have remote access configured)
3. Confirm your gateway URL is correct
4. Try disconnecting and reconnecting

### Connection Drops Frequently

If your connection is unstable:

1. Check your WiFi or cellular signal strength
2. Move closer to your WiFi router if possible
3. Verify your gateway is running without errors
4. Check if firewall settings are blocking the connection

### "Could not connect to server" Message

This indicates the app cannot reach the gateway:

1. Verify the gateway URL is correct (including http:// or https://)
2. Check that the gateway is running
3. Ensure your device can access the gateway's network
4. Try entering the gateway's IP address directly instead of a hostname

### Canvas Not Loading

If the canvas appears blank or shows an error:

1. Check your internet connection
2. Wait a moment for the canvas to load
3. Try disconnecting and reconnecting to the gateway
4. Verify the gateway's canvas host is properly configured

### Voice Wake Not Responding

If voice wake isn't detecting your commands:

1. Check that Voice Wake is enabled in Settings
2. Ensure microphone permission is granted
3. Disable Talk Mode if it's enabled (they cannot run together)
4. Speak clearly with a slight pause after the trigger word
5. Try adjusting your trigger words

### App Disconnects in Background

On iOS, network connections may suspend when the app is in the background for extended periods:

- This is normal iOS behavior to save battery
- The app will reconnect automatically when you return to it
- For critical always-on features, keep the app in the foreground

### Camera Errors

If camera features fail:

1. Check that Camera is enabled in Settings → OpenClaw
2. Grant camera permission when prompted
3. Ensure no other app is using the camera
4. Try closing and reopening the app

### Authentication Failures

If you see "unauthorized" errors:

1. Verify your token or password is correct
2. Check with your gateway administrator
3. Try disconnecting and entering credentials again
4. Ensure your account has the necessary permissions

## Agent Selection

### Multiple Agents

If your gateway has multiple agents configured:

1. Open the agent selector in the app
2. View the list of available agents
3. Tap an agent to select it
4. Your selection persists across app restarts

### Active Agent Display

The currently selected agent appears at the top of the screen. If no specific agent is selected, you'll see "Main" indicating the default gateway agent.

## Data and Privacy

### What Data is Sent

The mobile app sends to your gateway:

- Voice recordings (when using voice features)
- Photos and videos (when camera features are used)
- Location data (when location features are used and permission granted)
- Device status information (when requested by the gateway)
- Canvas interactions (button taps, form inputs)

### Local Processing

- Voice wake detection happens on your device
- No audio is sent until a trigger word is detected
- Camera previews are processed locally

### Data Storage

- Connection settings are stored locally on your device
- No conversation history is stored in the app
- All conversation data lives on your gateway

## Best Practices

### Battery Conservation

To extend battery life:

- Disable voice wake when not needed
- Use talk mode instead of continuous voice wake
- Keep location set to "While Using" instead of "Always"
- Close the app when not in use for extended periods

### Network Usage

To minimize data usage on cellular:

- Connect to WiFi when possible for large transfers
- Avoid camera/screen recording features on metered connections
- Use lower quality settings if available

### Performance

For the best experience:

- Keep your gateway on a reliable network
- Use a strong WiFi connection when possible
- Close other apps if experiencing slowness
- Restart the app if it becomes unresponsive

### Security

To keep your connection secure:

- Use HTTPS connections when possible
- Keep your authentication token private
- Don't share gateway credentials
- Disconnect when not in use on shared devices