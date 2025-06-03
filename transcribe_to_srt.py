import sys
import os
import datetime
from faster_whisper import WhisperModel
from opencc import OpenCC

def format_timestamp(seconds):
    td = datetime.timedelta(seconds=seconds)
    total_seconds = int(td.total_seconds())
    hours = total_seconds // 3600
    minutes = (total_seconds % 3600) // 60
    secs = total_seconds % 60
    milliseconds = int((td.total_seconds() - total_seconds) * 1000)
    return f"{hours:02}:{minutes:02}:{secs:02},{milliseconds:03}"

def main():
    if len(sys.argv) < 2:
        print("❗ Please drag and drop an audio/video file onto this script, or run:\npython3 transcribe_to_srt.py <your_file>")
        sys.exit(1)

    input_path = sys.argv[1]
    if not os.path.isfile(input_path):
        print("❗ File not found:", input_path)
        sys.exit(1)

    base_name = os.path.splitext(os.path.basename(input_path))[0]
    output_srt = os.path.join(os.path.dirname(input_path), base_name + ".srt")

    print("🔄 Loading model...")
    model = WhisperModel("medium", device="cpu", compute_type="int8")
    cc = OpenCC('t2s')  # Traditional to Simplified

    print(f"🎧 Transcribing file: {input_path}")
    segments, info = model.transcribe(input_path, language="zh")
    segments = list(segments)

    print(f"💾 Writing subtitles to: {output_srt}")
    with open(output_srt, "w", encoding="utf-8") as f:
        for i, segment in enumerate(segments, start=1):
            simplified_text = cc.convert(segment.text.strip())
            start_time = format_timestamp(segment.start)
            end_time = format_timestamp(segment.end)
            f.write(f"{i}\n{start_time} --> {end_time}\n{simplified_text}\n\n")

    print("✅ Done! SRT file created:", output_srt)

if __name__ == "__main__":
    main()
