import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let img = NSImage(contentsOf: urlSkel)!

let canvas = NSImage(size: NSSize(width: 300, height: 600))
canvas.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .none
// Right leg: x: 100..210 (w: 110), y: 380..680 (h: 300)
img.draw(in: NSRect(x: 0, y: 0, width: 300, height: 600),
         from: NSRect(x: 100, y: 681 - 680, width: 110, height: 300),
         operation: .sourceOver, fraction: 1.0)
canvas.unlockFocus()

let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/zoom_truth_right_leg.png"))
print("Saved zoom_truth_right_leg.png")
