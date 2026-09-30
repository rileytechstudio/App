import AppKit

let userUrl = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let userImg = NSImage(contentsOf: userUrl)!
let rep = NSBitmapImageRep(data: userImg.tiffRepresentation!)!

let sMinX = 111.0
let sMinY = 31.0
let charW = 161.0
let charH = 466.0

// Let's create an output image rep
let outRep = NSBitmapImageRep(data: userImg.tiffRepresentation!)!
NSGraphicsContext.saveGraphicsState()
let ctx = NSGraphicsContext(bitmapImageRep: outRep)
NSGraphicsContext.current = ctx

// Test boxes:
struct Box {
    let name: String
    let x: Double
    let y: Double
    let w: Double
    let h: Double
    let rot: Double
}

let testBoxes: [Box] = [
    Box(name: "skull", x: 50.0, y: 17.0, w: 48.0, h: 18.0, rot: 0),
    Box(name: "ribcage", x: 50.0, y: 36.0, w: 78.0, h: 22.0, rot: 0),
    Box(name: "pelvis", x: 50.0, y: 58.0, w: 60.0, h: 16.0, rot: 0),
    Box(name: "spine", x: 50.0, y: 39.0, w: 8.0, h: 36.0, rot: 0),
    
    // Left arm
    Box(name: "l_hum", x: 21.0, y: 36.0, w: 16.0, h: 18.0, rot: 15),
    Box(name: "l_rad", x: 14.0, y: 49.0, w: 12.0, h: 14.0, rot: 8),
    Box(name: "l_hand", x: 10.0, y: 59.0, w: 12.0, h: 10.0, rot: 5),
    
    // Right arm
    Box(name: "r_hum", x: 79.0, y: 36.0, w: 16.0, h: 18.0, rot: -15),
    Box(name: "r_rad", x: 86.0, y: 49.0, w: 12.0, h: 14.0, rot: -8),
    Box(name: "r_hand", x: 90.0, y: 59.0, w: 12.0, h: 10.0, rot: -5),
    
    // Left leg
    Box(name: "l_fem", x: 34.0, y: 70.0, w: 18.0, h: 20.0, rot: 4),
    Box(name: "l_tib", x: 31.0, y: 86.0, w: 14.0, h: 17.0, rot: 2),
    Box(name: "l_foot", x: 25.0, y: 95.0, w: 18.0, h: 7.0, rot: -6),
    
    // Right leg
    Box(name: "r_fem", x: 66.0, y: 70.0, w: 18.0, h: 20.0, rot: -4),
    Box(name: "r_tib", x: 69.0, y: 86.0, w: 14.0, h: 17.0, rot: -2),
    Box(name: "r_foot", x: 75.0, y: 95.0, w: 18.0, h: 7.0, rot: 6)
]

for b in testBoxes {
    let px = sMinX + (b.x / 100.0) * charW
    let py = sMinY + (b.y / 100.0) * charH
    let pw = (b.w / 100.0) * charW
    let ph = (b.h / 100.0) * charH
    
    // CoreGraphics has origin at bottom-left in Cocoa, but let's check
    // In NSBitmapImageRep, origin is top-left if isFlipped or let's transform:
    let cgCtx = ctx!.cgContext
    cgCtx.saveGState()
    // Convert to CG coordinates (y from bottom)
    let cgY = Double(rep.pixelsHigh) - py
    cgCtx.translateBy(x: px, y: cgY)
    cgCtx.rotate(by: CGFloat(-b.rot * Double.pi / 180.0))
    cgCtx.setStrokeColor(NSColor.red.cgColor)
    cgCtx.setLineWidth(1.5)
    cgCtx.stroke(CGRect(x: -pw/2.0, y: -ph/2.0, width: pw, height: ph))
    cgCtx.restoreGState()
}

NSGraphicsContext.restoreGraphicsState()
let outData = outRep.representation(using: .png, properties: [:])!
try! outData.write(to: URL(fileURLWithPath: "scratch/test_overlay_boxes.png"))
print("Saved scratch/test_overlay_boxes.png")

