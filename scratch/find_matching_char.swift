import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOfFile: targetUrl.path)!
let targetRep = NSBitmapImageRep(data: targetImg.tiffRepresentation!)!

let fm = FileManager.default
let paths = try! fm.subpathsOfDirectory(atPath: "assets").filter { $0.hasSuffix(".png") }

for p in paths {
    if p.contains("Younger") || p.contains("Boy") || p.contains("Solo") || p.contains("Character") {
        let fullPath = "assets/\(p)"
        guard let img = NSImage(contentsOfFile: fullPath),
              let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else { continue }
        print("\(p): \(rep.pixelsWide) x \(rep.pixelsHigh)")
    }
}
