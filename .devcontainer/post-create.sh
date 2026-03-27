#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Work IQ Daily Workflow development environment..."

# Install gh-aw extension (GitHub Agentic Workflows)
echo "==> Installing gh-aw CLI extension..."
gh extension install github/gh-aw

# Install Work IQ CLI globally via npm
echo "==> Installing Work IQ CLI (@microsoft/workiq)..."
npm install -g @microsoft/workiq

# Accept Work IQ EULA non-interactively (set WORKIQ_AUTO_ACCEPT_EULA=true in env, or run manually)
if [ "${WORKIQ_AUTO_ACCEPT_EULA:-false}" = "true" ]; then
  workiq accept-eula || true
fi

# Install Work IQ plugin for GitHub Copilot CLI (if copilot CLI is available)
if command -v copilot &>/dev/null; then
  echo "==> Installing Work IQ plugin for GitHub Copilot CLI..."
  copilot /plugin marketplace add microsoft/work-iq || true
  copilot /plugin install workiq@work-iq || true
fi

echo ""
echo "==> Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Authenticate with GitHub:  gh auth login"
echo "  2. Authenticate with Work IQ: workiq login"
echo "  3. Compile agentic workflows: gh aw compile --all"
echo "  4. See available workflows:   gh aw list"
echo ""
