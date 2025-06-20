# Faster Whisper Transcriber

A lightweight transcription tool based on [faster-whisper](https://github.com/guillaumekln/faster-whisper). It transcribes audio or video files into Simplified Chinese `.srt` subtitle files and saves them to the same directory.

Designed for macOS users working with Final Cut Pro or similar tools.

---

## ✅ Features

- Transcribes audio/video files to `.srt` subtitle
- Converts subtitles to Simplified Chinese using OpenCC
- Output is saved next to the original media file
- Works seamlessly with the FCPX subtitle tool: [Subtitle Tool & Converter](https://editingtools.io/subtitles/)

---

## ⚙️ Environment Setup (macOS)

You'll need:

- Python 3.x
- pip3
- A virtual environment
- `faster-whisper` (for transcription)
- `opencc` (for Traditional → Simplified conversion)
- `ffmpeg` (for handling audio/video files; faster-whisper depends on it to process media input. Without it, transcription may fail. Install via Homebrew: brew install ffmpeg)

### 🔧 Virtual Environment Installation Steps

```bash
# 1. Create a virtual environment at your desired path (replace <path-to-venv> with your chosen directory)
#    Example:
python3 -m venv ~/.venv/srt_transcriber_env

# 2. Activate the virtual environment (adjust path accordingly)
#    Example:
source ~/.venv/srt_transcriber_env/bin/activate

# 3. Upgrade pip inside the virtual environment
pip install --upgrade pip

# 4. Install required Python packages
pip install faster-whisper
pip install opencc-python-reimplemented
```

---

## 🚀 How to Use

1. Open Terminal and navigate to the project directory
2. Activate the virtual environment:
   ```bash
   source ~/.venv/srt_transcriber_env/bin/activate
   ```
3. Run the transcription script and **drag your media file into Terminal**, then press `Enter`:
   ```bash
   python3 <your-path-to>/faster-whisper-transcriber/transcribe_to_srt.py [drag your file here]
   ```
   Alternatively, you can:
   - Drag a media file directly onto **SRT Transcriber.app**
   - Or right-click the file and choose **Open With → SRT Transcriber.app** for one-click transcription

   The AppleScript example for **SRT Transcriber.app** is shown below:
   ```applescript
   on run {input, parameters}
       set filePath to POSIX path of item 1 of input

       -- Make sure to replace <your-path-to> with the absolute path to your project directory
       set shellScript to "cd ~/Documents/faster-whisper-transcriber && source ~/.venv/srt_transcriber_env/bin/activate && python3 transcribe_to_srt.py \"" & filePath & "\"; exec zsh"
    
       tell application "Terminal"
           activate
           do script shellScript
       end tell

       return input
   end run
   ```
4. A new `.srt` file will be created in the same folder

---


## 🎬 Export to Final Cut Pro (FCPXML)

1. Go to: [Subtitle Tool & Converter](https://editingtools.io/subtitles/)
2. Paste the generated `.srt` content into the input box
3. Select **.fcpxml**
4. Select **25fps** (or another frame rate as needed)
5. Click **Generate** then **Download**