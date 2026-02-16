# AI Models and Provider Management

OpenClaw provides comprehensive support for multiple AI providers, allowing you to connect to different AI services and manage how they're used across your projects.

## Supported AI Providers

OpenClaw works with the following AI providers:

### Anthropic
Access Claude models through Anthropic's API. This provider supports text generation and conversation capabilities.

### OpenAI
Connect to GPT models and DALL-E for both text and image generation tasks.

### AWS Bedrock
Use AI models hosted on Amazon Web Services, providing access to multiple model families through a unified AWS interface.

### Google AI
Access Google's AI models including Gemini for various AI tasks.

### Azure OpenAI
Connect to OpenAI models hosted on Microsoft Azure infrastructure.

### Ollama
Work with locally-hosted open-source models through the Ollama platform.

### LM Studio
Use models running on your local machine through LM Studio.

## Authentication Methods

OpenClaw supports multiple ways to authenticate with AI providers, giving you flexibility in how you manage credentials.

### API Keys
The most common authentication method involves providing API keys directly. You can set these through environment variables or configuration files.

### OAuth Authentication
Some providers support OAuth-based authentication, allowing you to authenticate through web-based login flows.

### AWS Profiles
When using AWS Bedrock, you can authenticate using AWS credential profiles configured on your system. This method leverages your existing AWS CLI configuration.

### Authentication Priority Order

When multiple authentication methods are available, OpenClaw follows a specific priority order to determine which credentials to use:

1. **Explicitly specified credentials** - Credentials you provide directly for a specific operation
2. **Environment variables** - API keys and tokens set in your environment
3. **Profile-based credentials** - Stored authentication profiles
4. **Default configurations** - System-wide default settings

## Model Selection

### Primary Model Configuration

You can specify which AI model to use for different types of tasks. OpenClaw distinguishes between:

- **Text generation models** - For conversation, code generation, and text-based tasks
- **Image generation models** - For creating or editing images

### Model Aliases

Instead of typing full model names each time, you can use short, memorable aliases. Common aliases include:

- **sonnet** - Maps to Claude models
- **gpt** - Maps to GPT models
- **opus** - Maps to specific Claude variants
- **haiku** - Maps to faster, lighter Claude models

These aliases make it easier to switch between models without remembering exact model identifiers.

## Fallback Strategies

OpenClaw includes intelligent fallback mechanisms to ensure your work continues even when a specific model is unavailable.

### Automatic Fallbacks

When your primary model encounters an issue, OpenClaw can automatically try alternative models:

1. **Same provider fallback** - First tries other models from the same provider
2. **Cross-provider fallback** - If that fails, attempts equivalent models from other providers
3. **Capability matching** - Ensures fallback models support the same features you're using

### Image Generation Fallbacks

Image generation has its own fallback system, since these models have different capabilities than text models. If your preferred image model isn't available, OpenClaw will try other image-capable models in order of preference.

### Configuring Fallback Behavior

You can control fallback behavior by:

- Specifying which models should be considered as fallbacks
- Disabling automatic fallbacks if you prefer explicit control
- Setting provider preferences to prioritize certain services

## Model Discovery and Status

### Checking Available Models

You can view which models are currently accessible based on your authentication setup. This helps you:

- Verify your credentials are working
- See which models you have access to
- Identify any configuration issues

### Authentication Status Overview

OpenClaw provides visibility into your authentication status across all providers:

- **Configured** - Provider has credentials set up
- **Active** - Provider is authenticated and working
- **Inactive** - Provider configured but not currently accessible
- **Not configured** - No credentials provided for this provider

### Model Registry

OpenClaw maintains an internal registry of supported models, including:

- Model capabilities (text, images, code, etc.)
- Provider information
- Authentication requirements
- Default settings

## Usage Tracking

OpenClaw tracks your AI model usage to help you:

- Monitor API consumption
- Understand which models you use most
- Identify potential cost optimization opportunities

### What Gets Tracked

- Number of requests per model
- Tokens consumed (for text models)
- Images generated (for image models)
- Success and failure rates

### Viewing Usage Statistics

You can review your usage patterns through built-in reporting commands that show:

- Total usage across all providers
- Per-model breakdown
- Historical trends
- Error rates by provider

## Rate Limiting

To prevent exceeding provider limits and manage costs, OpenClaw includes rate limiting features:

### Provider Rate Limits

Each AI provider has their own rate limits. OpenClaw respects these limits by:

- Queuing requests when approaching limits
- Spacing out rapid consecutive requests
- Providing feedback when rate limits are reached

### Custom Rate Controls

You can set your own rate limits that are stricter than provider defaults to:

- Control costs by limiting API calls
- Distribute usage across multiple projects
- Prevent accidental overuse

## Configuration Management

### Global Configuration

Set system-wide defaults that apply across all your projects:

- Default model selections
- Preferred providers
- Authentication credentials
- Fallback preferences

### Project-Specific Settings

Override global settings for individual projects when you need:

- Different models for different types of work
- Specific provider preferences
- Custom authentication per project

### Configuration Scanning

OpenClaw can scan your environment to detect:

- Available authentication credentials
- Configured providers
- Potential configuration conflicts
- Missing required settings

This automatic detection helps ensure your setup is correct and identifies issues before they affect your work.

## Best Practices

### Credential Security

- Store API keys in environment variables rather than configuration files
- Use profile-based authentication when available
- Regularly rotate API keys
- Never commit credentials to version control

### Provider Selection

- Choose providers based on your specific use case
- Consider cost differences between providers
- Test fallback configurations before relying on them
- Keep backup providers configured

### Model Selection

- Use faster, cheaper models for development and testing
- Reserve premium models for production work
- Configure appropriate fallbacks for critical operations
- Regularly review which models best fit your needs

### Cost Management

- Set rate limits aligned with your budget
- Monitor usage regularly
- Use local models (Ollama, LM Studio) for development when possible
- Configure fallbacks that consider cost differences

## Troubleshooting

### Authentication Issues

If you're having trouble connecting to a provider:

- Verify your API keys are current and valid
- Check that credentials are set in the expected location
- Ensure you have the necessary permissions on the provider's platform
- Review authentication status to identify which provider is affected

### Model Availability

If a model isn't accessible:

- Confirm you have access to that model through your provider account
- Check if the model name or alias is spelled correctly
- Verify the provider is properly authenticated
- Review any regional restrictions that might apply

### Fallback Not Working

If fallback models aren't being used:

- Ensure fallback configuration is enabled
- Verify alternative models are properly configured
- Check that fallback models support the features you're using
- Review error messages to understand why primary model failed