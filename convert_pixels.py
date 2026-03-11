#!/usr/bin/env python3
"""Convert VGA pixel data to PNG for Tic-Tac-Toe game"""

from PIL import Image

WIDTH = 640
HEIGHT = 480


def convert_to_png():
    img = Image.new("RGB", (WIDTH, HEIGHT))
    pixels = img.load()

    with open("pixels.txt", "r") as f:
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

    img.save("vga_output.png")
    print(f"Saved vga_output.png ({WIDTH}x{HEIGHT})")


if __name__ == "__main__":
    convert_to_png()
