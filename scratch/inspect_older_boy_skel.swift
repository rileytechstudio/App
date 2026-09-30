import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!
print("Older Boy Skeleton.png: \(rep.pixelsWide) x \(rep.pixelsHigh)")
