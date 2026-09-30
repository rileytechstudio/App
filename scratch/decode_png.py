import zlib, struct

def decode_png(path):
    with open(path, 'rb') as f:
        data = f.read()
    pos = 8
    chunks = []
    while pos < len(data):
        length, ctype = struct.unpack('>I4s', data[pos:pos+8])
        cdata = data[pos+8:pos+8+length]
        pos += 12 + length
        chunks.append((ctype, cdata))
        if ctype == b'IEND': break
    
    ihdr = [c[1] for c in chunks if c[0] == b'IHDR'][0]
    w, h, depth, ctype, comp, filter_m, interlace = struct.unpack('>IIBBBBB', ihdr)
    idat = b''.join([c[1] for c in chunks if c[0] == b'IDAT'])
    raw = zlib.decompress(idat)
    
    # RGBA has 4 bytes per pixel
    stride = w * 4
    pixels = []
    prev_row = bytearray(stride)
    raw_pos = 0
    
    for y in range(h):
        filter_type = raw[raw_pos]
        raw_pos += 1
        curr_row = bytearray(raw[raw_pos:raw_pos+stride])
        raw_pos += stride
        
        # Unfilter
        if filter_type == 0: # None
            pass
        elif filter_type == 1: # Sub
            for x in range(4, stride):
                curr_row[x] = (curr_row[x] + curr_row[x-4]) & 0xFF
        elif filter_type == 2: # Up
            for x in range(stride):
                curr_row[x] = (curr_row[x] + prev_row[x]) & 0xFF
        elif filter_type == 3: # Average
            for x in range(stride):
                a = curr_row[x-4] if x >= 4 else 0
                b = prev_row[x]
                curr_row[x] = (curr_row[x] + ((a + b) >> 1)) & 0xFF
        elif filter_type == 4: # Paeth
            for x in range(stride):
                a = curr_row[x-4] if x >= 4 else 0
                b = prev_row[x]
                c = prev_row[x-4] if x >= 4 else 0
                p = a + b - c
                pa = abs(p - a)
                pb = abs(p - b)
                pc = abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                curr_row[x] = (curr_row[x] + pr) & 0xFF
        
        pixels.append(curr_row)
        prev_row = curr_row
    
    return w, h, pixels

w, h, pixels = decode_png('/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png')
print(f"Decoded {w}x{h}, rows={len(pixels)}")

def encode_png(w, h, rgba_rows, out_path):
    raw = bytearray()
    for row in rgba_rows:
        raw.append(0) # Filter None
        raw.extend(row)
    
    comp = zlib.compress(raw, 6)
    
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    
    def chunk(ctype, cdata):
        return struct.pack('>I', len(cdata)) + ctype + cdata + struct.pack('>I', zlib.crc32(ctype + cdata) & 0xFFFFFFFF)
    
    with open(out_path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(chunk(b'IHDR', ihdr))
        f.write(chunk(b'IDAT', comp))
        f.write(chunk(b'IEND', b''))
    print(f"Encoded {w}x{h} to {out_path}")

# Test saving a crop of the skeleton on transparent background
sMinX = 111
sMinY = 31
charW = 161
charH = 466

out_rows = []
for y in range(charH):
    row = bytearray(charW * 4)
    sy = sMinY + y
    curr = pixels[sy]
    for x in range(charW):
        sx = (sMinX + x) * 4
        r, g, b, a = curr[sx], curr[sx+1], curr[sx+2], curr[sx+3]
        
        # Color classification:
        # Bone white: r > 195, g > 195, b > 195
        is_white = (r > 195 and g > 195 and b > 195)
        # Bone blue: b > 125, b > r + 30, g > 80
        is_blue = (b > 125 and b > r + 30 and g > 80)
        # Dark bone line: dark navy
        is_dark = (r < 80 and g < 90 and b < 125 and b > 40 and (r + g + b) > 30)
        
        # Silhouette olive: r in 150..220, g in 160..220, b in 100..160
        is_olive = (r > 150 and g > 165 and b < 165 and abs(r - g) < 40)
        # Background purple: r in 60..115, g in 35..80, b in 140..195
        is_purple = (r < 115 and g < 90 and b > 140)
        
        dx = x * 4
        if (is_white or is_blue or is_dark) and not is_olive and not is_purple:
            row[dx] = r
            row[dx+1] = g
            row[dx+2] = b
            row[dx+3] = 255
        else:
            row[dx] = 0
            row[dx+1] = 0
            row[dx+2] = 0
            row[dx+3] = 0
    out_rows.append(row)

encode_png(charW, charH, out_rows, "scratch/python_extracted_skeleton.png")
