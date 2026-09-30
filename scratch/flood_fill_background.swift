import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let img = NSImage(contentsOf: url)!
let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let W = cgImage.width
let H = cgImage.height

let colorSpace = CGColorSpaceCreateDeviceRGB()
let bytesPerRow = W * 4
var rawData = [UInt8](repeating: 0, count: H * bytesPerRow)

guard let inCtx = CGContext(data: &rawData, width: W, height: H, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }
inCtx.draw(cgImage, in: CGRect(x: 0, y: 0, width: W, height: H))

// BFS flood fill from outside
// A pixel is background if it's purple:
// Background purple: r: 70..100, g: 50..75, b: 150..185
// Silhouette dark purple: r: 50..85, g: 40..65, b: 110..155
// Bone pixels are NEVER purple:
// White bone: r>150, g>150, b>150
// Blue joint shading: b>100, g>r+10
// Eye socket: dark navy r<60, g<65, b<95

func isBackgroundPixel(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> Bool {
    // If it's white bone, definitely not background
    if r > 140 && g > 140 && b > 140 { return false }
    // If it's blue joint shading/outline, definitely not background
    if b > 90 && Int(g) > Int(r) + 8 { return false }
    // If it's dark navy eye socket, definitely not background
    if r < 60 && g < 70 && b < 95 { return false }
    // Otherwise it is purple background or silhouette shadow
    return true
}

var isBg = [Bool](repeating: false, count: W * H)
var queue = [(x: Int, y: Int)]()
queue.reserveCapacity(W * H)

// Add all 4 borders to queue if background
for x in 0..<W {
    for y in [0, H - 1] {
        let offset = (y * W + x) * 4
        if isBackgroundPixel(rawData[offset], rawData[offset + 1], rawData[offset + 2]) {
            isBg[y * W + x] = true
            queue.append((x, y))
        }
    }
}
for y in 0..<H {
    for x in [0, W - 1] {
        let offset = (y * W + x) * 4
        if !isBg[y * W + x] && isBackgroundPixel(rawData[offset], rawData[offset + 1], rawData[offset + 2]) {
            isBg[y * W + x] = true
            queue.append((x, y))
        }
    }
}

var head = 0
while head < queue.count {
    let p = queue[head]
    head += 1
    
    let neighbors = [(p.x + 1, p.y), (p.x - 1, p.y), (p.x, p.y + 1), (p.x, p.y - 1)]
    for n in neighbors {
        if n.0 >= 0 && n.0 < W && n.1 >= 0 && n.1 < H {
            let idx = n.1 * W + n.0
            if !isBg[idx] {
                let offset = idx * 4
                if isBackgroundPixel(rawData[offset], rawData[offset + 1], rawData[offset + 2]) {
                    isBg[idx] = true
                    queue.append((n.0, n.1))
                }
            }
        }
    }
}

print("Flood filled \(queue.count) background pixels out of \(W * H)")

// Now build output data:
var outData = rawData
var minX = W, maxX = 0, minY = H, maxY = 0

for y in 0..<H {
    let screenY = H - 1 - y
    for x in 0..<W {
        let idx = y * W + x
        let offset = idx * 4
        if isBg[idx] {
            outData[offset + 3] = 0 // transparent
        } else {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, screenY)
            maxY = max(maxY, screenY)
        }
    }
}

print(String(format: "Skeleton bounds: x: %d..%d (w:%d), y(screen): %d..%d (h:%d)",
    minX, maxX, maxX - minX + 1, minY, maxY, maxY - minY + 1))

guard let outCtx = CGContext(data: &outData, width: W, height: H, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
      let outCg = outCtx.makeImage() else { exit(1) }

let cropW = maxX - minX + 1
let cropH = maxY - minY + 1
let cgCropY = H - 1 - maxY
guard let croppedCg = outCg.cropping(to: CGRect(x: minX, y: cgCropY, width: cropW, height: cropH)) else { exit(1) }

let rep = NSBitmapImageRep(cgImage: croppedCg)
let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/older_boy_skel_floodfilled.png"))
print("Saved scratch/older_boy_skel_floodfilled.png (\(cropW) x \(cropH))")

