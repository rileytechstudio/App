import AppKit

// Let's render each candidate piece alone on transparent background
// and compute intersection with target image bone pixels!
guard let targetImg = NSImage(contentsOfFile: "scratch/user_younger_boy_target.png"),
      let targetCg = targetImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    exit(1)
}
let targetRep = NSBitmapImageRep(cgImage: targetCg)

// Let's check feet in target:
print("Feet in target:")
for y in 420..<466 {
    var rowStr = ""
    for x in stride(from: 15, through: 60, by: 3) {
        let c = targetRep.colorAt(x: x, y: y)!
        let isWhite = c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8
        rowStr += isWhite ? "#" : "."
    }
    if rowStr.contains("#") {
        print(String(format: "%3d: ", y) + rowStr)
    }
}
