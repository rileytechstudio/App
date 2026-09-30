import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let img = NSImage(contentsOf: urlSkel)!

let canvas = NSImage(size: NSSize(width: 300, height: 300))
canvas.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .none
// Left elbow: x: 5..55 (w: 50), y: 230..280 (h: 50)
img.draw(in: NSRect(x: 0, y: 0, width: 300, height: 300),
         from: NSRect(x: 5, y: 681 - 280, width: 50, height: 50),
         operation: .sourceOver, fraction: 1.0)
canvas.unlockFocus()

let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/zoom_left_elbow.png"))
print("Saved zoom_left_elbow.png")
