#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Work IQ Daily Workflow development environment..."

# Install gh-aw extension (GitHub Agentic Workflows)
echo "==> Installing gh-aw CLI extension..."
gh extension install github/gh-aw

# Install Work IQ CLI globally via npm
echo "==> Installing Work IQ CLI (@microsoft/workiq)..."
npm install -g @microsoft/workiq

# Accept Work IQ EULA non-interactively
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
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Next steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Authenticate with GitHub:"
echo "       gh auth login"
echo ""
echo "  2. Authenticate with Work IQ (interactive — required once):"
echo "       workiq login"
echo ""
echo "     After login, extract your refresh token for use in CI:"
echo "       cat ~/.workiq/config.json | grep -i refresh"
echo "     Then add it as a GitHub secret named WORKIQ_REFRESH_TOKEN."
echo "     See README.md#obtaining-a-workiq-refresh-token for full instructions."
echo ""
echo "  3. Compile agentic workflows (.md → .lock.yml):"
echo "       gh aw init"
echo "       gh aw compile --all"
echo ""
echo "  4. See available workflows:"
echo "       gh aw list"
echo ""
echo "  5. Test a workflow in isolation (no side effects):"
echo "       gh aw trial .github/workflows/issue-triage.md"
echo ""
