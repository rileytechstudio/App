import AppKit

// 1. Load user's truth image
let urlUser = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790692100225.png")
let imgUser = NSImage(contentsOf: urlUser)!
let repUser = NSBitmapImageRep(data: imgUser.tiffRepresentation!)!

// 2. Load character solo
let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

// Create pink silhouette
let pinkRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(charW), pixelsHigh: Int(charH), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
for y in 0..<Int(charH) {
    for x in 0..<Int(charW) {
        let c = repSolo.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            pinkRep.setColor(NSColor(calibratedRed: 1.0, green: 0.655, blue: 0.929, alpha: c.alphaComponent), atX: x, y: y)
        } else {
            pinkRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}
let imgPink = NSImage(data: pinkRep.representation(using: .png, properties: [:])!)!

// High-res source bounds in Older Boy Skeleton.png:
let srcSkelMinX = 596.0
let srcSkelMinY = 371.0
let srcSkelW = 414.0
let srcSkelH = 1262.0

// Destination bounds mapped from media_1790692100225.png:
let skelMinX = 6.63
let skelMinY = 10.66
let skelW = 196.14
let skelH = 667.67

// Test 3 skull shifts around dx=4.6, dy=6.1:
for (dx, dy) in [(4.6, 6.1), (4.0, 5.5), (5.0, 6.5)] {
    let canvas = NSImage(size: NSSize(width: charW, height: charH))
    canvas.lockFocus()
    imgPink.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))
    
    // Draw body parts from scratch/unmatted_Bone_older_boy_*.png:
    // Slices from earlier:
    let bodySlices = [
        ("spine", 720.0, 535.0, 66.0, 411.0, 0.0, 0.0, 1),
        ("pelvis", 671.0, 920.0, 210.0, 201.0, 0.0, 0.0, 2),
        ("humerus_right", 845.0, 725.0, 41.0, 116.0, 0.0, 0.0, 2),
        ("radius_ulna_right", 845.0, 830.0, 70.0, 151.0, 0.0, 0.0, 2),
        ("femur_right", 785.0, 1040.0, 101.0, 276.0, 0.0, 0.0, 2),
        ("ribcage", 635.0, 625.0, 241.0, 241.0, 0.0, 0.0, 3),
        ("humerus_left", 610.0, 645.0, 66.0, 166.0, 0.0, 0.0, 4),
        ("femur_left", 655.0, 1040.0, 106.0, 276.0, 0.0, 0.0, 4),
        ("radius_ulna_left", 596.0, 800.0, 95.0, 171.0, 0.0, 0.0, 5),
        ("hands_left", 655.0, 965.0, 66.0, 111.0, 0.0, 0.0, 6),
        ("hands_right", 885.0, 980.0, 52.0, 96.0, 0.0, 0.0, 6),
        ("fibula_tibia_right", 820.0, 1300.0, 66.0, 266.0, 0.0, 0.0, 6),
        ("fibula_tibia_left", 651.0, 1303.0, 85.0, 263.0, 0.0, 0.0, 7),
        ("feet_right", 820.0, 1540.0, 148.0, 71.0, 0.0, 0.0, 7),
        ("feet_left", 646.0, 1545.0, 135.0, 89.0, 0.0, 0.0, 8),
        ("skull", 700.0, 372.0, 164.0, 165.0, dx, dy, 10)
    ]
    
    let sorted = bodySlices.sorted { $0.7 < $1.7 }
    for s in sorted {
        let file = "scratch/unmatted_Bone_older_boy_\(s.0).png"
        guard let pImg = NSImage(contentsOf: URL(fileURLWithPath: file)) else { continue }
        let cLeft = skelMinX + (s.1 - srcSkelMinX) / srcSkelW * skelW + s.5
        let cTop = skelMinY + (s.2 - srcSkelMinY) / srcSkelH * skelH + s.6
        let cW = s.3 / srcSkelW * skelW
        let cH = s.4 / srcSkelH * skelH
        let cocoaY = charH - cTop - cH
        pImg.draw(in: NSRect(x: cLeft, y: cocoaY, width: cW, height: cH),
                  from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
    }
    canvas.unlockFocus()
    
    let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/test_highres_dx\(Int(dx*10))_dy\(Int(dy*10)).png"))
}

// Side by side comparison with user upload cropped:
// User upload character is at x: 117..282 (w: 166), y: 125..635 (h: 511)
let sideCanvas = NSImage(size: NSSize(width: 480, height: 681))
sideCanvas.lockFocus()
NSColor(calibratedWhite: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: 480, height: 681).fill()

// Draw User Upload (left)
let userScale = 681.0 / 511.0
let userW = 166.0 * userScale
let cocoaUserCropY = Double(repUser.pixelsHigh) - 125.0 - 511.0
imgUser.draw(in: NSRect(x: 20, y: 0, width: userW, height: 681),
             from: NSRect(x: 117, y: cocoaUserCropY, width: 166, height: 511),
             operation: .sourceOver, fraction: 1.0)

// Draw our highres test (right)
let imgTest = NSImage(contentsOf: URL(fileURLWithPath: "scratch/test_highres_dx46_dy61.png"))!
imgTest.draw(in: NSRect(x: 240, y: 0, width: charW, height: charH))

sideCanvas.unlockFocus()

let sideRep = NSBitmapImageRep(data: sideCanvas.tiffRepresentation!)!
try! sideRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/highres_vs_user_upload.png"))
print("Saved scratch/highres_vs_user_upload.png")
