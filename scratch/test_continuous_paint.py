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

w, h = 900, 300
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

def draw_line(x0, y0, x1, y1, width, color, alpha):
    dx = x1 - x0; dy = y1 - y0
    dist = math.hypot(dx, dy)
    steps = max(1, int(dist * 2))
    r, g, b = color
    rad = width / 2.0
    for s in range(steps + 1):
        t = s / steps
        cx = x0 + dx * t
        cy = y0 + dy * t
        for py in range(int(cy - rad - 1), int(cy + rad + 2)):
            for px in range(int(cx - rad - 1), int(cx + rad + 2)):
                d = math.hypot(px - cx, py - cy)
                if d <= rad:
                    frac = 1.0 if d <= rad - 0.7 else (rad - d) / 0.7
                    blend_pixel(px, py, r, g, b, int(alpha * frac))

red = (255, 30, 20)

pts_paint = []
for x in range(80, 820, 3):
    y = 150 + math.sin((x - 80) * 0.015) * 12
    pts_paint.append((float(x), float(y)))

cum_dist = 0
for i in range(len(pts_paint) - 1):
    x0, y0 = pts_paint[i]
    x1, y1 = pts_paint[i+1]
    dx = x1 - x0; dy = y1 - y0
    seg_dist = math.hypot(dx, dy)
    cum_dist += seg_dist
    nx = -dy / seg_dist if seg_dist > 0 else 0
    ny = dx / seg_dist if seg_dist > 0 else 0

    # Organic thickness alternation:
    phase = math.sin(cum_dist * 0.030) * 0.75 + math.sin(cum_dist * 0.011) * 0.25 # -1.0 to 1.0
    # Furrow factor: 0.0 when phase >= 0.05 (solid thick acrylic), up to 1.0 when phase <= -0.5
    furrow_factor = max(0.0, min(1.0, (0.05 - phase) / 0.65))

    # Upper ribbon parameters (swells when solid, narrows slightly when dry furrow opens)
    upper_w = 9.0 + (1.0 - furrow_factor) * 4.5 # 9.0px to 13.5px
    upper_off = 1.5 + furrow_factor * 2.8 # +1.5px to +4.3px
    draw_line(x0 + nx * upper_off, y0 + ny * upper_off,
              x1 + nx * upper_off, y1 + ny * upper_off,
              upper_w, red, 245)

    # Lower ribbon parameters
    lower_w = 4.2 + (1.0 - furrow_factor) * 4.8 # 4.2px to 9.0px
    lower_off = -1.5 - furrow_factor * 4.8 # -1.5px to -6.3px
    draw_line(x0 + nx * lower_off, y0 + ny * lower_off,
              x1 + nx * lower_off, y1 + ny * lower_off,
              lower_w, red, 235)

    # Bristle fiber in the furrow
    if furrow_factor > 0.3:
        fiber_off = -1.2
        fiber_a = int(60 + (1.0 - furrow_factor) * 50)
        draw_line(x0 + nx * fiber_off, y0 + ny * fiber_off,
                  x1 + nx * fiber_off, y1 + ny * fiber_off,
                  1.6, red, fiber_a)

    # Lower wisp
    if furrow_factor > 0.5:
        wisp_off = lower_off - lower_w * 0.6 - 1.5
        wisp_a = int(furrow_factor * 110)
        draw_line(x0 + nx * wisp_off, y0 + ny * wisp_off,
                  x1 + nx * wisp_off, y1 + ny * wisp_off,
                  1.8, red, wisp_a)

write_png('/Users/rileytechstudio/Documents/Gemini/App/scratch/test_continuous_paint.png', w, h, bytes(canvas))
print("Rendered test_continuous_paint.png successfully!")
