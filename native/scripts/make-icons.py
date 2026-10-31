#!/usr/bin/env python3
"""Generate placeholder app icons (solid rounded square) for the Tauri shell."""
import struct, zlib, os, sys

def png(width, height, rgba):
    raw = b""
    row = bytes(rgba) * width
    for _ in range(height):
        raw += b"\x00" + row
    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr)
            + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))

def ico(png_bytes, size):
    # ICO wrapping a PNG (valid on Windows Vista+)
    header = struct.pack("<HHH", 0, 1, 1)
    entry = struct.pack("<BBBBHHII", size % 256, size % 256, 0, 0, 1, 32,
                        len(png_bytes), 22)
    return header + entry + png_bytes

out = sys.argv[1] if len(sys.argv) > 1 else "icons"
os.makedirs(out, exist_ok=True)
# desaturated slate blue square with alpha
rgba = (47, 60, 92, 255)
p = png(512, 512, rgba)
open(os.path.join(out, "icon.png"), "wb").write(p)
open(os.path.join(out, "icon.ico"), "wb").write(ico(p, 64))
print("wrote", out)
