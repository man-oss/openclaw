# How to Manage AI Models and Providers

OpenClaw allows you to connect to different AI services and manage which AI models you want to use. This guide will help you set up authentication, add providers, configure models, and manage advanced settings.

## Understanding Providers and Models

A **provider** is an AI service (like Anthropic, OpenAI, or others) that offers AI models. Each provider requires authentication before you can use their models. Once authenticated, you can select which specific models to use for your tasks.

## Adding Authentication

### Choosing Your Authentication Method

Before you can use AI models, you need to authenticate with the provider. Different providers support different authentication methods:

- **Setup Token**: For Anthropic users who have the Claude CLI installed
- **Paste Token**: Manually paste an API token or key
- **OAuth**: Log in through your web browser (provider-dependent)

### Adding Your First Provider

To add a new provider and set up authentication:

1. Run the interactive setup to add authentication
2. Select your provider from the list (e.g., Anthropic)
3. Choose your preferred authentication method
4. Follow the prompts to complete authentication

#### Using Anthropic Setup Token

If you're using Anthropic and have the Claude CLI installed:

1. First, run `claude setup-token` in your terminal and copy the token
2. Start the authentication process
3. Select "Anthropic" as your provider
4. Choose "setup-token (claude)" as the method
5. Paste your token when prompted

The system will save your authentication and make Anthropic models available.

#### Using Manual Token Entry

For any provider that uses API tokens:

1. Start the authentication process
2. Select your provider (or choose "custom" to enter a provider name)
3. Choose "paste token" as the method
4. Paste your API token when prompted
5. Optionally set an expiration time for the token (e.g., "365d" for 365 days, "12h" for 12 hours)

You can create a custom profile name for your token, which is useful if you have multiple accounts with the same provider.

### Managing Multiple Profiles

You can have multiple authentication profiles for the same provider. This is helpful if you have:

- Different API keys for different projects
- Both personal and work accounts
- Tokens with different permission levels

Each profile gets a unique identifier. When adding authentication, you can specify a custom profile name, or use the default naming (e.g., "anthropic:manual").

### Token Expiration

When adding tokens manually, you can specify when they expire:

- Choose whether the token expires when prompted
- Enter a duration like "365d" (365 days), "30d" (30 days), or "12h" (12 hours)
- The system will track expiration and warn you when tokens need renewal

## Viewing Available Models

### Listing Configured Models

To see which models are currently configured and ready to use, view your model list. This shows:

- Model names and their providers
- Which models you have authentication for
- Aliases you've created for quick access
- Tags for organization

### Discovering All Available Models

To see every model that OpenClaw knows about, even if you haven't configured them yet:

1. Request the full model catalog
2. Browse models by provider
3. Check which ones require authentication

You can filter this list to show only:

- Models from a specific provider
- Models running locally on your computer

### Understanding Model Availability

Each model in the list shows whether you can currently use it. A model is available when:

- You have valid authentication for its provider
- The authentication hasn't expired
- You have the necessary permissions

## Creating Model Aliases

Aliases let you create short, memorable names for models you use frequently.

### Adding an Alias

To create an alias:

1. Choose a short name for your alias (e.g., "fast", "creative", "default")
2. Specify which model it should point to
3. The alias becomes available immediately

For example, you might create an alias called "fast" that points to a specific Claude model, then use "fast" in your commands instead of typing the full model name.

### Viewing Your Aliases

To see all your current aliases, list them to view:

- The alias name
- Which model it points to

### Removing an Alias

To delete an alias you no longer need, specify the alias name. The underlying model remains available; only the shortcut is removed.

### Alias Rules

- Each alias can only point to one model
- Each model can have multiple aliases
- Aliases must be unique—you can't have two aliases with the same name
- Alias names are normalized automatically (spaces and special characters are handled)

## Configuring Fallback Models

Fallback models provide redundancy. If your primary model is unavailable (due to rate limits, service outages, or authentication issues), OpenClaw automatically tries the next model in your fallback list.

### Adding Fallback Models

To add a model to your fallback list:

1. Specify the model you want to add
2. It gets added to the end of your fallback sequence

You can add multiple fallback models. They'll be tried in the order you added them.

