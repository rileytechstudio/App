import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let imgSkel = NSImage(contentsOf: urlSkel)!

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

// 1. Overlay on Pink Silhouette
let canvasPink = NSImage(size: NSSize(width: charW, height: charH))
canvasPink.lockFocus()
imgPink.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))
imgSkel.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))
canvasPink.unlockFocus()

let repPink = NSBitmapImageRep(data: canvasPink.tiffRepresentation!)!
try! repPink.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/truth_on_pink.png"))

// 2. Overlay on Actual Character Solo
let canvasSolo = NSImage(size: NSSize(width: charW, height: charH))
canvasSolo.lockFocus()
imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))
imgSkel.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))
canvasSolo.unlockFocus()

let repSoloOut = NSBitmapImageRep(data: canvasSolo.tiffRepresentation!)!
try! repSoloOut.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/truth_on_solo.png"))

// 3. Side by side: User's original cropped upload vs Our overlay on pink
let sideCanvas = NSImage(size: NSSize(width: 480, height: 681))
sideCanvas.lockFocus()
NSColor(calibratedWhite: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: 480, height: 681).fill()

// Draw original user cropped upload scaled to 681 height:
let urlUser = URL(fileURLWithPath: "scratch/cropped_new_upload.png")
let imgUser = NSImage(contentsOf: urlUser)!
let userW = 166.0 * (681.0 / 511.0)
imgUser.draw(in: NSRect(x: 20, y: 0, width: userW, height: 681),
             from: NSRect(x: 0, y: 0, width: 166, height: 511),
             operation: .sourceOver,
             fraction: 1.0)

// Draw our overlay on pink
canvasPink.draw(in: NSRect(x: 240, y: 0, width: charW, height: charH))

sideCanvas.unlockFocus()

let repSide = NSBitmapImageRep(data: sideCanvas.tiffRepresentation!)!
try! repSide.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/side_by_side_user_upload_match.png"))

print("Saved verification images")
