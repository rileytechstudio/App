import math, struct, zlib

def write_png(filename, width, height, rgba_data):
    def chunk(tag, data):
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)
    raw = b''.join(b'\x00' + rgba_data[y*width*4 : (y+1)*width*4] for y in range(height))
    compressed = zlib.compress(raw, 9)
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    with open(filename, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(chunk(b'IHDR', ihdr_data))
        f.write(chunk(b'IDAT', compressed))
        f.write(chunk(b'IEND', b''))

w, h = 900, 450
canvas = bytearray(w * h * 4)
for i in range(w * h):
    canvas[i*4] = 248; canvas[i*4+1] = 246; canvas[i*4+2] = 240; canvas[i*4+3] = 255

def blend_pixel(x, y, r, g, b, a):
    if 0 <= x < w and 0 <= y < h:
        idx = (int(y) * w + int(x)) * 4
        inv_a = 255 - a
        canvas[idx]   = (r * a + canvas[idx]   * inv_a) // 255
        canvas[idx+1] = (g * a + canvas[idx+1] * inv_a) // 255
        canvas[idx+2] = (b * a + canvas[idx+2] * inv_a) // 255

def draw_continuous_stroke(points, width, color, alpha):
    r, g, b = color
    rad = width / 2.0
    for i in range(len(points) - 1):
        x0, y0 = points[i]
        x1, y1 = points[i+1]
        dist = math.hypot(x1 - x0, y1 - y0)
        steps = max(1, int(dist * 3))
        for s in range(steps + 1):
            t = s / steps
            cx = x0 + (x1 - x0) * t
            cy = y0 + (y1 - y0) * t
            for py in range(int(cy - rad - 1), int(cy + rad + 2)):
                for px in range(int(cx - rad - 1), int(cx + rad + 2)):
                    d = math.hypot(px - cx, py - cy)
                    if d <= rad:
                        frac = 1.0 if d <= rad - 0.7 else (rad - d) / 0.7
                        blend_pixel(px, py, r, g, b, int(alpha * frac))

blue = (15, 120, 235)
red = (255, 30, 20)
purple = (84, 46, 144)

# 1. PENCIL: Continuous fine line (lineWidth: 3.5, alpha: 220)
pts_pencil = []
for x in range(80, 820, 4):
    y = 80 + math.sin((x - 80) * 0.02) * 15
    pts_pencil.append((float(x), float(y)))
draw_continuous_stroke(pts_pencil, 3.5, purple, 225)

# 2. MARKER: Continuous solid bold line (lineWidth: 11.0, alpha: 245)
pts_marker = []
for x in range(80, 820, 4):
    y = 200 + math.sin((x - 80) * 0.02) * 15
    pts_marker.append((float(x), float(y)))
draw_continuous_stroke(pts_marker, 11.0, blue, 245)

# 3. PAINT TUBE: Continuous rich thick acrylic stroke (lineWidth: 20.0, alpha: 245)
pts_paint = []
for x in range(80, 820, 4):
    y = 330 + math.sin((x - 80) * 0.02) * 15
    pts_paint.append((float(x), float(y)))
draw_continuous_stroke(pts_paint, 20.0, red, 248)

write_png('/Users/rileytechstudio/Documents/Gemini/App/scratch/test_continuous_tools.png', w, h, bytes(canvas))
print("Rendered test_continuous_tools.png successfully!")
