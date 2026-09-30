import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let img = NSImage(contentsOf: urlSkel)!

let canvas = NSImage(size: NSSize(width: 400, height: 400))
canvas.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .none
// Left arm: x: 0..80, y: 150..410 (h: 260)
img.draw(in: NSRect(x: 0, y: 0, width: 200, height: 400),
         from: NSRect(x: 0, y: 681 - 410, width: 80, height: 260),
         operation: .sourceOver, fraction: 1.0)
// Right arm: x: 130..200, y: 190..410 (h: 220)
img.draw(in: NSRect(x: 200, y: 0, width: 200, height: 400),
         from: NSRect(x: 130, y: 681 - 410, width: 70, height: 220),
         operation: .sourceOver, fraction: 1.0)
canvas.unlockFocus()

let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/zoom_truth_arms.png"))
print("Saved zoom_truth_arms.png")
