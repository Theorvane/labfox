"""Minimal PNG read / resize / write using only the standard library.

The build environment has no ImageMagick, no librsvg and no Pillow, and cannot
install them (no pip, no sudo). Icon generation would otherwise be a manual
step done on somebody's laptop, which is exactly the kind of thing that drifts
out of sync with the source image. zlib is in the standard library, so a small
decoder and encoder is enough to keep the whole pipeline reproducible.

Supports what the brand source actually is: non-interlaced, 8-bit, RGB or RGBA.
Anything else raises rather than guessing.
"""

import struct
import zlib

_SIG = b"\x89PNG\r\n\x1a\n"


def _chunks(data):
    pos = 8
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos:pos + 4])
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + length]
        yield kind, body
        pos += 12 + length


def _paeth(a, b, c):
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    return b if pb <= pc else c


def read(path):
    """Return (width, height, channels, bytearray of raw pixel data)."""
    data = open(path, "rb").read()
    if data[:8] != _SIG:
        raise ValueError(f"{path} is not a PNG")

    width = height = depth = color = None
    idat = bytearray()
    for kind, body in _chunks(data):
        if kind == b"IHDR":
            width, height, depth, color, _, _, interlace = struct.unpack(">IIBBBBB", body)
            if depth != 8:
                raise ValueError(f"only 8-bit PNGs are supported, got {depth}-bit")
            if color not in (2, 6):
                raise ValueError(f"only RGB and RGBA are supported, got color type {color}")
            if interlace:
                raise ValueError("interlaced PNGs are not supported")
        elif kind == b"IDAT":
            idat += body
        elif kind == b"IEND":
            break

    channels = 3 if color == 2 else 4
    raw = zlib.decompress(bytes(idat))
    stride = width * channels
    out = bytearray(height * stride)

    pos = 0
    prev = bytearray(stride)
    for y in range(height):
        ftype = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride

        if ftype == 1:
            for i in range(channels, stride):
                line[i] = (line[i] + line[i - channels]) & 0xFF
        elif ftype == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ftype == 3:
            for i in range(stride):
                left = line[i - channels] if i >= channels else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 0xFF
        elif ftype == 4:
            for i in range(stride):
                left = line[i - channels] if i >= channels else 0
                upleft = prev[i - channels] if i >= channels else 0
                line[i] = (line[i] + _paeth(left, prev[i], upleft)) & 0xFF
        elif ftype != 0:
            raise ValueError(f"unknown filter type {ftype} on row {y}")

        out[y * stride:(y + 1) * stride] = line
        prev = line

    return width, height, channels, out


def resize(src, sw, sh, channels, dw, dh):
    """Box-filter resample. Averaging the whole source rect per target pixel is
    what keeps thin strokes from breaking up at favicon sizes."""
    dst = bytearray(dw * dh * channels)
    x_edges = [(x * sw) // dw for x in range(dw + 1)]
    y_edges = [(y * sh) // dh for y in range(dh + 1)]

    for dy in range(dh):
        y0, y1 = y_edges[dy], max(y_edges[dy + 1], y_edges[dy] + 1)
        row_base = dy * dw * channels
        for dx in range(dw):
            x0, x1 = x_edges[dx], max(x_edges[dx + 1], x_edges[dx] + 1)
            totals = [0] * channels
            count = 0
            for sy in range(y0, y1):
                base = (sy * sw + x0) * channels
                for _ in range(x1 - x0):
                    for c in range(channels):
                        totals[c] += src[base + c]
                    base += channels
                    count += 1
            off = row_base + dx * channels
            for c in range(channels):
                dst[off + c] = totals[c] // count
    return dst


def canvas(width, height, rgb):
    """Solid background, RGB only."""
    return bytearray(bytes(rgb) * (width * height))


def paste(dst, dw, src, sw, sh, channels, x, y):
    """Composite src onto an RGB dst at (x, y). Alpha is honoured if present."""
    for row in range(sh):
        d = ((y + row) * dw + x) * 3
        s = row * sw * channels
        for _ in range(sw):
            if channels == 4:
                a = src[s + 3]
                if a:
                    for c in range(3):
                        dst[d + c] = (src[s + c] * a + dst[d + c] * (255 - a)) // 255
            else:
                dst[d:d + 3] = src[s:s + 3]
            d += 3
            s += channels
    return dst


def write(path, width, height, channels, pixels):
    stride = width * channels
    raw = bytearray()
    for y in range(height):
        raw.append(0)  # filter type 0; the encoder does not need to be clever
        raw += pixels[y * stride:(y + 1) * stride]

    def chunk(kind, body):
        return (struct.pack(">I", len(body)) + kind + body
                + struct.pack(">I", zlib.crc32(kind + body) & 0xFFFFFFFF))

    color = 2 if channels == 3 else 6
    png = (_SIG
           + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, color, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
           + chunk(b"IEND", b""))
    open(path, "wb").write(png)
    return len(png)
