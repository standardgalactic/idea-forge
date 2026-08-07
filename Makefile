.PHONY: help init lint test format clean

help:
	@echo "Available targets:"
	@echo "  make init       - Install development dependencies"
	@echo "  make lint       - Run ShellCheck on all shell scripts"
	@echo "  make test       - Run test suite"
	@echo "  make format     - Format shell scripts with shfmt"
	@echo "  make clean      - Remove temporary files"

init:
	@echo "Checking for required tools..."
	@command -v shellcheck >/dev/null 2>&1 || { echo "Installing shellcheck..."; sudo apt-get update && sudo apt-get install -y shellcheck; }
	@command -v shfmt >/dev/null 2>&1 || { echo "Installing shfmt..."; GO111MODULE=on go install mvdan.cc/sh/v3/cmd/shfmt@latest; }
	@echo "Development dependencies ready."

lint:
	@echo "Running ShellCheck..."
	@find . -type f \( -name "*.sh" -o -path "*/bin/forge" \) -not -path "./.git/*" -exec shellcheck -x {} +
	@echo "Linting complete."

test:
	@echo "Running test suite..."
	@bash tests/run_tests.sh
	@echo "Tests complete."

format:
	@echo "Formatting shell scripts..."
	@find . -type f \( -name "*.sh" -o -path "*/bin/forge" \) -not -path "./.git/*" -exec shfmt -w -i 4 -bn -ci {} +
	@echo "Formatting complete."

clean:
	@echo "Cleaning temporary files..."
	@find . -type f -name "*.bak" -delete
	@find . -type f -name "*~" -delete
	@echo "Clean complete."
