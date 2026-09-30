import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let img = NSImage(contentsOf: urlSkel)!

let kneeCanvas = NSImage(size: NSSize(width: 200, height: 200))
kneeCanvas.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .none
img.draw(in: NSRect(x: 0, y: 0, width: 200, height: 200),
         from: NSRect(x: 30, y: 681 - 535, width: 40, height: 40),
         operation: .sourceOver, fraction: 1.0)
kneeCanvas.unlockFocus()

let kneeRep = NSBitmapImageRep(data: kneeCanvas.tiffRepresentation!)!
try! kneeRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/zoom_truth_knee.png"))
print("Saved zoom_truth_knee.png")
