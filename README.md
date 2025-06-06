# Faster Whisper Transcriber

A lightweight transcription tool based on [`faster-whisper`](https://github.com/guillaumekln/faster-whisper). It transcribes audio or video files into Simplified Chinese `.srt` subtitle files and saves them to the same directory.

Designed for macOS users working with Final Cut Pro or similar tools.

---

## ✅ Features

- Transcribes audio/video files to `.srt` subtitle
- Converts subtitles to Simplified Chinese using OpenCC
- Output is saved next to the original media file
- Works seamlessly with the FCPX subtitle tool: [Crossub FCPXML Exporter](https://orzass.com/crossub/srt/63)

---

## ⚙️ Environment Setup (macOS)

You'll need:

- Python 3.x
- pip3
- A virtual environment
- `faster-whisper` (for transcription)
- `opencc` (for Traditional → Simplified conversion)

### 🔧 Installation Steps

```bash
# 1. Create a virtual environment
python3 -m venv ~/.venvs/faster-whisper-env

# 2. Activate the virtual environment
source ~/.venvs/faster-whisper-env/bin/activate

# 3. Upgrade pip
pip install --upgrade pip

# 4. Install required packages
pip install faster-whisper
pip install opencc-python-reimplemented
```

---

## 🚀 How to Use

1. Open Terminal
2. Activate the virtual environment:
   ```bash
   source ~/.venvs/faster-whisper-env/bin/activate
   ```
3. Run the transcription script and **drag your media file into Terminal**, then press `Enter`:
   ```bash
   python3 ~/Documents/faster-whisper-transcriber/transcribe_to_srt.py [drag your file here]
   ```
   or Drag a file onto SRT Transcriber.app, or right-click the file and choose Open With → SRT Transcriber.app to transcribe with one click.
4. A new `.srt` file will be created in the same folder, named like:
   ```
   YourFile.srt
   ```

---

## 🎬 Export to Final Cut Pro (FCPXML)

1. Go to: [https://orzass.com/crossub/srt/63](https://orzass.com/crossub/srt/63)
2. Paste the generated `.srt` content into the input box
3. Select **25fps** (or another frame rate as needed)
4. Click **Export** to download `.fcpxml`
5. Import the `.fcpxml` into Final Cut Pro

---

## 📄 License

MIT License

---

Feel free to modify or extend this project to automate FCPXML generation or integrate it with video editing pipelines.
