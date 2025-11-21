#!/usr/bin/env bash
set -euo pipefail

# Install Flutter into $HOME/flutter if not already present
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

# Ensure web support and cache web artifacts
flutter --version
flutter config --enable-web
flutter precache --web

# Get dependencies and build the web output
flutter pub get
flutter build web --release

# At this point build/web will contain the static site for Netlify's publish folder.