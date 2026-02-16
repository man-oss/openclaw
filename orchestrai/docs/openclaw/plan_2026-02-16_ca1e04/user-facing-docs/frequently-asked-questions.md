# Frequently Asked Questions

## General Questions

### What is OpenClaw?

OpenClaw is a personal AI assistant that runs on your own devices. It connects to the messaging platforms you already use—like WhatsApp, Telegram, Slack, Discord, and many others—so you can interact with your AI assistant wherever you're most comfortable chatting.

### How is OpenClaw different from other AI assistants?

Unlike cloud-based AI assistants, OpenClaw runs locally on your own computer or server. This means you have complete control over your data, can customize the behavior to your needs, and can connect it to all your favorite messaging apps in one place. It's designed to feel like a personal assistant that's always available on your terms.

### What messaging platforms does OpenClaw support?

OpenClaw works with WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage (via BlueBubbles), Microsoft Teams, Matrix, Zalo, and includes a built-in web chat interface. You can connect multiple platforms at once and your assistant will respond across all of them.

### Do I need technical knowledge to use OpenClaw?

Basic computer familiarity is helpful for the initial setup. OpenClaw includes a guided setup wizard that walks you through the installation process step by step. Once configured, using OpenClaw is as simple as sending messages in your favorite chat app.

### Is OpenClaw free?

OpenClaw itself is free and open-source. However, you'll need an AI service subscription (like Anthropic's Claude or OpenAI's ChatGPT) to power the assistant's responses. These are separate services that you subscribe to directly.

## Setup and Installation

### What do I need to get started?

You need a computer running macOS, Linux, or Windows (via WSL2), and Node.js version 22 or higher installed. You'll also need a subscription to either Anthropic Claude or OpenAI ChatGPT for the AI functionality.

### How long does setup take?

Most users complete the setup process in 15-30 minutes using the guided wizard. The wizard helps you configure your AI service, connect your messaging platforms, and get everything running smoothly.

### Can I run OpenClaw on a remote server?

Yes! Many users run OpenClaw on a small Linux server or VPS to keep it available 24/7. Your computer or phone can then connect to it remotely, and you can still use device-specific features when needed.

### What happens during the onboarding wizard?

The wizard guides you through: connecting your AI service (Anthropic or OpenAI), setting up the control center, choosing which messaging platforms to enable, and configuring any optional features you want to use. You can always change these settings later.

### Do I need to keep my computer running all the time?

For the assistant to respond to messages, yes, the computer running OpenClaw needs to be on and connected to the internet. Many users solve this by running OpenClaw on a dedicated server or always-on device.

## Privacy and Security

### Where is my data stored?

All your conversations and data stay on your own device or server where you installed OpenClaw. Nothing is sent to OpenClaw's creators. The only external service that sees your messages is the AI provider you chose (Anthropic or OpenAI), which is necessary for generating responses.

### Can anyone message my assistant?

By default, OpenClaw uses a pairing system for security. When someone new tries to message your assistant, they receive a pairing code. You then approve them using a simple command, and only after approval can they have full conversations. This prevents random people from accessing your assistant.

### How do I control who can use my assistant?

You can configure allowlists for each messaging platform, specifying exactly which users or phone numbers are permitted to interact with your assistant. You can also set up different access levels for different people if needed.

### Is my conversation history private?

Yes, your full conversation history is stored locally on your device. OpenClaw doesn't send any analytics or conversation data to external servers (except to your chosen AI provider for generating responses).

### What security features does OpenClaw have?

OpenClaw includes pairing codes for new contacts, allowlist controls, optional password protection for the web interface, and the ability to run each group conversation in an isolated sandbox for additional security.

## Platform Compatibility

### Which operating systems are supported?

OpenClaw runs on macOS, Linux, and Windows (using WSL2—Windows Subsystem for Linux version 2). For the best experience on Windows, we strongly recommend using WSL2 rather than native Windows.

### Can I use OpenClaw on my phone?

While the main assistant runs on a computer or server, there are companion apps for iOS and Android. These apps let you use features like voice commands, camera access, and screen sharing with your assistant, while the processing still happens on your main device.

### What are the minimum system requirements?

You need Node.js version 22.12.0 or higher. A modern computer with at least 4GB of RAM is recommended. For the AI models themselves, requirements depend on your chosen provider—cloud-based services like Anthropic and OpenAI work on any internet-connected system.

### Does it work on Raspberry Pi?

Yes, OpenClaw can run on Raspberry Pi and similar devices. This is a popular choice for users who want a low-power, always-on assistant without keeping a full computer running.

### Can I access my assistant from multiple devices?

Yes, you can connect to your OpenClaw instance from multiple devices using the web interface, companion apps, or any of the connected messaging platforms. All devices will interact with the same assistant and share the conversation history.

## AI Models and Capabilities

### Which AI models can I use?

OpenClaw supports Anthropic's Claude models and OpenAI's GPT models. You can use either service through their subscription plans or API access. The recommended setup uses Anthropic Claude Opus for the best balance of capability and reliability.

### Can I switch between different AI models?

Yes, you can change which AI model you're using at any time. You can even set up automatic fallback, so if your primary model is unavailable, OpenClaw switches to a backup model automatically.

### What can the assistant actually do?

Your assistant can answer questions, help with research, write content, analyze documents and images, browse websites, run code, manage files, set scheduled reminders, and much more. The exact capabilities depend on which tools you enable.

### Can the assistant browse the internet?

Yes, when you enable the browser tool, your assistant can visit websites, read articles, fill out forms, and interact with web pages on your behalf.

### Does it remember previous conversations?

