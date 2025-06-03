# Faster Whisper Transcriber

A simple transcription tool based on [`faster-whisper`](https://github.com/guillaumekln/faster-whisper), designed for macOS users working with audio/video files. It transcribes input media and generates a **Simplified Chinese `.srt` subtitle file** in the same directory as the original file.

## ✅ Features

- Transcribes audio/video to `.srt` subtitle
- Converts to Simplified Chinese using OpenCC
- Outputs the subtitle file to the same folder
- Compatible with [FCPX subtitle tool](https://orzass.com/crossub/srt/63) to generate `.fcpxml` files for Final Cut Pro

---

## ⚙️ Environment Setup (macOS Terminal)

Ensure you have the following installed:

- Python 3.x
- pip3
- virtual environment support
- `faster-whisper` for transcription
- `opencc` for Traditional-to-Simplified Chinese conversion

### 🔧 Step-by-step installation

```bash
# 1. Create and activate a virtual environment
python3 -m venv ~/.venvs/faster-whisper-env
source ~/.venvs/faster-whisper-env/bin/activate

# 2. Upgrade pip
pip install --upgrade pip

# 3. Install faster-whisper (for Whisper transcription)
pip install faster-whisper

# 4. Install OpenCC (for converting subtitles to Simplified Chinese)
pip install opencc-python-reimplemented
```

---

## 🚀 How to Use

1. Place your Python script `transcribe_to_srt.py` in a folder, e.g. `~/Documents/faster-whisper-transcriber/`.
2. Use the provided shell script `run_transcribe.sh` to automate activation and transcription.
3. Drag your video/audio file into the terminal when prompted.
4. The script will generate an `.srt` subtitle file named like `YourFile_Simple.srt`.

Example:

```bash
./run_transcribe.sh
# [Drag and drop your file here] then press Enter
```

---

## 🎬 Export to FCPX

After generating the `.srt`, go to:

👉 [https://orzass.com/crossub/srt/63](https://orzass.com/crossub/srt/63)

Then:

1. Paste your `.srt` content into the webpage.
2. Select **25fps** or the frame rate you need.
3. Click **Export** to download an FCPXML subtitle file compatible with Final Cut Pro.

---

## 📝 License

MIT License

---

Feel free to extend this tool with automatic `.fcpxml` export or GUI integration.
