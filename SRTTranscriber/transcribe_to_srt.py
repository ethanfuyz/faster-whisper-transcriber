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


def main():
    if len(sys.argv) < 2:
        print("❗ Please provide a media file.")
        sys.exit(1)

    input_path = sys.argv[1]
    model_name = sys.argv[2] if len(sys.argv) > 2 else "medium"
    if not os.path.isfile(input_path):
        print("❗ File not found:", input_path)
        sys.exit(1)

    base_name = os.path.splitext(os.path.basename(input_path))[0]
    output_srt = os.path.join(os.path.dirname(input_path), base_name + "_" + model_name + ".srt")

    print("🔄 Loading model...")
    model = WhisperModel(model_name, device="cpu", compute_type="int8")
    cc = OpenCC('t2s')

    with open(output_srt, "w", encoding="utf-8") as f:
        for i, segment in enumerate(model.transcribe(input_path, language="zh", beam_size=5)[0], start=1):
            simplified_text = cc.convert(segment.text.strip())
            start_time = format_timestamp(segment.start)
            end_time = format_timestamp(segment.end)
            srt_block = f"{i}\n{start_time} --> {end_time}\n{simplified_text}\n"
            f.write(srt_block + "\n")

            print(f"END:{segment.end}")
            sys.stdout.flush()

    print(f"✅ Done! SRT saved to: {output_srt}")


if __name__ == "__main__":
    main()
