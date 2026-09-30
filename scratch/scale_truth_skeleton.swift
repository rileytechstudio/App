import AppKit

let urlTruth = URL(fileURLWithPath: "scratch/truth_skeleton.png")
let imgTruth = NSImage(contentsOf: urlTruth)!

// Character in truth image was: x: 117..282 (w: 166), y: 125..635 (h: 511)
// In truth_skeleton.png, the size is already 166 x 511!
// We want to scale it to 220 x 681 (the size of Character_OlderBoy_Solo.png)!

let destW: CGFloat = 220.0
let destH: CGFloat = 681.0

let canvas = NSImage(size: NSSize(width: destW, height: destH))
canvas.lockFocus()

imgTruth.draw(in: NSRect(x: 0, y: 0, width: destW, height: destH),
              from: NSRect(x: 0, y: 0, width: imgTruth.size.width, height: imgTruth.size.height),
              operation: .sourceOver,
              fraction: 1.0)

canvas.unlockFocus()

let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: "scratch/truth_assembled_scaled.png"))
print("Saved scratch/truth_assembled_scaled.png (220x681)")
