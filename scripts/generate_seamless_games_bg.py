import zlib, struct
from collections import deque
import math, random

def load_rgba(path):
    with open(path, 'rb') as f:
        f.read(8); idat = bytearray()
        while True:
            hdr = f.read(8)
            if not hdr: break
            l, t = struct.unpack('>I4s', hdr); d = f.read(l); f.read(4)
            if t == b'IHDR': w, h = struct.unpack('>II', d[:8])
            elif t == b'IDAT': idat.extend(d)
            elif t == b'IEND': break
    raw = zlib.decompress(idat); stride = 1 + w * 4; unfiltered = bytearray(w * h * 4)
    for y in range(h):
        ft = raw[y * stride]; row = bytearray(raw[y * stride + 1 : (y + 1) * stride])
        prev = unfiltered[(y-1)*w*4 : y*w*4] if y > 0 else bytearray(w * 4)
        if ft == 1:
            for x in range(4, w * 4): row[x] = (row[x] + row[x-4]) & 0xff
        elif ft == 2:
            for x in range(w * 4): row[x] = (row[x] + prev[x]) & 0xff
        elif ft == 3:
            for x in range(w * 4):
                l = row[x-4] if x >= 4 else 0; row[x] = (row[x] + ((l + prev[x]) >> 1)) & 0xff
        elif ft == 4:
            for x in range(w * 4):
                a = row[x-4] if x >= 4 else 0; b = prev[x]; c = prev[x-4] if x >= 4 else 0
                p = a + b - c; pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c); row[x] = (row[x] + pr) & 0xff
        unfiltered[y*w*4 : (y+1)*w*4] = row
    return w, h, unfiltered

