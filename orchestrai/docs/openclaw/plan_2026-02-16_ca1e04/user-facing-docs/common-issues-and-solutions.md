# Common Issues and Solutions

This guide helps you diagnose and resolve common problems you might encounter while using OpenClaw.

## Installation and Setup Issues

### Cannot Find Configuration File

**Problem:** OpenClaw reports it cannot locate your configuration file.

**Solution:** OpenClaw looks for its configuration in a specific location on your computer. The exact path is shown when you run status commands. If the file doesn't exist:

1. Run the configuration wizard to create it automatically
2. Ensure you have write permissions in your home directory
3. Check that the configuration directory wasn't accidentally deleted

### Agent Directory Not Found

**Problem:** Messages indicate the agent directory is missing or inaccessible.

**Solution:** The agent directory stores important working files. If it's missing:

1. Verify the path shown in status messages exists and is accessible
2. Check folder permissions - you need both read and write access
3. Allow OpenClaw to recreate the directory by running setup commands again

## Authentication and API Key Problems

### Missing Authentication for Active Providers

**Problem:** You see warnings about "Missing auth" for providers you're trying to use.

**Solution:** Each AI provider needs proper authentication before you can use it:

- **For Anthropic/Claude:** First set up your token with the Claude app, then run the setup command to import it into OpenClaw, or add your API key through the configuration wizard
- **For other providers:** Run the configuration wizard or set the appropriate API key in your environment variables

### OAuth Token Expired

**Problem:** Status checks show your OAuth token is "expired" or authentication fails with expired credentials.

**Solution:** OAuth tokens have limited lifespans and need periodic renewal:

1. Check the status display to see which provider tokens are expired
2. Re-run authentication setup for that provider
3. Some tokens show "expiring" before they fully expire - renew them proactively to avoid interruptions

### Unknown OAuth Token Status

**Problem:** Status shows "unknown" for OAuth token expiration.

**Solution:** This means OpenClaw cannot determine when your token expires:

- The token may still work but could expire without warning
- Test the connection by running a probe check
- Consider re-authenticating to get a token with known expiration

### Environment Variable Not Applied

**Problem:** You set an API key environment variable but OpenClaw doesn't recognize it.

**Solution:** Check these common issues:

1. **Shell environment fallback disabled:** Enable shell environment fallback in your configuration or ensure it's turned on
2. **Variable name incorrect:** Each provider expects specific environment variable names
3. **Terminal session:** Restart your terminal after setting environment variables to ensure they're loaded

## Model Availability and Rate Limiting

### Rate Limit Errors

**Problem:** You receive rate limit errors when trying to use a provider.

**Solution:** Providers restrict how many requests you can make in a time window:

1. Check the usage summary in status displays to see your current limits
2. Wait for the time window to reset (shown in the status display)
3. If you have multiple authentication profiles for the same provider, OpenClaw can automatically rotate between them
4. Consider upgrading your provider account tier for higher limits

### Provider Profile in Cooldown

**Problem:** Status shows a profile is in "cooldown" or "disabled" state.

**Solution:** When a profile encounters repeated errors or hits rate limits, it's temporarily paused:

- View the status display to see how long until the cooldown expires
- The "remaining" time tells you when the profile will be available again
- Use alternative profiles or wait for the cooldown to complete
- For persistent issues, the profile may be disabled until you resolve the underlying problem

### Model Not Available

**Problem:** Commands fail with "no model available" or similar errors.

**Solution:** This means no usable model was found:

1. Verify the model name is correct in your configuration
2. Check that you have valid authentication for that model's provider
3. Ensure the model exists in the provider's current catalog
4. Run a probe check to test which models are actually accessible

### Billing Issues

**Problem:** Authentication probes show "billing" status or payment errors.

**Solution:** Provider account billing problems prevent API access:

1. Log into your provider account to check payment status
2. Verify your payment method is valid and not expired
3. Check if you've exceeded free tier limits
4. Ensure your account has sufficient credits or an active subscription

## Channel Connection Issues

### Cannot Connect to Gateway

**Problem:** Mobile app or remote features cannot establish a connection.

**Solution:** Connection requires the gateway to be running and reachable:

1. Verify the gateway service is running on your computer
2. Ensure your devices are on the same network (or using proper remote access)
3. Check firewall settings aren't blocking the connection
4. Confirm the connection URL or host address is correct

