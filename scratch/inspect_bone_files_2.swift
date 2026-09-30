import AppKit

func showAscii(path: String) {
    guard let img = NSImage(contentsOfFile: path),
          let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
        print("Failed: \(path)")
        return
    }
    print("=== \(path) (\(rep.pixelsWide) x \(rep.pixelsHigh)) ===")
    let stepY = max(1, rep.pixelsHigh / 20)
    let stepX = max(1, rep.pixelsWide / 25)
    for y in stride(from: 0, to: rep.pixelsHigh, by: stepY) {
        var line = ""
        for x in stride(from: 0, to: rep.pixelsWide, by: stepX) {
            let a = rep.colorAt(x: x, y: y)!.alphaComponent
            line += a > 0.3 ? "#" : "."
        }
        print(line)
    }
}

showAscii(path: "assets/bones/Bone_radius_ulna_right.png")
showAscii(path: "assets/bones/Bone_humerus_right.png")
