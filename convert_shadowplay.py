import os
import subprocess
import re
import threading
import time

# Function to convert video file using ffmpeg with hardware acceleration (NVENC)
def convert_video(input_file, output_file, lock):
    try:
        # Use ffmpeg with NVENC for hardware-accelerated encoding
        with lock:
            ffmpeg_command = [
                'ffmpeg', '-hwaccel', 'cuda',
                '-i', input_file,
                '-c:v', 'h264_nvenc',
                '-b:v', '5M',           # Adjust bitrate for 1080p medium quality
                '-maxrate', '6M',       # Adjust max bitrate accordingly
                '-bufsize', '3M',       # Adjust buffer size accordingly
                '-preset', 'medium',    # Preset for balanced speed vs. compression efficiency
                '-profile:v', 'high',
                '-level:v', '4.2',
                '-c:a', 'copy',
                output_file
            ]

            # Start ffmpeg process
            process = subprocess.Popen(ffmpeg_command, stderr=subprocess.PIPE, universal_newlines=True)

            # Parse ffmpeg stderr for progress
            duration = None
            for line in process.stderr:
                match_duration = re.match(r'Duration: (\d+):(\d+):(\d+)', line)
                if match_duration:
                    duration = int(match_duration.group(1)) * 3600 + int(match_duration.group(2)) * 60 + int(match_duration.group(3))

                match_time = re.match(r'time=(\d+):(\d+):(\d+)', line)
                if match_time and duration:
                    current_time = int(match_time.group(1)) * 3600 + int(match_time.group(2)) * 60 + int(match_time.group(3))
                    progress = (current_time / duration) * 100
                    print(f'\rConverting: {input_file} [{progress:.2f}%]', end='', flush=True)

            process.communicate()  # Wait for ffmpeg to finish
            print(f'\rConverting: {input_file} [100.00%]')  # Print completion message

            print(f"Converted: {input_file} -> {output_file}")
            return True
    except subprocess.CalledProcessError as e:
        print(f"Error converting {input_file}: {e}")
        return False

# Function to check if a filename matches the NVIDIA ShadowPlay naming convention
def is_shadowplay_clip(filename):
    # Example NVIDIA ShadowPlay naming pattern: Valorant 2022.10.04 - 02.01.44.10.DVR.mp4
    pattern = r'.*\d{4}\.\d{2}\.\d{2} - \d{2}\.\d{2}\.\d{2}\.\d{2}\.DVR\.mp4$'
    return re.match(pattern, filename) is not None

# Function to traverse directories recursively
def process_directory(directory, lock):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.mp4') and is_shadowplay_clip(file):
                input_file = os.path.join(root, file)
                output_file = os.path.join(root, f"{os.path.splitext(file)[0]}_small.mp4")

                # Print message before converting
                print(f"Converting: {input_file}")

                # Convert video using ffmpeg with NVENC
                if convert_video(input_file, output_file, lock):
                    # Delete original file if conversion successful
                    try:
                        os.remove(input_file)
                        print(f"Deleted original: {input_file}")
                    except OSError as e:
                        print(f"Error deleting {input_file}: {e}")

# Main function to start processing from the script's directory
def main():
    # Get the current directory where the script is located
    root_directory = os.path.dirname(os.path.realpath(__file__))
    print(f"Processing directory: {root_directory}")

    # Create a lock object for thread synchronization
    lock = threading.Lock()

    # Process the directory recursively
    process_directory(root_directory, lock)

if __name__ == "__main__":
    main()
