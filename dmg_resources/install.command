#!/bin/bash

echo "🚀 Starting setup for SRT Transcriber..."

# 1. Xcode CLI
if ! xcode-select -p &>/dev/null; then
  echo "🔧 Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "👉 Please rerun this script after tools installed."
  exit 1
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  echo "🧪 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 3. ffmpeg
if ! command -v ffmpeg &>/dev/null; then
  echo "🎞 Installing ffmpeg..."
  brew install ffmpeg
fi

# 4. Python
if [ ! -d "$HOME/.venv/srt_transcriber_env" ]; then
  echo "📦 Creating virtual environment..."
  python3 -m venv ~/.venv/srt_transcriber_env
else
  echo "✅ Virtual environment already exists, skipping creation."
fi

source ~/.venv/srt_transcriber_env/bin/activate
pip install --upgrade pip
pip install faster-whisper opencc-python-reimplemented

echo "✅ All done!"
