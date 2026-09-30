import AppKit

let userUrl = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let userImg = NSImage(contentsOf: userUrl)!
let userRep = NSBitmapImageRep(data: userImg.tiffRepresentation!)!

let sMinX = 111.0
let sMinY = 31.0
let charW = 161.0
let charH = 466.0

// Helper to render a bone with given (x%, y%, w%, h%, rot) into an image rep
func testSkull() {
    let skullUrl = URL(fileURLWithPath: "assets/bones/Bone_skull.png")
    let skullImg = NSImage(contentsOf: skullUrl)!
    
    // Search grid:
    // cx: 48..52, step 0.5
    // cy: 11..15, step 0.5
    // w: 42..52, step 1.0
    // h: 16..22, step 0.5
    // rot: -5..5, step 1.0
    
    var bestScore = Double.infinity
    var bestParams = (cx: 0.0, cy: 0.0, w: 0.0, h: 0.0, rot: 0.0)
    
    for cx in stride(from: 48.0, through: 52.0, by: 0.5) {
        for cy in stride(from: 11.0, through: 15.0, by: 0.5) {
            for w in stride(from: 44.0, through: 52.0, by: 1.0) {
                for h in stride(from: 16.0, through: 22.0, by: 0.5) {
                    for rot in stride(from: -2.0, through: 2.0, by: 1.0) {
                        // Compute pixel rect in user image:
                        let pxW = (w / 100.0) * charW
                        let pxH = (h / 100.0) * charH
                        let pxCX = sMinX + (cx / 100.0) * charW
                        let pxCY = sMinY + (cy / 100.0) * charH
                        
                        // We will render skullImg into an offscreen bitmap of size userRep
                        // and compute difference in the skull bounding region
                        let minX = Int(pxCX - pxW / 2.0)
                        let maxX = Int(pxCX + pxW / 2.0)
                        let minY = Int(pxCY - pxH / 2.0)
                        let maxY = Int(pxCY + pxH / 2.0)
                        
                        // Render skull
                        let testRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: maxX - minX + 1, pixelsHigh: maxY - minY + 1, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
                        NSGraphicsContext.saveGraphicsState()
                        let ctx = NSGraphicsContext(bitmapImageRep: testRep)
                        NSGraphicsContext.current = ctx
                        
                        // Draw
                        let targetRect = NSRect(x: 0, y: 0, width: Double(maxX - minX + 1), height: Double(maxY - minY + 1))
                        skullImg.draw(in: targetRect, from: .zero, operation: .copy, fraction: 1.0)
                        NSGraphicsContext.restoreGraphicsState()
                        
                        // Compare pixels
                        var diffSum = 0.0
                        var count = 0
                        for y in 0..<(maxY - minY + 1) {
                            let uy = minY + y
                            if uy < 0 || uy >= userRep.pixelsHigh { continue }
                            for x in 0..<(maxX - minX + 1) {
                                let ux = minX + x
                                if ux < 0 || ux >= userRep.pixelsWide { continue }
                                
                                let tc = testRep.colorAt(x: x, y: y)!
                                let uc = userRep.colorAt(x: ux, y: uy)!
                                
                                if tc.alphaComponent > 0.5 {
                                    // Compare bone white / blue
                                    let diff = abs(tc.redComponent - uc.redComponent) +
                                               abs(tc.greenComponent - uc.greenComponent) +
                                               abs(tc.blueComponent - uc.blueComponent)
                                    diffSum += diff
                                    count += 1
                                }
                            }
                        }
                        
                        if count > 500 {
                            let score = diffSum / Double(count)
                            if score < bestScore {
                                bestScore = score
                                bestParams = (cx, cy, w, h, rot)
                            }
                        }
                    }
                }
            }
        }
    }
    print("Best Skull: cx: \(bestParams.cx)%, cy: \(bestParams.cy)%, w: \(bestParams.w)%, h: \(bestParams.h)%, rot: \(bestParams.rot)°, score: \(bestScore)")
}

testSkull()