### Viewing Your Fallback Configuration

Check your current fallback list to see:

- Which models are in the sequence
- The order they'll be tried

### Removing a Fallback Model

To remove a specific model from your fallback list, specify which model to remove. The remaining fallback models stay in place.

### Clearing All Fallbacks

To remove all fallback models at once and start fresh, clear the entire fallback list.

### Fallback Strategy

When your primary model fails:

1. OpenClaw tries the first fallback model
2. If that fails, it tries the second fallback model
3. This continues through your entire fallback list
4. If all fallbacks fail, you'll receive an error message

## Managing Multiple Providers

You can authenticate with multiple providers simultaneously. This lets you:

- Switch between providers for different tasks
- Use specialized models from different services
- Maintain redundancy if one provider has issues

### Setting a Default Model

When you authenticate with a provider, you can optionally set one of their models as your default. This is the model that will be used when you don't specify one explicitly.

To make this happen automatically during authentication, include the set-default option when logging in.

## Provider-Specific Features

### Provider Notes

After authentication, some providers display important notes about:

- Usage limits or quotas
- Special features available
- Configuration recommendations

These notes help you get the most out of each provider.

### OAuth for Remote Environments

If you're running OpenClaw on a remote server or VPS:

- OAuth flows are automatically adapted for remote access
- You can authenticate through your local browser
- The system handles the connection securely between your browser and remote server

## Filtering and Searching

### Filter by Provider

When viewing models, you can filter to show only models from a specific provider. This helps when you:

- Want to compare models from one service
- Are configuring a new provider
- Need to verify authentication for a specific provider

### Local Models Only

If you're running AI models locally on your computer, you can filter to show only local models. This hides cloud-based services and shows just what's running on your machine.

## Output Formats

When viewing models or aliases, you can choose different output formats:

- **Standard format**: Easy-to-read tables with all information
- **JSON format**: Machine-readable data for scripts and automation
- **Plain format**: Simple text output for parsing or piping to other commands

## Troubleshooting Authentication Issues

### Token Validation Errors

If your token is rejected:

- Verify you copied the complete token without extra spaces
- Check the token hasn't expired
- Ensure the token is for the correct provider
- Confirm the token has the necessary permissions

### Provider Not Found

If a provider isn't recognized:

- Check the provider name spelling
- Verify you've installed the necessary plugin for that provider
- View installed plugins to confirm availability

### Authentication Expired

When authentication expires:

- You'll see a warning when viewing models
- Re-authenticate using the same process as initial setup
- Your previous configuration (aliases, fallbacks) remains intact

### Model Not Available

If a configured model shows as unavailable:

- Verify your authentication is current and valid
- Check if the provider has deprecated or renamed the model
- Ensure your API key has permissions for that specific model
- Review any provider-specific rate limits or restrictions

## Configuration Updates

Whenever you make changes to authentication, aliases, or fallbacks:

- Your configuration file is automatically updated
- Changes take effect immediately
- A confirmation message shows what was changed
- Previous configurations are preserved (the system only modifies what you changed)

## Best Practices

### Security

- Never share your API tokens or setup tokens
- Set appropriate expiration times for tokens
- Use separate profiles for different security contexts
- Regularly rotate your authentication credentials

### Organization

- Use descriptive alias names that indicate the model's purpose
- Tag models by category (fast, accurate, cost-effective, etc.)
- Configure fallbacks from most-preferred to least-preferred
- Document which profiles are for which purposes

### Reliability

- Always configure at least one fallback model
- Authenticate with multiple providers for redundancy
- Monitor token expiration dates
- Test your configuration after making changes

### Performance

- Choose local models for privacy-sensitive tasks
- Use faster models for simple tasks, more capable models for complex ones
- Create aliases for your most-used models to save typing
- Consider cost when selecting default models

## Working with Custom Providers

If you're using a custom or self-hosted AI provider:

1. During authentication setup, choose "custom" as the provider type
2. Enter your provider's identifier (the system normalizes it automatically)
3. Complete authentication using your provider's token or key
4. The provider becomes available alongside built-in providers

Custom providers work the same way as built-in ones—you can create aliases, set fallbacks, and manage multiple profiles.