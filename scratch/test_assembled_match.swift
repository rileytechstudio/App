import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOfFile: targetUrl.path)!
let targetRep = NSBitmapImageRep(data: targetImg.tiffRepresentation!)!

let skelUrl = URL(fileURLWithPath: "assets/Skeleton_Assembled.png")
let skelImg = NSImage(contentsOfFile: skelUrl.path)!
let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!)!

print("Target: \(targetRep.pixelsWide) x \(targetRep.pixelsHigh)")
print("Skeleton_Assembled: \(skelRep.pixelsWide) x \(skelRep.pixelsHigh)")

// In user target:
// Let's test placing Skeleton_Assembled scaled as a single rectangle:
// Search (x, y, w, h)
var bestIoU = 0.0
var bestRect = (x: 0, y: 0, w: 0, h: 0)

// In target (161 x 466):
// Skull top is at y ~ 18, feet bottom is at y ~ 465. Height ~ 447.
// Width: Hands reach from x ~ 0 to x ~ 160. Width ~ 161!
// Skeleton_Assembled original aspect is 841 / 1690 = 0.4976.
// Target aspect of skeleton: 161 / 447 = 0.360.
// So the skeleton in target was scaled with non-uniform (w, h) or uniform?
// Let's check!

for w in stride(from: 140, through: 170, by: 2) {
    for h in stride(from: 420, through: 460, by: 2) {
        for x in stride(from: -10, through: 10, by: 2) {
            for y in stride(from: 10, through: 25, by: 1) {
                // Check sample points: skull center, pelvis center, hands
                // Let's compute IoU on a downsampled grid (step 4)
                var intersection = 0
                var union = 0
                for py in stride(from: 0, to: 466, by: 6) {
                    for px in stride(from: 0, to: 161, by: 4) {
                        // Is it target bone?
                        let tc = targetRep.colorAt(x: px, y: py)!
                        let tr = tc.redComponent, tg = tc.greenComponent, tb = tc.blueComponent
                        let isTarget = (tr > 0.82 && tg > 0.82 && tb > 0.82) || (tb > 0.55 && tb > tr + 0.15 && tg > 0.35) || (tr < 0.28 && tg < 0.28 && tb < 0.42 && (tr + tg + tb) > 0.15)
                        
                        // Map (px, py) into skeleton rect
                        let sx = Int(Double(px - x) / Double(w) * 841.0)
                        let sy = Int(Double(py - y) / Double(h) * 1690.0)
                        var isSkel = false
                        if sx >= 0 && sx < 841 && sy >= 0 && sy < 1690 {
                            let sa = skelRep.colorAt(x: sx, y: sy)!.alphaComponent
                            if sa > 0.3 {
                                isSkel = true
                            }
                        }
                        
                        if isTarget && isSkel { intersection += 1 }
                        if isTarget || isSkel { union += 1 }
                    }
                }
                let iou = union > 0 ? Double(intersection) / Double(union) : 0
                if iou > bestIoU {
                    bestIoU = iou
                    bestRect = (x, y, w, h)
                }
            }
        }
    }
}

print("Best fit of Skeleton_Assembled on user target:")
print("x: \(bestRect.x), y: \(bestRect.y), w: \(bestRect.w), h: \(bestRect.h)")
print("IoU: \(bestIoU)")

