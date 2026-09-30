import AppKit

let footUrl = URL(fileURLWithPath: "assets/bones/Bone_feet_left.png")
let footImg = NSImage(contentsOf: footUrl)!
let rep = NSBitmapImageRep(data: footImg.tiffRepresentation!)!

print("Bone_feet_left: \(rep.pixelsWide) x \(rep.pixelsHigh)")
for y in stride(from: 0, to: rep.pixelsHigh, by: 10) {
    var line = ""
    for x in stride(from: 0, to: rep.pixelsWide, by: 10) {
        let a = rep.colorAt(x: x, y: y)!.alphaComponent
        line += a > 0.3 ? "#" : "."
    }
    print(String(format: "%3d: ", y) + line)
}

