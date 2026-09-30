import AppKit

guard let targetImg = NSImage(contentsOfFile: "scratch/user_younger_boy_target.png"),
      let targetCg = targetImg.cgImage(forProposedRect: nil, context: nil, hints: nil),
      let candImg = NSImage(contentsOfFile: "scratch/candidate_younger_boy.png"),
      let candCg = candImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    exit(1)
}

let W = 186
let H = 538

let targetRep = NSBitmapImageRep(cgImage: targetCg)
let candRep = NSBitmapImageRep(cgImage: candCg)

// Create a diff image:
// Green: matching bone pixels
// Red: bone in target but missing in candidate
// Blue: bone in candidate but not in target
let diffRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

var totalTargetBones = 0
var matchedBones = 0
var falsePositiveBones = 0

for y in 0..<H {
    // Map to target coords (161x466)
    let ty = Int(Double(y) / Double(H) * 466.0)
    for x in 0..<W {
        let tx = Int(Double(x) / Double(W) * 161.0)
        
        var isTargetBone = false
        if tx >= 0 && tx < 161 && ty >= 0 && ty < 466 {
            if let tc = targetRep.colorAt(x: tx, y: ty) {
                let r = tc.redComponent, g = tc.greenComponent, b = tc.blueComponent
                if (r > 0.82 && g > 0.82 && b > 0.82) || (b > 0.55 && b > r + 0.15 && g > 0.35) || (r < 0.28 && g < 0.28 && b < 0.42 && (r + g + b) > 0.15) {
                    isTargetBone = true
                }
            }
        }
        
        let cc = candRep.colorAt(x: x, y: y)!
        let isCandBone = cc.alphaComponent > 0.5 && !(cc.redComponent > 0.6 && cc.greenComponent > 0.6 && cc.blueComponent < 0.6) // not silhouette
        
        if isTargetBone { totalTargetBones += 1 }
        
        if isTargetBone && isCandBone {
            matchedBones += 1
            diffRep.setColor(NSColor(red: 0, green: 1, blue: 0, alpha: 1), atX: x, y: y) // green
        } else if isTargetBone && !isCandBone {
            diffRep.setColor(NSColor(red: 1, green: 0, blue: 0, alpha: 1), atX: x, y: y) // red (missing)
        } else if !isTargetBone && isCandBone {
            falsePositiveBones += 1
            diffRep.setColor(NSColor(red: 0, green: 0, blue: 1, alpha: 1), atX: x, y: y) // blue (extra)
        } else {
            diffRep.setColor(NSColor(white: 0.1, alpha: 1), atX: x, y: y)
        }
    }
}

let matchPct = Double(matchedBones) / Double(totalTargetBones) * 100.0
print("Target bone pixels: \(totalTargetBones)")
print("Matched bone pixels: \(matchedBones) (\(String(format: "%.1f", matchPct))%)")
print("Extra bone pixels: \(falsePositiveBones)")

let png = diffRep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: "scratch/diff_overlay.png"))
print("Saved scratch/diff_overlay.png")

