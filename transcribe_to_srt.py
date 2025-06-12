import sys
import os
import datetime
import subprocess
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

def get_duration_ms(filepath):
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries",
             "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", filepath],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        duration_sec = float(result.stdout.decode().strip())
        return int(duration_sec * 1000)
    except Exception as e:
        print("⚠️ Could not determine duration:", e)
        return None

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
    model = WhisperModel("large-v3", device="cpu", compute_type="int8")
    cc = OpenCC('t2s')

    print(f"🎧 Transcribing: {os.path.basename(input_path)}")
    total_duration_ms = get_duration_ms(input_path)

    if total_duration_ms is None:
        print("❗ Failed to get duration. Progress percentage won't be shown.")
        total_duration_ms = 0

    with open(output_srt, "w", encoding="utf-8") as f:
        for i, segment in enumerate(model.transcribe(input_path, language="zh", beam_size=5)[0], start=1):
            simplified_text = cc.convert(segment.text.strip())
            start_time = format_timestamp(segment.start)
            end_time = format_timestamp(segment.end)
            srt_block = f"{i}\n{start_time} --> {end_time}\n{simplified_text}\n"

            f.write(srt_block + "\n")

            # Calculate and print progress (overwrite same line)
            percent = int((segment.end * 1000) / total_duration_ms * 100) if total_duration_ms else 0
            print(f"\r🔁 Progress: [{percent:3}%]", end="", flush=True)

    print(f"\n✅ Done! SRT file saved to: {output_srt}")

if __name__ == "__main__":
    main()
