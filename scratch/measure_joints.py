from decode_png import decode_png

w, h, pixels = decode_png('/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png')

sMinX = 111
sMinY = 31
charW = 161
charH = 466

# Helper to check if pixel is bone
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

# Let's inspect vertical slice at x = 191 (character centerline)
print("Centerline (x = 191) vertical bone spans:")
in_bone = False
start_y = 0
for y in range(h):
    b = is_bone(191, y)
    if b and not in_bone:
        in_bone = True
        start_y = y
    elif not b and in_bone:
        in_bone = False
        print(f"   y: {start_y}..{y-1} (h={y-start_y}), %: {start_y/h*100:.1f}%..{(y-1)/h*100:.1f}% (char%: {(start_y-sMinY)/charH*100:.1f}%..{(y-1-sMinY)/charH*100:.1f}%)")
if in_bone:
    print(f"   y: {start_y}..{h-1}")

