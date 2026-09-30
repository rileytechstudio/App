import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let img = NSImage(contentsOf: urlSkel)!

let canvas = NSImage(size: NSSize(width: 300, height: 300))
canvas.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .none
img.draw(in: NSRect(x: 0, y: 0, width: 300, height: 300),
         from: NSRect(x: 25, y: 681 - 681, width: 100, height: 100),
         operation: .sourceOver, fraction: 1.0)
canvas.unlockFocus()

let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/zoom_truth_feet.png"))
print("Saved zoom_truth_feet.png")
