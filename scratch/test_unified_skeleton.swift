import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOfFile: targetUrl.path)!
let targetCg = targetImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!

let charImg = NSImage(contentsOfFile: "assets/Character_YoungerBoy_Solo.png")!
let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let W = charCg.width // 186
let H = charCg.height // 538

// The original 10 bone definitions relative to the skeleton box (aspect 841 / 1690):
struct BoxBone {
    let id: String
    let file: String
    let left: Double
    let top: Double
    let width: Double
    let height: Double
    let zIndex: Int
}

let originalBones: [BoxBone] = [
    BoxBone(id: "spine", file: "assets/bones/Bone_spine.png", left: 44.95, top: 15.68, width: 9.04, height: 30.24, zIndex: 1),
    BoxBone(id: "skull", file: "assets/bones/Bone_skull.png", left: 36.86, top: 1.48, width: 26.16, height: 16.15, zIndex: 5),
    BoxBone(id: "ribcage", file: "assets/bones/Bone_ribcage.png", left: 27.82, top: 16.51, width: 44.35, height: 19.17, zIndex: 4),
    BoxBone(id: "humerus", file: "assets/bones/Bone_humerus.png", left: 16.53, top: 20.65, width: 66.94, height: 17.93, zIndex: 2),
    BoxBone(id: "radius_ulna", file: "assets/bones/Bone_radius_ulna.png", left: 7.13, top: 38.82, width: 85.73, height: 16.63, zIndex: 6),
    BoxBone(id: "hands", file: "assets/bones/Bone_hands.png", left: 0.00, top: 54.56, width: 100.00, height: 12.01, zIndex: 7),
    BoxBone(id: "pelvis", file: "assets/bones/Bone_pelvis.png", left: 31.51, top: 42.49, width: 36.98, height: 12.96, zIndex: 3),
    BoxBone(id: "femur", file: "assets/bones/Bone_femur.png", left: 29.13, top: 51.48, width: 41.62, height: 22.72, zIndex: 2),
    BoxBone(id: "fibula_tibia", file: "assets/bones/Bone_fibula_tibia.png", left: 30.32, top: 73.67, width: 39.36, height: 19.94, zIndex: 8),
    BoxBone(id: "feet", file: "assets/bones/Bone_feet.png", left: 18.07, top: 92.19, width: 63.85, height: 7.81, zIndex: 9)
]

// Render the 10 bones into a 841 x 1690 skeleton canvas
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let skCtx = CGContext(data: nil, width: 841, height: 1690, bitsPerComponent: 8, bytesPerRow: 841 * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

let sorted = originalBones.sorted { $0.zIndex < $1.zIndex }
for b in sorted {
    guard let img = NSImage(contentsOfFile: b.file),
          let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }
    let x = b.left / 100.0 * 841.0
    let y = (100.0 - b.top - b.height) / 100.0 * 1690.0
    let w = b.width / 100.0 * 841.0
    let h = b.height / 100.0 * 1690.0
    skCtx.draw(cg, in: CGRect(x: x, y: y, width: w, height: h))
}
let assembledCg = skCtx.makeImage()!

// Now, in media_1790613333821.png:
// Let's see how this assembled skeleton maps onto the character frame (186 x 538)!
// If the skeleton box is:
// left: -3.5%, top: 1.5%, width: 107.0%, height: 96.0% (or similar)
func testScale(boxLeft: Double, boxTop: Double, boxW: Double, boxH: Double, name: String) {
    guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
    
    // Draw character silhouette
    ctx.setAlpha(0.35)
    ctx.draw(charCg, in: CGRect(x: 0, y: 0, width: W, height: H))
    ctx.setAlpha(1.0)
    
    // Draw assembled skeleton inside the box
    let bx = boxLeft / 100.0 * Double(W)
    let by = (100.0 - boxTop - boxH) / 100.0 * Double(H)
    let bw = boxW / 100.0 * Double(W)
    let bh = boxH / 100.0 * Double(H)
    ctx.draw(assembledCg, in: CGRect(x: bx, y: by, width: bw, height: bh))
    
    guard let compCg = ctx.makeImage() else { return }
    
    // Make side by side with target
    let totalW = W * 2 + 20
    guard let sbsCtx = CGContext(data: nil, width: totalW, height: H, bitsPerComponent: 8, bytesPerRow: totalW * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
    sbsCtx.draw(targetCg, in: CGRect(x: 0, y: 0, width: W, height: H))
    sbsCtx.draw(compCg, in: CGRect(x: W + 20, y: 0, width: W, height: H))
    
    let sbsImg = sbsCtx.makeImage()!
    let rep = NSBitmapImageRep(cgImage: sbsImg)
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: "scratch/unified_comparison_\(name).png"))
    print("Saved scratch/unified_comparison_\(name).png")
}

// In target image (161 x 466):
// Skull top is at y = 18 px = 3.8%
// Feet bottom is at y = 465 px = 99.8%
// Height of skeleton = 96.0%
// Hands reach from left = 0% to right = 100%
// In original skeleton, hands width is 100% of skeleton box width.
// So skeleton box width = 100%!
// Let's test a few slight box placements:
testScale(boxLeft: 0.0, boxTop: 2.0, boxW: 100.0, boxH: 96.0, name: "100_96")
testScale(boxLeft: -2.0, boxTop: 1.5, boxW: 104.0, boxH: 97.0, name: "104_97")
testScale(boxLeft: -4.0, boxTop: 1.0, boxW: 108.0, boxH: 98.0, name: "108_98")