### Connection Drops Frequently

**Problem:** Established connections disconnect unexpectedly or repeatedly.

**Solution:** Several factors can cause unstable connections:

1. **Network stability:** Check your WiFi or network connection quality
2. **Firewall interference:** Ensure security software isn't interrupting connections
3. **Timeout settings:** Long periods of inactivity may trigger automatic disconnection
4. **Server availability:** Verify the gateway service remains running

## Mobile App Connectivity Problems

### App Shows "Could Not Connect to Server"

**Problem:** The mobile app displays a persistent connection error overlay.

**Solution:** The app avoids loading unreachable addresses:

1. Verify the gateway is running and accessible from your mobile device
2. Check that both devices are on the same network
3. The app performs automatic connection checks - if it can't reach the server, it won't attempt to load
4. Try manually refreshing once the gateway is confirmed running

### Localhost or Loopback Address Issues

**Problem:** Connection URLs contain localhost, 127.0.0.1, or similar addresses that don't work from mobile.

**Solution:** Localhost addresses only work on the same device:

- The system automatically detects and ignores loopback addresses
- Ensure your gateway is configured to use your actual network address
- Check configuration for proper host settings that work across your network

### Canvas Not Loading on Connect

**Problem:** When the app connects, the expected canvas or interface doesn't appear.

**Solution:** The app checks connection availability before loading:

1. A TCP connection probe runs automatically to verify reachability
2. If the probe fails within 2.5 seconds, the default canvas shows instead
3. Once a stable connection is confirmed, the remote canvas will load
4. Check network connectivity if probes consistently fail

## Performance and Timeout Issues

### Request Timeouts

**Problem:** Commands or requests timeout before completing.

**Solution:** Timeouts protect against hanging requests:

1. **Default timeout values:** Probe checks use 8-second timeouts by default
2. **Adjust timeout settings:** Increase timeout values for slower connections or larger requests
3. **Network latency:** High latency connections may need longer timeouts
4. **Provider responsiveness:** Some providers respond slower than others during peak times

### Slow Probe Results

**Problem:** Authentication probes take a long time to complete.

**Solution:** Probes test actual API connectivity which requires network requests:

1. **Concurrency setting:** Adjust how many probes run simultaneously (default is 2)
2. **Number of targets:** More authentication profiles mean longer total probe time
3. **Provider latency:** Each provider's response time varies
4. **Token limits:** Probes use minimal tokens (8 by default) to speed up tests

### Format Errors

**Problem:** Probe status shows "format" errors.

**Solution:** Format errors indicate unexpected response structures:

1. This may indicate API incompatibility or provider changes
2. Verify you're using current software versions
3. Check if the provider recently updated their API
4. The authentication may be valid but the model test failed for other reasons

## Diagnostic Tools

### Running Connection Probes

Test authentication and connectivity by running probe checks:

- Probes send minimal test requests to verify each authentication method works
- Results show exact latency, status, and error details for each provider and profile
- Use provider filtering to test specific services
- Profile filtering lets you test individual authentication profiles

### Checking Overall Status

View comprehensive system status to identify issues:

- See which authentication methods are active and their source
- Check OAuth token expiration status
- View usage limits and current consumption
- Identify missing authentication for providers you're trying to use
- Review cooldown and disabled profile states

### Understanding Status Codes

Probe and connection checks return specific status indicators:

- **ok:** Authentication works correctly, provider responded successfully
- **auth:** Authentication failed - check credentials or token validity
- **rate_limit:** Temporarily blocked due to usage limits
- **billing:** Payment or account issues preventing access
- **timeout:** Request took too long, may indicate network or provider issues
- **format:** Unexpected response structure received
- **no_model:** No suitable model found for testing
- **unknown:** Unspecified error occurred

### Interpreting Error Messages

Error messages provide specific troubleshooting guidance:

- Messages are automatically sanitized to hide sensitive credentials
- Look for hints about which component failed (auth, network, provider)
- Check if multiple profiles show the same error (may indicate provider-wide issue)
- Compare working vs. failing profiles to identify configuration differences

## Getting Additional Help

If problems persist after trying these solutions:

1. Check the status display for detailed diagnostic information
2. Run authentication probes to identify exactly which providers and profiles work
3. Review configuration paths shown in status output to verify file locations
4. Examine error messages carefully for specific failure reasons
5. Ensure all required services are running and accessible