Yes, each messaging platform and chat maintains its own conversation history. Your assistant remembers context from earlier in the conversation, making interactions feel more natural and continuous.

### Can I give it access to my files?

You control which files and folders your assistant can access through configuration settings. You can grant read-only access, full editing permissions, or restrict access entirely based on your needs.

## Cost and Subscriptions

### How much does OpenClaw cost?

OpenClaw itself is completely free. You only pay for your AI service subscription (Anthropic Claude or OpenAI ChatGPT), which you purchase directly from those providers. Pricing varies by provider and usage level.

### What's the difference between subscription and API access?

Subscription plans (like Claude Pro) give you unlimited or high-volume usage for a flat monthly fee. API access charges you per message based on usage. For regular use, subscriptions are often more economical.

### Does OpenClaw charge per message?

No, OpenClaw doesn't charge anything. Your AI provider may charge per message if you're using API access rather than a subscription plan.

### Can I use the free tier of ChatGPT or Claude?

OpenClaw requires API access or OAuth authentication, which typically isn't available on free tiers. You'll need either a subscription plan (like Claude Pro or ChatGPT Plus) or an API key with usage credits.

### Are there hidden costs?

No. OpenClaw is open-source and free. The only costs are your AI service subscription and any standard expenses like electricity or internet for running the software. There are no surprise fees or premium features.

## Features and Functionality

### Can the assistant make phone calls or send SMS?

OpenClaw focuses on messaging platforms and doesn't directly make phone calls. However, it can send messages through any connected platform, including SMS if you set up the Android companion app with SMS permissions.

### Does it support voice commands?

Yes, the macOS and mobile companion apps support voice interaction. You can speak to your assistant and receive spoken responses using the Voice Wake and Talk Mode features.

### Can I schedule tasks or reminders?

Yes, you can set up scheduled tasks using the built-in scheduling system. Your assistant can send you reminders, run automated tasks, or perform actions at specific times.

### Can multiple people share one assistant?

Yes, you can configure OpenClaw to respond to multiple users. Each person can have their own conversation history while sharing the same assistant instance. You can also set up different assistants with different capabilities for different users if needed.

### Does it work in group chats?

Yes, OpenClaw works in group conversations on supported platforms. You can configure whether it responds to every message or only when specifically mentioned.

### Can it send and receive images?

Yes, OpenClaw can receive images from you, analyze them, and send images back. This works across most messaging platforms. The assistant can describe what's in photos, read text from images, and more.

## Troubleshooting and Support

### What if OpenClaw stops responding?

First, check that the OpenClaw service is still running. You can restart it using the command for your system. If problems persist, the built-in diagnostic tool can help identify common issues.

### How do I update to a new version?

OpenClaw includes an update command that handles the upgrade process. It will download the latest version and migrate your settings automatically. Your conversation history and configuration are preserved during updates.

### Where can I get help?

The documentation website includes detailed guides for all features. There's also an active Discord community where users and developers help each other. For specific issues, you can check the troubleshooting guide or ask in the community.

### What if a messaging platform stops working?

Each messaging platform has its own troubleshooting section in the documentation. Common issues include needing to reconnect your account or adjusting permissions. The diagnostic tool can often identify and fix these automatically.

### Can I reset everything and start over?

Yes, you can reset your OpenClaw installation to start fresh. This clears all settings and conversation history while keeping the software itself installed. You'll go through the setup wizard again as if it's a new installation.

### How do I report bugs?

You can report bugs through the GitHub issue tracker. Include details about what you were trying to do, what happened instead, and any error messages you saw. The community and developers monitor these reports regularly.

## Customization and Advanced Features

### Can I customize the assistant's personality?

Yes, OpenClaw includes configuration files where you can define your assistant's personality, writing style, and behavioral preferences. You can make it formal, casual, technical, creative, or anything in between.

### What are "skills" in OpenClaw?

Skills are pre-built capabilities you can add to your assistant, like specific knowledge domains, specialized tools, or automated workflows. You can install skills from the skill registry or create your own.

### Can I run custom code or scripts?

Yes, when properly configured, your assistant can execute code and run scripts on your system. This is a powerful feature that requires careful security configuration to use safely.

### How do I add new messaging platforms?

The extension system allows adding support for additional messaging platforms. Some extensions are available from the community, and you can develop your own using the plugin SDK.

### Can I have different assistants for different purposes?

Yes, you can set up multiple isolated assistants (called agents) with different capabilities, personalities, and tool access. You can route different messaging accounts or platforms to different assistants.

## Comparison with Other Solutions

### How is this different from ChatGPT Plus?

ChatGPT Plus gives you web access to ChatGPT. OpenClaw runs on your own device and connects ChatGPT (or Claude) to all your messaging apps, gives you advanced automation, local file access, and complete customization of behavior and capabilities.

### Why not just use Claude or ChatGPT's official apps?

Official apps are great, but they're limited to one platform and one interface. OpenClaw brings AI assistance to every messaging app you use, adds powerful automation and tool capabilities, and gives you complete control over privacy and data.

### Is this like running a chatbot?

OpenClaw is more sophisticated than a typical chatbot. It maintains context across conversations, can use complex tools, access local files and systems, and integrates deeply with your devices—not just responding to preset commands.

### Can't I do this with browser extensions?

Browser extensions only work while your browser is open and can't integrate with messaging apps, your file system, or device features. OpenClaw works 24/7 and has much deeper integration with your systems and apps.

### What about other self-hosted AI assistants?

OpenClaw is specifically designed as a personal, multi-channel assistant with a focus on messaging integration and practical daily use. It prioritizes ease of setup, real-world messaging platform support, and a polished experience over raw technical flexibility.