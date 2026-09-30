import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let img = NSImage(contentsOf: urlSkel)!

let neckCanvas = NSImage(size: NSSize(width: 300, height: 300))
neckCanvas.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .none
// Head & neck region: x: 40..170 (w: 130), y: 0..150 (h: 150)
img.draw(in: NSRect(x: 0, y: 0, width: 300, height: 300),
         from: NSRect(x: 40, y: 681 - 150, width: 130, height: 150),
         operation: .sourceOver, fraction: 1.0)
neckCanvas.unlockFocus()

let rep = NSBitmapImageRep(data: neckCanvas.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/zoom_truth_neck.png"))
print("Saved zoom_truth_neck.png")
