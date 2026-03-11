#!/usr/bin/env python3
"""Convert VGA pixel data to PNG for Tic-Tac-Toe game - handles multiple frames"""

from PIL import Image
import os

WIDTH = 640
HEIGHT = 480


def convert_file(filename):
    """Convert a single pixel file to PNG"""
    if not os.path.exists(filename):
        print(f"File not found: {filename}")
        return False

    img = Image.new("RGB", (WIDTH, HEIGHT))
    pixels = img.load()
    pixel_count = 0

    with open(filename, "r") as f:
        for line_num, line in enumerate(f):
            if line_num >= WIDTH * HEIGHT:
                break
            parts = line.strip().split(",")
            if len(parts) >= 3:
                x = line_num % WIDTH
                y = line_num // WIDTH
                r = int(parts[0]) * 17
                g = int(parts[1]) * 17
                b = int(parts[2]) * 17
                pixels[x, y] = (r, g, b)
                pixel_count += 1

    # Save with same name but .png extension
    png_name = filename.replace(".txt", ".png")
    img.save(png_name)
    print(f"Saved {png_name} ({WIDTH}x{HEIGHT}, {pixel_count} pixels)")
    return True


def convert_all():
    """Convert all pixel files (pixels_0.txt through pixels_9.txt and pixels.txt)"""
    # Convert numbered frames
    for i in range(10):
        filename = f"pixels_{i}.txt"
        if os.path.exists(filename):
            convert_file(filename)

    # Also convert single frame if exists
    if os.path.exists("pixels.txt"):
        convert_file("pixels.txt")


if __name__ == "__main__":
    convert_all()
