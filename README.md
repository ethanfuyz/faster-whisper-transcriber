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
# 1. Navigate to the project directory
cd <your-path-to>/faster-whisper-transcriber

# 2. Create a virtual environment under the project path
python3 -m venv .venv

# 3. Activate the virtual environment
source .venv/bin/activate

# 4. Upgrade pip
pip install --upgrade pip

# 5. Install required packages
pip install faster-whisper
pip install opencc-python-reimplemented
```

---

## 🚀 How to Use

1. Open Terminal and navigate to the project directory
2. Activate the virtual environment:
   ```bash
   source .venv/bin/activate
   ```
3. Run the transcription script and **drag your media file into Terminal**, then press `Enter`:
   ```bash
   python3 <your-path-to>/faster-whisper-transcriber/transcribe_to_srt.py [drag your file here]
   ```
   Or drag a file onto SRT Transcriber.app.
   
   Or right-click the file and choose Open With → SRT Transcriber.app to transcribe with one click.

   The AppleScript for **SRT Transcriber.app** is shown below:
   ```applescript
   on run {input, parameters}
       set filePath to POSIX path of item 1 of input

       -- Replace <your-path-to> with the actual path to your project
       set shellScript to "cd <your-path-to>/faster-whisper-transcriber && source .venv/bin/activate && python3 transcribe_to_srt.py \"" & filePath & "\"; exec zsh"
    
       tell application "Terminal"
           activate
           do script shellScript
       end tell

       return input
   end run
   ```
4. A new `.srt` file will be created in the same folder, named like:
   ```
   YourFile.srt
   ```

---

## 🎬 Export to Final Cut Pro (FCPXML)

1. Go to: [Subtitle Tool & Converter](https://editingtools.io/subtitles/)
2. Paste the generated `.srt` content into the input box
3. Select **.fcpxml**
4. Select **25fps** (or another frame rate as needed)
6. Click **Generate** then **Download**