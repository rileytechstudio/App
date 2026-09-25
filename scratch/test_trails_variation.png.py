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

w, h = 900, 500
canvas = bytearray(w * h * 4)
# Paper background
for i in range(w * h):
    canvas[i*4] = 248; canvas[i*4+1] = 246; canvas[i*4+2] = 240; canvas[i*4+3] = 255

def blend_pixel(x, y, r, g, b, a):
    if 0 <= x < w and 0 <= y < h:
        idx = (int(y) * w + int(x)) * 4
        inv_a = 255 - a
        canvas[idx]   = (r * a + canvas[idx]   * inv_a) // 255
        canvas[idx+1] = (g * a + canvas[idx+1] * inv_a) // 255
        canvas[idx+2] = (b * a + canvas[idx+2] * inv_a) // 255

# Color: Vibrant Red (like paint tube example) and Deep Blue
red = (255, 30, 20)
blue = (15, 120, 235)

# --- 1. TEST MARKER TRAIL WITH INK VARIATION ---
# Let's draw a wavy marker stroke across x = 80 to 820 at y = 120
for px in range(80, 820):
    dist = px - 80
    base_y = 120 + math.sin(dist * 0.018) * 12

    # Ink width modulation:
    # Harmonic variations to simulate hand pressure and ink pooling:
    # Slow wave + medium ripple
    wave1 = math.sin(dist * 0.022) * 3.8
    wave2 = math.sin(dist * 0.055) * 2.0
    # Slight taper envelope towards the end
    end_dist = 820 - px
    end_taper = min(1.0, end_dist / 60.0)
    
    width = max(3.5, (11.0 + wave1 + wave2) * end_taper)
    half_w = width / 2.0

    # Draw vertical slice of stroke
    for dy in range(int(-half_w - 2), int(half_w + 3)):
        dist_y = abs(dy)
        if dist_y <= half_w - 0.7:
            alpha = 248
        elif dist_y <= half_w + 0.7:
            frac = (half_w + 0.7 - dist_y) / 1.4
            alpha = int(frac * 248)
        else:
            alpha = 0
        if alpha > 0:
            blend_pixel(px, base_y + dy, blue[0], blue[1], blue[2], alpha)

# --- 2. TEST PAINT TUBE TRAIL WITH ALTERNATING THICKNESS AND COMING-IN/OUT FURROW ---
# Let's draw across x = 80 to 820 at y = 280
for px in range(80, 820):
    dist = px - 80
    base_y = 280 + math.sin(dist * 0.015) * 10

    # Organic thickness alternation: cycles every ~140px
    # Cycle between thick solid impasto and thinner dry-furrowed paint
    cycle = math.sin(dist * 0.032) # -1.0 to +1.0
    # Let's also add a secondary slow wave
    slow = math.sin(dist * 0.011) * 0.25
    phase = cycle + slow # roughly -1.25 to +1.25

    # Overall height/thickness alternates between ~10px and ~22px
    total_thickness = 15.0 + phase * 6.0 # 9px to 21px
    
    # Furrow opening factor:
    # When phase > 0.2: paint is heavy & thick, furrow is completely CLOSED (solid paint!)
    # When phase < 0.2: furrow opens up, paper shows through, creating alternating bristle gap!
    furrow_open = max(0.0, min(1.0, (0.3 - phase) / 0.7)) # 0.0 when thick/solid, 1.0 when dry/thin

    # Upper body half-width
    upper_h = total_thickness * 0.65
    # Lower ribbon height
    lower_h = total_thickness * 0.35 * (1.0 - furrow_open * 0.2)
    # Furrow gap distance between upper and lower ribbon:
    # 0 when closed (merges seamlessly into 1 thick solid stroke!), up to 3.5px when open
    gap_size = furrow_open * 3.8

    # We map y from -lower_h - gap_size to +upper_h
    # Upper body: y from 0 to +upper_h
    for dy in range(int(-total_thickness), int(total_thickness + 2)):
        py = base_y + dy
        # Determine if dy falls in:
        # A) Upper ribbon: dy between 0 and upper_h
        # B) Gap: dy between -gap_size and 0
        # C) Lower ribbon: dy between -gap_size - lower_h and -gap_size
        alpha = 0
        if 0 <= dy <= upper_h:
            # Upper ribbon is always richly coated
            dist_edge = min(dy, upper_h - dy)
            alpha = 245 if dist_edge >= 0.8 else int((dist_edge / 0.8) * 245)
        elif -gap_size < dy < 0:
            # Furrow gap!
            if furrow_open > 0.1:
                # Bristle wisps inside furrow
                if abs(dy + gap_size * 0.5) < 0.8 and (px * 7) % 5 != 0:
                    alpha = int((1.0 - furrow_open * 0.6) * 110) # faint bristle
                else:
                    alpha = int((1.0 - furrow_open) * 230) # fades out as furrow opens!
            else:
                alpha = 245 # closed solid!
        elif (-gap_size - lower_h) <= dy <= -gap_size:
            # Lower ribbon
            dist_edge = min(abs(dy - (-gap_size)), abs(dy - (-gap_size - lower_h)))
            # When furrow is wide open, lower ribbon has slight bristle striation
            alpha = 235 if dist_edge >= 0.8 else int((dist_edge / 0.8) * 235)
            if furrow_open > 0.7 and (px % 4 == 0):
                alpha = int(alpha * 0.75) # bristle texture
        elif dy < (-gap_size - lower_h) and furrow_open > 0.5:
            # Subtle lower bristle wisp trailing below
            if abs(dy - (-gap_size - lower_h - 2.5)) < 0.8 and (px * 13) % 7 != 0:
                alpha = int(furrow_open * 120)

        if alpha > 0:
            blend_pixel(px, py, red[0], red[1], red[2], alpha)

write_png('/Users/rileytechstudio/Documents/Gemini/App/scratch/test_trails_variation.png', w, h, bytes(canvas))
print("Rendered test_trails_variation.png successfully!")