def write_png(filename, width, height, pixels):
    raw_bytes = bytearray()
    stride = width * 4
    for y in range(height):
        raw_bytes.append(0)
        raw_bytes.extend(pixels[y*stride:(y+1)*stride])
    compressed = zlib.compress(bytes(raw_bytes), 9)
    ihdr_payload = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr_crc = zlib.crc32(b'IHDR' + ihdr_payload)
    idat_crc = zlib.crc32(b'IDAT' + compressed)
    iend_crc = zlib.crc32(b'IEND')
    with open(filename, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(struct.pack('>I', 13) + b'IHDR' + ihdr_payload + struct.pack('>I', ihdr_crc))
        f.write(struct.pack('>I', len(compressed)) + b'IDAT' + compressed + struct.pack('>I', idat_crc))
        f.write(struct.pack('>I', 0) + b'IEND' + struct.pack('>I', iend_crc))

w, h, data = load_rgba('Games/Games Scroll 4.png')

# Connected components
visited = [False] * (w * h); comps = []
for y in range(h):
    for x in range(w):
        idx = y * w + x
        if visited[idx] or data[idx * 4 + 3] < 15: continue
        q = deque([(x, y)]); visited[idx] = True; pixels = []
        while q:
            cx, cy = q.popleft(); pixels.append((cx, cy))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    if dx == 0 and dy == 0: continue
                    nx, ny = cx + dx, cy + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        nidx = ny * w + nx
                        if not visited[nidx] and data[nidx * 4 + 3] >= 15:
                            visited[nidx] = True; q.append((nx, ny))
        comps.append({'pixels': pixels,
                      'min_x': min(p[0] for p in pixels), 'max_x': max(p[0] for p in pixels),
                      'min_y': min(p[1] for p in pixels), 'max_y': max(p[1] for p in pixels),
                      'center': (sum(p[0] for p in pixels)/len(pixels), sum(p[1] for p in pixels)/len(pixels))})

bodies = [c for c in comps if len(c['pixels']) > 400]
merged = []
used = [False] * len(bodies)
for i in range(len(bodies)):
    if used[i]: continue
    b_group = [bodies[i]]; used[i] = True; c_i = bodies[i]['center']
    for j in range(i+1, len(bodies)):
        if used[j]: continue
        c_j = bodies[j]['center']
        if math.hypot(c_i[0] - c_j[0], c_i[1] - c_j[1]) < 35:
            b_group.append(bodies[j]); used[j] = True
    merged.append(b_group)

controllers = []
for bg in merged:
    pxs = []
    for b in bg: pxs.extend(b['pixels'])
    controllers.append({'body_pixels': pxs, 'all_pixels': list(pxs)})

for c in comps:
    if any(c in bg for bg in merged): continue
    cx, cy = c['center']; best_ctrl = None; min_dist = float('inf')
    for ctrl in controllers:
        bc_x = sum(p[0] for p in ctrl['body_pixels']) / len(ctrl['body_pixels'])
        bc_y = sum(p[1] for p in ctrl['body_pixels']) / len(ctrl['body_pixels'])
        d = math.hypot(bc_x - cx, bc_y - cy)
        if d < min_dist: min_dist = d; best_ctrl = ctrl
    best_ctrl['all_pixels'].extend(c['pixels'])

# Extract pristine sprite data for each of the 61 controllers
sprites = []
coords = []
for i, ctrl in enumerate(controllers):
    min_x = min(p[0] for p in ctrl['all_pixels'])
    max_x = max(p[0] for p in ctrl['all_pixels'])
    min_y = min(p[1] for p in ctrl['all_pixels'])
    max_y = max(p[1] for p in ctrl['all_pixels'])
    cx = sum(p[0] for p in ctrl['all_pixels']) / len(ctrl['all_pixels'])
    cy = sum(p[1] for p in ctrl['all_pixels']) / len(ctrl['all_pixels'])
    sw = max_x - min_x + 1
    sh = max_y - min_y + 1
    s_raw = bytearray(sw * sh * 4)
    px_set = set(ctrl['all_pixels'])
    for py in range(min_y, max_y + 1):
        for px in range(min_x, max_x + 1):
            if (px, py) in px_set:
                src_idx = (py * w + px) * 4
                dst_idx = ((py - min_y) * sw + (px - min_x)) * 4
                s_raw[dst_idx:dst_idx+4] = data[src_idx:src_idx+4]
    sprites.append({
        'id': i, 'sw': sw, 'sh': sh, 'raw': s_raw,
        'offset_cx': cx - min_x,
        'offset_cy': cy - min_y
    })
    coords.append((cx, cy))

def tor_diff(p1, p2):
    dx = p1[0] - p2[0]; dy = p1[1] - p2[1]
    if dx > w / 2: dx -= w
    elif dx < -w / 2: dx += w
    if dy > h / 2: dy -= h
    elif dy < -h / 2: dy += h
    return dx, dy

def tor_dist(p1, p2):
    dx, dy = tor_diff(p1, p2)
    return math.hypot(dx, dy)

ref = min(coords, key=lambda p: p[1])
v1x, v1y = 90.60, 33.80
v2x, v2y = -33.80, 90.60

lattice_candidates = []
for n in range(-18, 19):
    for m in range(-18, 19):
        px = (ref[0] + n * v1x - m * v1y) % w
        py = (ref[1] + n * v1y + m * v1x) % h
        lattice_candidates.append((px, py))

pts = [list(c) for c in coords]
fixed_count = len(coords)

# Greedy lattice placement
while True:
    best_cand = None
    best_d = 0
    for cand in lattice_candidates:
        min_d = min(tor_dist(cand, p) for p in pts)
        if min_d >= 80.0 and min_d > best_d:
            best_d = min_d
            best_cand = cand
    if best_cand is None: break
    pts.append(list(best_cand))

# Fill any residual voids
while True:
    best_pocket = None
    best_clearance = 0
    for gy in range(0, h, 10):
        for gx in range(0, w, 10):
            d = min(tor_dist((gx, gy), p) for p in pts)
            if d > 82.0 and d > best_clearance:
                best_clearance = d
                best_pocket = (gx, gy)
    if best_pocket is None or best_clearance < 82.0:
        break
    pts.append(list(best_pocket))

# Spring relaxation on boundary items
for iteration in range(250):
    forces = [[0.0, 0.0] for _ in range(len(pts))]
    for i in range(len(pts)):
        for j in range(i + 1, len(pts)):
            dx, dy = tor_diff(pts[i], pts[j])
            dist = math.hypot(dx, dy)
            if dist < 1e-4: continue
            if dist < 130.0:
                if dist < 87.0:
                    f = (87.0 - dist) * 2.0
                else:
                    target = 93.0
                    f = (target - dist) * 0.1
                fx = (dx / dist) * f
                fy = (dy / dist) * f
                if i >= fixed_count:
                    forces[i][0] += fx
                    forces[i][1] += fy
                if j >= fixed_count:
                    forces[j][0] -= fx
                    forces[j][1] -= fy
    for i in range(fixed_count, len(pts)):
        pts[i][0] = (pts[i][0] + forces[i][0] * 0.08) % w
        pts[i][1] = (pts[i][1] + forces[i][1] * 0.08) % h

print(f'Final site count: {len(pts)}')
min_pair_d = min(tor_dist(pts[i], pts[j]) for i in range(len(pts)) for j in range(i+1, len(pts)))
print(f'Minimum toroidal clearance: {min_pair_d:.2f} px')

# Assign sprite IDs to each site:
# Site 0..60 get their original sprite IDs 0..60!
sprite_assignments = list(range(fixed_count))

# For boundary sites (index >= fixed_count), assign sprites to maximize distance to same sprite:
random.seed(1337)
available_pool = []
for rep in range(3):
    shuffled = list(range(len(sprites)))
    random.shuffle(shuffled)
    available_pool.extend(shuffled)

for site_idx in range(fixed_count, len(pts)):
    site_pt = pts[site_idx]
    # Pick a sprite from available_pool that maximizes toroidal distance to all existing sites using that sprite
    best_spr = None
    best_dist = -1.0
    for candidate_spr in available_pool:
        # find min dist to existing occurrences
        d = float('inf')
        for ex_idx, ex_spr in enumerate(sprite_assignments):
            if ex_spr == candidate_spr:
                cur_d = tor_dist(site_pt, pts[ex_idx])
                if cur_d < d: d = cur_d
        if d > best_dist:
            best_dist = d
            best_spr = candidate_spr
    sprite_assignments.append(best_spr)
    available_pool.remove(best_spr)

# Verify minimum separation between identical sprites:
min_same_dist = float('inf')
for i in range(len(pts)):
    for j in range(i + 1, len(pts)):
        if sprite_assignments[i] == sprite_assignments[j]:
            d = tor_dist(pts[i], pts[j])
            if d < min_same_dist: min_same_dist = d

print(f'Minimum toroidal distance between IDENTICAL controllers: {min_same_dist:.2f} px')

# Render seamless pattern on transparent canvas
pattern_pixels = bytearray(w * h * 4)

def toroidal_blit(sprite, cx, cy, target):
    sw = sprite['sw']
    sh = sprite['sh']
    start_x = int(round(cx - sprite['offset_cx']))
    start_y = int(round(cy - sprite['offset_cy']))
    for sy in range(sh):
        for sx in range(sw):
            s_idx = (sy * sw + sx) * 4
            sa = sprite['raw'][s_idx + 3]
            if sa < 15: continue
            tx = (start_x + sx) % w
            ty = (start_y + sy) % h
            t_idx = (ty * w + tx) * 4
            target[t_idx : t_idx + 4] = sprite['raw'][s_idx : s_idx + 4]

for i in range(len(pts)):
    spr = sprites[sprite_assignments[i]]
    toroidal_blit(spr, pts[i][0], pts[i][1], pattern_pixels)

write_png('scratch/GamesBackgroundPattern_seamless.png', w, h, pattern_pixels)
print('Wrote scratch/GamesBackgroundPattern_seamless.png')

# Render a 2x2 tiling on top of the purple background (#5931BB)
t2_w = w * 2
t2_h = h * 2
# Scale down by 2 for easy preview: 1366x1024
prev_w = w
prev_h = h
preview = bytearray(prev_w * prev_h * 4)

# Purple base color: rgb(89, 49, 187) -> #5931BB
for py in range(prev_h):
    # Map to 2x2 tile space
    gy = (py * 2) % h
    for px in range(prev_w):
        gx = (px * 2) % w
        src_idx = (gy * w + gx) * 4
        dst_idx = (py * prev_w + px) * 4
        sa = pattern_pixels[src_idx + 3] / 255.0
        sr = pattern_pixels[src_idx]
        sg = pattern_pixels[src_idx + 1]
        sb = pattern_pixels[src_idx + 2]
        # Alpha blend over #5931BB
        preview[dst_idx]     = int(sr * sa + 89 * (1.0 - sa))
        preview[dst_idx + 1] = int(sg * sa + 49 * (1.0 - sa))
        preview[dst_idx + 2] = int(sb * sa + 187 * (1.0 - sa))
        preview[dst_idx + 3] = 255

write_png('scratch/preview_2x2_fixed.png', prev_w, prev_h, preview)
print('Wrote scratch/preview_2x2_fixed.png')
