#!/bin/bash

set -euo pipefail

# CtrlSpec Installation Script
# Downloads documentation templates and sets up symlinks for AI coding assistants

GITHUB_REPO="ctrleditor/ctrlspec"
GITHUB_BRANCH="main"
GITHUB_RAW="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

log_step() {
    echo -e "\n${GREEN}→${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          echo "unknown";;
    esac
}

# Create directory if it doesn't exist
mkdir_safe() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_info "Created directory: $1"
    fi
}

# Create symlink safely (backup existing, create new)
symlink_safe() {
    local target="$1"
    local link="$2"
    local link_name=$(basename "$link")
    local link_dir=$(dirname "$link")

    mkdir_safe "$link_dir"

    if [ -L "$link" ]; then
        # Symlink exists, check if it points to the right place
        local existing=$(readlink "$link")
        if [ "$existing" = "$target" ]; then
            log_info "Symlink already correct: $link_name"
            return 0
        else
            log_warn "Symlink exists but points elsewhere, updating: $link_name"
            rm "$link"
        fi
    elif [ -e "$link" ]; then
        # File exists, backup it
        local backup="${link}.backup.$(date +%s)"
        log_warn "File exists, creating backup: $link_name → $backup"
        mv "$link" "$backup"
    fi

    ln -s "$target" "$link"
    log_info "Created symlink: $link_name → $(basename $target)"
}

# Try to find CtrlSpec source directory (for local installation)
find_ctrlspec_source() {
    # Check if we're running from the CtrlSpec repo
    if [ -f "./docs/llm.md" ] && [ -f "./.mcp.json" ]; then
        echo "."
        return 0
    fi

    # Check parent directories
    local current="$(pwd)"
    while [ "$current" != "/" ]; do
        if [ -f "$current/docs/llm.md" ] && [ -f "$current/.mcp.json" ]; then
            echo "$current"
            return 0
        fi
        current="$(dirname "$current")"
    done

    return 1
}

# Copy file from local source
copy_file() {
    local source="$1"
    local dest="$2"
    local filename=$(basename "$dest")

    mkdir_safe "$(dirname "$dest")"

    if [ ! -f "$source" ]; then
        log_error "Source file not found: $source"
        return 1
    fi

    # Resolve to absolute paths for comparison
    local src_abs=$(cd "$(dirname "$source")" && pwd)/$(basename "$source")
    local dst_abs=$(cd "$(dirname "$dest")" 2>/dev/null && pwd)/$(basename "$dest") || echo "$dest"

    # If source and dest are the same, skip copy
    if [ "$src_abs" = "$dst_abs" ]; then
        log_info "File already in place: $filename"
        return 0
    fi

    # Don't overwrite root README.md
    if [ "$(basename "$dest")" = "README.md" ] && [ "$(dirname "$dest")" = "." ]; then
        if [ -f "$dest" ]; then
            log_warn "Root README.md exists, skipping"
            return 0
        fi
    fi

    cp "$source" "$dest"
    log_info "Copied: $filename"
    return 0
}

# Download file from GitHub
download_file() {
    local source="$1"
    local dest="$2"
    local filename=$(basename "$dest")

    mkdir_safe "$(dirname "$dest")"

    # Don't overwrite root README.md
    if [ "$(basename "$dest")" = "README.md" ] && [ "$(dirname "$dest")" = "." ]; then
        if [ -f "$dest" ]; then
            log_warn "Root README.md exists, skipping"
            return 0
        fi
    fi

    if command -v curl &> /dev/null; then
        if curl -fsSL "$source" -o "$dest"; then
            log_info "Downloaded: $filename"
            return 0
        fi
    elif command -v wget &> /dev/null; then
        if wget -q "$source" -O "$dest"; then
            log_info "Downloaded: $filename"
            return 0
        fi
    else
        log_error "Neither curl nor wget found. Cannot download files."
        return 1
    fi

    log_error "Failed to download: $filename"
    return 1
}

# Smart file getter: use local source if available, otherwise download
get_file() {
    local remote_path="$1"
    local dest="$2"

    if [ -n "${CTRLSPEC_SOURCE:-}" ]; then
        local source_file="${CTRLSPEC_SOURCE}/${remote_path}"
        copy_file "$source_file" "$dest"
    else
        local github_url="${GITHUB_RAW}/${remote_path}"
        download_file "$github_url" "$dest"
    fi
}

# Main installation
main() {
    local os=$(detect_os)
    local project_root="$(pwd)"

    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║       CtrlSpec Installation             ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Project root: $project_root"
    echo "OS detected: $os"
    echo ""

    # Try to detect local CtrlSpec source
    if CTRLSPEC_SOURCE=$(find_ctrlspec_source 2>/dev/null); then
        log_info "Using local CtrlSpec source: $CTRLSPEC_SOURCE"
        export CTRLSPEC_SOURCE
    else
        log_info "Installing from GitHub (https://github.com/ctrleditor/ctrlspec)"
    fi
    echo ""

    # Step 1: Create docs directory
    log_step "Setting up documentation structure"
    mkdir_safe "$project_root/docs"

    # Step 2: Download documentation templates
    log_step "Downloading documentation templates"

    local docs=(
        "llm.md"
        "requirements.md"
        "architecture.md"
        "constraints.md"
        "decisions.md"
        "testing.md"
        "deployment.md"
    )

    for doc in "${docs[@]}"; do
        get_file "docs/$doc" "$project_root/docs/$doc"
    done

    # Step 3: Create symlinks for AI tools
    log_step "Creating symlinks for AI coding assistants"

    # Claude Code
    symlink_safe "docs/llm.md" "$project_root/CLAUDE.md"

    # Generic agents
    symlink_safe "docs/llm.md" "$project_root/AGENTS.md"

    # Cursor
    symlink_safe "docs/llm.md" "$project_root/.cursorrules"

    # Cursor directory structure
    symlink_safe "../docs/llm.md" "$project_root/.cursor/rules"
    symlink_safe "../.mcp.json" "$project_root/.cursor/mcp.json"

    # Claude Code config
    symlink_safe "../../.mcp.json" "$project_root/.config/claude/mcp_config.json"

    # Step 4: Download MCP configuration
    log_step "Setting up MCP configuration"
    get_file ".mcp.json" "$project_root/.mcp.json"

    # Step 5: Summary
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║    Installation Complete!              ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Documentation files installed:"
    for doc in "${docs[@]}"; do
        echo "  • docs/$doc"
    done
    echo ""
    echo "Symlinks created:"
    echo "  • CLAUDE.md (for Claude Code)"
    echo "  • AGENTS.md (for other agents)"
    echo "  • .cursorrules (for Cursor)"
    echo "  • .cursor/rules (for Cursor IDE)"
    echo "  • .cursor/mcp.json (Cursor MCP config)"
    echo "  • .config/claude/mcp_config.json (Claude Code MCP config)"
    echo ""
    echo "Next steps:"
    echo "  1. Edit docs/requirements.md with your project details"
    echo "  2. Update docs/architecture.md with your system design"
    echo "  3. Fill in other templates as needed"
    echo "  4. Commit: git add docs/ && git commit -m 'docs: add CtrlSpec documentation'"
    echo ""
    echo "Documentation: https://github.com/ctrleditor/ctrlspec"
    echo ""
}

# Run main installation
main "$@"
