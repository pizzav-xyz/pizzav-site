#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Builds a Hugo site hosted on a Cloudflare Worker.
#
# The Cloudflare Worker automatically installs Node.js dependencies.
#------------------------------------------------------------------------------

main() {

  DART_SASS_VERSION=1.97.1
  GO_VERSION=1.25.5
  HUGO_VERSION=0.154.2
  NODE_VERSION=24.12.0

  export TZ=Europe/Oslo

  # Install Dart Sass
  echo "Installing Dart Sass ${DART_SASS_VERSION}..."
  rm -f "dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz"
  curl -sLJO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz"
  if [ -d "${HOME}/.local/dart-sass" ]; then
    rm -rf "${HOME}/.local/dart-sass"
  fi
  mkdir -p "${HOME}/.local"
  tar -C "${HOME}/.local" -xf "dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz"
  rm "dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz"
  export PATH="${HOME}/.local/dart-sass:${PATH}"

  # Install Go
  echo "Installing Go ${GO_VERSION}..."
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
  curl -sLJO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  if [ -d "${HOME}/.local/go" ]; then
    rm -rf "${HOME}/.local/go"
  fi
  mkdir -p "${HOME}/.local"
  tar -C "${HOME}/.local" -xf "go${GO_VERSION}.linux-amd64.tar.gz"
  rm "go${GO_VERSION}.linux-amd64.tar.gz"
  export PATH="${HOME}/.local/go/bin:${PATH}"

  # Install Hugo
  echo "Installing Hugo ${HUGO_VERSION}..."
  rm -f "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
  curl -sLJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
  if [ -d "${HOME}/.local/hugo" ]; then
    rm -rf "${HOME}/.local/hugo"
  fi
  mkdir -p "${HOME}/.local"
  tar -C "${HOME}/.local" -xf "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
  rm "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
  export PATH="${HOME}/.local/hugo:${PATH}"

  # Install Node.js
  echo "Installing Node.js ${NODE_VERSION}..."
  rm -f "node-v${NODE_VERSION}-linux-x64.tar.xz"
  curl -sLJO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"
  if [ -d "${HOME}/.local/node-v${NODE_VERSION}-linux-x64" ]; then
    rm -rf "${HOME}/.local/node-v${NODE_VERSION}-linux-x64"
  fi
  mkdir -p "${HOME}/.local"
  tar -C "${HOME}/.local" -xf "node-v${NODE_VERSION}-linux-x64.tar.xz"
  rm "node-v${NODE_VERSION}-linux-x64.tar.xz"
  export PATH="${HOME}/.local/node-v${NODE_VERSION}-linux-x64/bin:${PATH}"

  # Verify installations
  echo "Verifying installations..."
  echo Dart Sass: "$(sass --version)"
  echo Go: "$(go version)"
  echo Hugo: "$(hugo version)"
  echo Node.js: "$(node --version)"

  # Configure Git
  echo "Configuring Git..."
  git config core.quotepath false
  if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
    git fetch --unshallow
  fi

  # Build the site
  echo "Building the site..."
  hugo --gc --minify

}

set -euo pipefail
main "$ @"