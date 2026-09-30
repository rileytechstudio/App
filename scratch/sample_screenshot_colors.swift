import AppKit

let fm = FileManager.default
let files = try! fm.contentsOfDirectory(atPath: "Anatomy Explorer")
let screenshotFile = files.first { $0.contains("Screenshot") && $0.contains("9.22.14") }!

let url = URL(fileURLWithPath: "Anatomy Explorer/\(screenshotFile)")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

print("Background at (10, 10): \(rep.colorAt(x: 10, y: 10)!)")
print("Center at (137, 50): \(rep.colorAt(x: 137, y: 50)!)")
print("Pink body at (137, 200): \(rep.colorAt(x: 137, y: 200)!)")
print("Bone at (137, 100): \(rep.colorAt(x: 137, y: 100)!)")
print("Feet at (137, 450): \(rep.colorAt(x: 137, y: 450)!)")

