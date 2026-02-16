# How to Configure Authentication Profiles

Authentication profiles let you connect OpenClaw to your AI providers. You can set up multiple profiles for the same provider, switch between them, and control which one gets used first.

## Getting Started

Before configuring authentication, you'll need:
- An account with your chosen AI provider (like Anthropic, OpenAI, etc.)
- Either an API key from that provider, or the ability to complete an OAuth login
- OpenClaw installed and ready to use

## Adding Your First Authentication Profile

### Interactive Setup

The easiest way to add authentication is through the interactive setup:

1. Open your terminal and run the login command
2. Select your AI provider from the list
3. Choose your authentication method (API key, OAuth, or token)
4. Follow the prompts to complete authentication

The system will guide you through each step, showing you available providers and explaining each option.

### For Anthropic Users

If you're using Anthropic's Claude, you have a special option using setup tokens:

1. First, run the Claude CLI command to generate a setup token
2. Copy the token that appears
3. Run OpenClaw's setup token command
4. When prompted, confirm you've copied the token
5. Paste your token when asked

The system will validate your token and create your authentication profile automatically.

### For Other Providers

For providers other than Anthropic:

1. Start the authentication process
2. When asked to select a provider, choose "custom" and enter your provider's name
3. Select "paste token" as your method
4. Enter a name for your profile (or use the suggested default)
5. Choose whether your token expires:
   - If yes, specify how long it lasts (like "365d" for one year, "30d" for 30 days)
   - If no, skip this step
6. Paste your token when prompted

Your authentication profile will be created and ready to use.

## Managing Multiple Profiles

You can create multiple authentication profiles for the same provider. This is useful when:
- You have different accounts or workspaces
- You want backup credentials if one expires
- You're testing with different rate limits or quotas

Each profile needs a unique name. The system suggests names based on your provider and authentication method, but you can customize these to anything that helps you remember which is which.

## Understanding Profile Selection

When you have multiple profiles for the same provider, OpenClaw needs to know which one to use. By default, it tries profiles in the order they were created. You can customize this order to prioritize specific profiles.

### Viewing Current Profile Order

To see which profile will be tried first for a provider:

1. Check the current order for your provider
2. The system shows you the list of profiles in priority order
3. The first profile in the list is tried first, then the second, and so on

### Changing Profile Priority

To change which profile gets used first:

1. Decide the order you want (list your profile names from highest to lowest priority)
2. Update the order for your provider
3. The system validates that all profile names exist and belong to the correct provider

Now when you use that provider, OpenClaw will try your profiles in the new order.

### Resetting to Default Order

If you want to go back to the original order:

1. Clear the custom order for your provider
2. The system removes your override
3. Profiles will be used in their default order again

## Setting a Default Model

When you add authentication for a provider, you may want to also set which model to use by default. During the login process, you'll see an option to set the default model automatically. If you skip this, you can always configure your default model later through the configuration settings.

## Working with Token Expiration

Some authentication tokens expire after a period of time. Here's how to handle expiration:

### When Setting Up a Token

If your token expires, specify the expiration period when creating the profile:
- Use format like "365d" for days, "12h" for hours, or "30m" for minutes
- The system tracks when your token will expire
- You'll know ahead of time when you need to refresh

### When a Token Expires

When an authentication token expires:
1. OpenClaw will automatically try the next profile in your priority list
2. If that one also fails, it continues down the list
3. If all profiles fail, you'll need to update at least one profile with fresh credentials

To update an expired token, simply add a new authentication profile using the same process as your initial setup. You can reuse the same profile name to replace the old credentials.

## Troubleshooting Authentication Issues

### Profile Not Found

If the system says a profile doesn't exist:
- Double-check the profile name spelling
- Verify you're using the correct provider name
- Make sure you've actually created the profile (run the add command again if needed)

### Wrong Provider Error

If you try to set profile order and get a "wrong provider" message:
- Verify the profile belongs to the provider you specified
- Each profile is tied to one provider and can't be used with others
- Create a new profile for the correct provider instead

### Cannot Update Configuration

If the system can't save your changes:
- Make sure no other OpenClaw process is running
- Check that you have write permissions for your configuration directory
- Wait a moment and try again (another process may have locked the file)

### Interactive Mode Required

Some authentication methods require an interactive terminal:
- Make sure you're running the command directly in your terminal
- Avoid running through scripts or automation that don't support interactive input
- If you're on a remote server, ensure your SSH session supports interactive input

### Remote Environment Limitations

If you're working on a remote server or cloud environment:
- OAuth flows may behave differently than on local machines
- The system automatically detects remote environments and adjusts
- You may be given special instructions for completing authentication remotely

### Invalid Configuration File

If the system reports configuration problems:
- Review the specific error messages shown
- Check the configuration file path mentioned in the error
- Fix any syntax or structure issues in your configuration
- Run the authentication command again after fixing the configuration

## Understanding Authentication Methods

Different providers offer different ways to authenticate:

**API Keys**: A static key you copy from your provider's dashboard. Simple and works everywhere, but doesn't expire automatically.

**OAuth**: A secure login flow where you grant permission through your provider's website. More secure and can be revoked, but requires a browser.

**Setup Tokens**: Special tokens generated by provider CLI tools. Combines convenience with security for supported providers.

Choose the method that best fits your workflow and security requirements. You can always add profiles with different methods later.

## Per-Agent Configuration

Authentication profiles can be configured separately for different agents. When working with multiple agents:
- Each agent can have its own set of profiles
- Profile priority order can differ between agents
- This lets you use different credentials for different projects or contexts

When managing profiles, you can specify which agent you're configuring. If you don't specify, the system uses your default agent.

## Next Steps

After setting up your authentication profiles:
- Test your connection by making a request to your AI provider
- Add additional profiles as backups or for different use cases
- Configure your preferred model if you haven't already
- Adjust profile priority order based on your usage patterns

Your authentication profiles are saved securely and will be used automatically whenever you interact with your AI providers through OpenClaw.