# SPDX SBOM for OpenClaw

**SPDX Version:** SPDX-2.3  
**Data License:** CC0-1.0  
**SPDX Identifier:** SPDXRef-DOCUMENT  
**Document Name:** OpenClaw Software Bill of Materials  
**Document Namespace:** https://github.com/man-oss/openclaw/sbom/spdx-2.3  
**Creator:** Tool: openclaw-sbom-generator  
**Created:** 2026-02-16T00:00:00Z

## Document Information

### Package: OpenClaw

**SPDX Identifier:** SPDXRef-Package-OpenClaw  
**Package Name:** openclaw  
**Package Version:** 2026.2.16  
**Package Supplier:** Person: Peter Steinberger  
**Package Download Location:** git+https://github.com/man-oss/openclaw.git  
**Files Analyzed:** true  
**Package Homepage:** https://github.com/openclaw/openclaw  
**Package Source Info:** Multi-channel AI gateway with extensible messaging integrations  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package License Comments:** Main project licensed under MIT License  
**Package Copyright Text:** Copyright (c) 2025 Peter Steinberger  
**Package Description:** Multi-channel AI gateway with extensible messaging integrations supporting Node.js, iOS, and Android platforms

**External References:**
- PACKAGE-MANAGER: npm (https://www.npmjs.com/package/openclaw)
- SECURITY: https://github.com/openclaw/openclaw/security

## Runtime Dependencies (Node.js)

### Core SDK Dependencies

**SPDXRef-Package-agentclientprotocol-sdk**  
**Package Name:** @agentclientprotocol/sdk  
**Package Version:** 0.14.1  
**Package License Declared:** NOASSERTION  
**Package License Concluded:** NOASSERTION  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-agentclientprotocol-sdk

**SPDXRef-Package-aws-sdk-bedrock**  
**Package Name:** @aws-sdk/client-bedrock  
**Package Version:** ^3.990.0  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-aws-sdk-bedrock

**SPDXRef-Package-buape-carbon**  
**Package Name:** @buape/carbon  
**Package Version:** 0.14.0  
**Package License Declared:** NOASSERTION  
**Package License Concluded:** NOASSERTION  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-buape-carbon

### CLI and Terminal Dependencies

**SPDXRef-Package-clack-prompts**  
**Package Name:** @clack/prompts  
**Package Version:** ^1.0.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-clack-prompts

**SPDXRef-Package-lydell-node-pty**  
**Package Name:** @lydell/node-pty  
**Package Version:** 1.2.0-beta.3  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Native dependency for terminal emulation  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-lydell-node-pty

### AI and Agent Framework Dependencies

**SPDXRef-Package-pi-agent-core**  
**Package Name:** @mariozechner/pi-agent-core  
**Package Version:** 0.52.12  
**Package License Declared:** NOASSERTION  
**Package License Concluded:** NOASSERTION  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-pi-agent-core

**SPDXRef-Package-pi-ai**  
**Package Name:** @mariozechner/pi-ai  
**Package Version:** 0.52.12  
**Package License Declared:** NOASSERTION  
**Package License Concluded:** NOASSERTION  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-pi-ai

**SPDXRef-Package-pi-coding-agent**  
**Package Name:** @mariozechner/pi-coding-agent  
**Package Version:** 0.52.12  
**Package License Declared:** NOASSERTION  
**Package License Concluded:** NOASSERTION  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-pi-coding-agent

**SPDXRef-Package-pi-tui**  
**Package Name:** @mariozechner/pi-tui  
**Package Version:** 0.52.12  
**Package License Declared:** NOASSERTION  
**Package License Concluded:** NOASSERTION  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-pi-tui

### Messaging Platform Integrations

**SPDXRef-Package-grammyjs-runner**  
**Package Name:** @grammyjs/runner  
**Package Version:** ^2.0.3  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Telegram bot framework runner  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-grammyjs-runner

**SPDXRef-Package-grammyjs-throttler**  
**Package Name:** @grammyjs/transformer-throttler  
**Package Version:** ^1.2.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-grammyjs-throttler

**SPDXRef-Package-grammy**  
**Package Name:** grammy  
**Package Version:** ^1.40.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Telegram bot API framework  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-grammy

**SPDXRef-Package-slack-bolt**  
**Package Name:** @slack/bolt  
**Package Version:** ^4.6.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Slack bot framework  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-slack-bolt

**SPDXRef-Package-slack-web-api**  
**Package Name:** @slack/web-api  
**Package Version:** ^7.14.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-slack-web-api

**SPDXRef-Package-baileys**  
**Package Name:** @whiskeysockets/baileys  
**Package Version:** 7.0.0-rc.9  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** WhatsApp Web API library  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-baileys

**SPDXRef-Package-line-bot-sdk**  
**Package Name:** @line/bot-sdk  
**Package Version:** ^10.6.0  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-line-bot-sdk

**SPDXRef-Package-larksuiteoapi**  
**Package Name:** @larksuiteoapi/node-sdk  
**Package Version:** ^1.59.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Lark/Feishu integration  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-larksuiteoapi

**SPDXRef-Package-discord-api-types**  
**Package Name:** discord-api-types  
**Package Version:** ^0.38.39  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-discord-api-types

### Network and Service Discovery

**SPDXRef-Package-homebridge-ciao**  
**Package Name:** @homebridge/ciao  
**Package Version:** ^1.3.5  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Package Comments:** mDNS/Bonjour service discovery  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-homebridge-ciao

**SPDXRef-Package-https-proxy-agent**  
**Package Name:** https-proxy-agent  
**Package Version:** ^7.0.6  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-https-proxy-agent

**SPDXRef-Package-undici**  
**Package Name:** undici  
**Package Version:** ^7.22.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** HTTP/1.1 client  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-undici

**SPDXRef-Package-ws**  
**Package Name:** ws  
**Package Version:** ^8.19.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** WebSocket client and server  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-ws

### Web and Content Processing

**SPDXRef-Package-mozilla-readability**  
**Package Name:** @mozilla/readability  
**Package Version:** ^0.6.0  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Package Comments:** Article content extraction  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-mozilla-readability

**SPDXRef-Package-playwright-core**  
**Package Name:** playwright-core  
**Package Version:** 1.58.2  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Package Comments:** Browser automation library  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-playwright-core

**SPDXRef-Package-linkedom**  
**Package Name:** linkedom  
**Package Version:** ^0.18.12  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** DOM implementation for Node.js  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-linkedom

**SPDXRef-Package-markdown-it**  
**Package Name:** markdown-it  
**Package Version:** ^14.1.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-markdown-it

**SPDXRef-Package-pdfjs-dist**  
**Package Name:** pdfjs-dist  
**Package Version:** ^5.4.624  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Package Comments:** PDF rendering library  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-pdfjs-dist

### Media Processing

**SPDXRef-Package-sharp**  
**Package Name:** sharp  
**Package Version:** ^0.34.5  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Package Comments:** High-performance image processing (native dependency)  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-sharp

**SPDXRef-Package-node-edge-tts**  
**Package Name:** node-edge-tts  
**Package Version:** ^1.2.10  
**Package License Declared:** NOASSERTION  
**Package License Concluded:** NOASSERTION  
**Package Comments:** Text-to-speech functionality  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-node-edge-tts

**SPDXRef-Package-file-type**  
**Package Name:** file-type  
**Package Version:** ^21.3.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-file-type

### Utilities and Framework

**SPDXRef-Package-typebox**  
**Package Name:** @sinclair/typebox  
**Package Version:** 0.34.48  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** JSON Schema type builder (overridden version)  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-typebox

**SPDXRef-Package-ajv**  
**Package Name:** ajv  
**Package Version:** ^8.18.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** JSON Schema validator  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-ajv

**SPDXRef-Package-zod**  
**Package Name:** zod  
**Package Version:** ^4.3.6  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** TypeScript schema validation  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-zod

**SPDXRef-Package-chalk**  
**Package Name:** chalk  
**Package Version:** ^5.6.2  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-chalk

**SPDXRef-Package-commander**  
**Package Name:** commander  
**Package Version:** ^14.0.3  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** CLI framework  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-commander

**SPDXRef-Package-dotenv**  
**Package Name:** dotenv  
**Package Version:** ^17.3.1  
**Package License Declared:** BSD-2-Clause  
**Package License Concluded:** BSD-2-Clause  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-dotenv

**SPDXRef-Package-express**  
**Package Name:** express  
**Package Version:** ^5.2.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-express

**SPDXRef-Package-jiti**  
**Package Name:** jiti  
**Package Version:** ^2.6.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-jiti

**SPDXRef-Package-json5**  
**Package Name:** json5  
**Package Version:** ^2.2.3  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-json5

**SPDXRef-Package-yaml**  
**Package Name:** yaml  
**Package Version:** ^2.8.2  
**Package License Declared:** ISC  
**Package License Concluded:** ISC  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-yaml

**SPDXRef-Package-tslog**  
**Package Name:** tslog  
**Package Version:** ^4.10.2  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-tslog

**SPDXRef-Package-croner**  
**Package Name:** croner  
**Package Version:** ^10.0.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Cron job scheduling  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-croner

**SPDXRef-Package-chokidar**  
**Package Name:** chokidar  
**Package Version:** ^5.0.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** File system watcher  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-chokidar

**SPDXRef-Package-proper-lockfile**  
**Package Name:** proper-lockfile  
**Package Version:** ^4.1.2  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-proper-lockfile

### Data Processing and Storage

**SPDXRef-Package-sqlite-vec**  
**Package Name:** sqlite-vec  
**Package Version:** 0.1.7-alpha.2  
**Package License Declared:** Apache-2.0 AND MIT  
**Package License Concluded:** Apache-2.0 AND MIT  
**Package Comments:** Vector search SQLite extension  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-sqlite-vec

**SPDXRef-Package-jszip**  
**Package Name:** jszip  
**Package Version:** ^3.10.1  
**Package License Declared:** (MIT OR GPL-3.0-or-later)  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-jszip

**SPDXRef-Package-tar**  
**Package Name:** tar  
**Package Version:** 7.5.9  
**Package License Declared:** ISC  
**Package License Concluded:** ISC  
**Package Comments:** Overridden version for security  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-tar

**SPDXRef-Package-long**  
**Package Name:** long  
**Package Version:** ^5.3.2  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-long

### Presentation and Display

**SPDXRef-Package-cli-highlight**  
**Package Name:** cli-highlight  
**Package Version:** ^2.1.11  
**Package License Declared:** ISC  
**Package License Concluded:** ISC  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-cli-highlight

**SPDXRef-Package-qrcode-terminal**  
**Package Name:** qrcode-terminal  
**Package Version:** ^0.12.0  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-qrcode-terminal

**SPDXRef-Package-osc-progress**  
**Package Name:** osc-progress  
**Package Version:** ^0.3.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-osc-progress

**SPDXRef-Package-signal-utils**  
**Package Name:** signal-utils  
**Package Version:** ^0.21.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-signal-utils

## Development Dependencies

**SPDXRef-Package-grammyjs-types**  
**Package Name:** @grammyjs/types  
**Package Version:** ^3.24.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-grammyjs-types

**SPDXRef-Package-lit-labs-signals**  
**Package Name:** @lit-labs/signals  
**Package Version:** ^0.2.0  
**Package License Declared:** BSD-3-Clause  
**Package License Concluded:** BSD-3-Clause  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-lit-labs-signals

**SPDXRef-Package-lit-context**  
**Package Name:** @lit/context  
**Package Version:** ^1.1.6  
**Package License Declared:** BSD-3-Clause  
**Package License Concluded:** BSD-3-Clause  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-lit-context

**SPDXRef-Package-lit**  
**Package Name:** lit  
**Package Version:** ^3.3.2  
**Package License Declared:** BSD-3-Clause  
**Package License Concluded:** BSD-3-Clause  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-lit

**SPDXRef-Package-types-express**  
**Package Name:** @types/express  
**Package Version:** ^5.0.6  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-types-express

**SPDXRef-Package-types-markdown-it**  
**Package Name:** @types/markdown-it  
**Package Version:** ^14.1.2  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-types-markdown-it

**SPDXRef-Package-types-node**  
**Package Name:** @types/node  
**Package Version:** ^25.2.3  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-types-node

**SPDXRef-Package-types-proper-lockfile**  
**Package Name:** @types/proper-lockfile  
**Package Version:** ^4.1.4  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-types-proper-lockfile

**SPDXRef-Package-types-qrcode-terminal**  
**Package Name:** @types/qrcode-terminal  
**Package Version:** ^0.12.2  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-types-qrcode-terminal

**SPDXRef-Package-types-ws**  
**Package Name:** @types/ws  
**Package Version:** ^8.18.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-types-ws

**SPDXRef-Package-typescript**  
**Package Name:** typescript  
**Package Version:** ^5.9.3  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-typescript

**SPDXRef-Package-typescript-native-preview**  
**Package Name:** @typescript/native-preview  
**Package Version:** 7.0.0-dev.20260215.1  
**Package License Declared:** Apache-2.0  
**Package License Concluded:** Apache-2.0  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-typescript-native-preview

**SPDXRef-Package-tsx**  
**Package Name:** tsx  
**Package Version:** ^4.21.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-tsx

**SPDXRef-Package-vitest**  
**Package Name:** vitest  
**Package Version:** ^4.0.18  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-vitest

**SPDXRef-Package-vitest-coverage-v8**  
**Package Name:** @vitest/coverage-v8  
**Package Version:** ^4.0.18  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-vitest-coverage-v8

**SPDXRef-Package-ollama**  
**Package Name:** ollama  
**Package Version:** ^0.6.3  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-ollama

**SPDXRef-Package-oxfmt**  
**Package Name:** oxfmt  
**Package Version:** 0.32.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-oxfmt

**SPDXRef-Package-oxlint**  
**Package Name:** oxlint  
**Package Version:** ^1.47.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-oxlint

**SPDXRef-Package-oxlint-tsgolint**  
**Package Name:** oxlint-tsgolint  
**Package Version:** ^0.13.0  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-oxlint-tsgolint

**SPDXRef-Package-rolldown**  
**Package Name:** rolldown  
**Package Version:** 1.0.0-rc.4  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-rolldown

**SPDXRef-Package-tsdown**  
**Package Name:** tsdown  
**Package Version:** ^0.20.3  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Relationship:** SPDXRef-Package-OpenClaw DEV_DEPENDENCY_OF SPDXRef-Package-tsdown

## Peer Dependencies (Optional)

**SPDXRef-Package-napi-rs-canvas**  
**Package Name:** @napi-rs/canvas  
**Package Version:** ^0.1.89  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Optional native canvas implementation  
**Relationship:** SPDXRef-Package-OpenClaw OPTIONAL_DEPENDENCY_OF SPDXRef-Package-napi-rs-canvas

**SPDXRef-Package-node-llama-cpp**  
**Package Name:** node-llama-cpp  
**Package Version:** 3.15.1  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Optional local LLM support  
**Relationship:** SPDXRef-Package-OpenClaw OPTIONAL_DEPENDENCY_OF SPDXRef-Package-node-llama-cpp

## Security-Related Overrides

The following packages have version overrides enforced for security compliance (defined in `pnpm.overrides`):

**SPDXRef-Package-fast-xml-parser-override**  
**Package Name:** fast-xml-parser  
**Package Version:** 5.3.4  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Security override to prevent XXE vulnerabilities  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-fast-xml-parser-override

**SPDXRef-Package-form-data-override**  
**Package Name:** form-data  
**Package Version:** 2.5.4  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Comments:** Security override  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-form-data-override

**SPDXRef-Package-qs-override**  
**Package Name:** qs  
**Package Version:** 6.14.2  
**Package License Declared:** BSD-3-Clause  
**Package License Concluded:** BSD-3-Clause  
**Package Comments:** Security override to prevent prototype pollution  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-qs-override

**SPDXRef-Package-tough-cookie-override**  
**Package Name:** tough-cookie  
**Package Version:** 4.1.3  
**Package License Declared:** BSD-3-Clause  
**Package License Concluded:** BSD-3-Clause  
**Package Comments:** Security override for cookie parsing vulnerabilities  
**Relationship:** SPDXRef-Package-OpenClaw DEPENDS_ON SPDXRef-Package-tough-cookie-override

## Mobile Platform Components

### iOS Application

**SPDXRef-Package-OpenClaw-iOS**  
**Package Name:** OpenClaw iOS  
**Package Version:** 2026.2.16  
**Package License Declared:** MIT  
**Package License Concluded:** MIT  
**Package Source Info:** Native iOS application located in `apps/ios/`  
**Package Description:** iOS client application for OpenClaw AI gateway  
**Files Analyzed:** true  
**Built With:** Swift, Xcode  
**Build System:** XcodeGen (project.yml configuration)  
**Relationship