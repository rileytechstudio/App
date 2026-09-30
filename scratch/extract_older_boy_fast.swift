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

var outData = [UInt8](repeating: 0, count: H * bytesPerRow)

var minX = W, maxX = 0, minY = H, maxY = 0

for y in 0..<H {
    // In CoreGraphics bottom-left, y=0 is bottom
    // Screen top is H - 1 - y
    let screenY = H - 1 - y
    let rowStart = y * bytesPerRow
    for x in 0..<W {
        let offset = rowStart + x * 4
        let r = rawData[offset]
        let g = rawData[offset + 1]
        let b = rawData[offset + 2]
        let a = rawData[offset + 3]
        
        // Background purple is around r: 84, g: 63, b: 166 (b is highest, r is second, g is lowest)
        // Silhouette shadow is around r: 70, g: 50, b: 140
        // Bone white: r > 180, g > 180, b > 180
        // Bone blue/cyan: b > 120, g > r + 15
        
        let isWhite = (r > 160 && g > 160 && b > 160)
        let isBlue = (b > 100 && Int(g) > Int(r) + 12)
        
        if isWhite || isBlue {
            outData[offset] = r
            outData[offset + 1] = g
            outData[offset + 2] = b
            outData[offset + 3] = a
            
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, screenY)
            maxY = max(maxY, screenY)
        } else {
            outData[offset + 3] = 0 // transparent
        }
    }
}

print(String(format: "Extracted bounds: x: %d..%d (w:%d), y(screen): %d..%d (h:%d)",
    minX, maxX, maxX - minX + 1, minY, maxY, maxY - minY + 1))

guard let outCtx = CGContext(data: &outData, width: W, height: H, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
      let outCg = outCtx.makeImage() else { exit(1) }

// Crop to tight bounds:
let cropW = maxX - minX + 1
let cropH = maxY - minY + 1
// In CoreGraphics bottom-left coordinates:
let cgCropY = H - 1 - maxY
guard let croppedCg = outCg.cropping(to: CGRect(x: minX, y: cgCropY, width: cropW, height: cropH)) else { exit(1) }

let rep = NSBitmapImageRep(cgImage: croppedCg)
let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/older_boy_skel_transparent.png"))
print("Saved scratch/older_boy_skel_transparent.png (\(cropW) x \(cropH))")

