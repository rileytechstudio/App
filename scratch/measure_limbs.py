from decode_png import decode_png

w, h, pixels = decode_png('/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png')
sMinX = 111; sMinY = 31; charW = 161; charH = 466

def is_bone(x, y):
    if x < 0 or x >= w or y < 0 or y >= h: return False
    curr = pixels[y]
    r, g, b, a = curr[x*4], curr[x*4+1], curr[x*4+2], curr[x*4+3]
    is_white = (r > 195 and g > 195 and b > 195)
    is_blue = (b > 125 and b > r + 30 and g > 80)
    is_dark = (r < 80 and g < 90 and b < 125 and b > 40 and (r + g + b) > 30)
    is_olive = (r > 150 and g > 165 and b < 165 and abs(r - g) < 40)
    is_purple = (r < 115 and g < 90 and b > 140)
    return (is_white or is_blue or is_dark) and not is_olive and not is_purple

def find_centroid(x0, x1, y0, y1, name):
    sx = 0.0; sy = 0.0; count = 0
    for y in range(y0, y1+1):
        for x in range(x0, x1+1):
            if is_bone(x, y):
                sx += x; sy += y; count += 1
    if count == 0:
        print(f"{name}: not found")
        return None
    cx = sx / count; cy = sy / count
    cx_pct = (cx - sMinX) / charW * 100
    cy_pct = (cy - sMinY) / charH * 100
    print(f"{name}: px=({cx:.1f}, {cy:.1f}), char%=({cx_pct:.1f}%, {cy_pct:.1f}%), count={count}")
    return cx, cy, cx_pct, cy_pct

print("=== JOINTS & KEY CENTERS ===")
find_centroid(130, 150, 160, 185, "Left Shoulder Joint")
find_centroid(115, 135, 230, 255, "Left Elbow Joint")
find_centroid(115, 135, 280, 305, "Left Wrist Joint")
find_centroid(115, 135, 305, 330, "Left Hand Tip")

find_centroid(235, 255, 160, 185, "Right Shoulder Joint")
find_centroid(245, 265, 230, 255, "Right Elbow Joint")
find_centroid(245, 265, 280, 305, "Right Wrist Joint")
find_centroid(245, 265, 305, 330, "Right Hand Tip")

find_centroid(150, 175, 305, 330, "Left Hip Joint")
find_centroid(145, 170, 395, 415, "Left Knee Joint")
find_centroid(145, 170, 460, 475, "Left Ankle Joint")

find_centroid(210, 235, 305, 330, "Right Hip Joint")
find_centroid(210, 235, 395, 415, "Right Knee Joint")
find_centroid(210, 235, 460, 475, "Right Ankle Joint")

