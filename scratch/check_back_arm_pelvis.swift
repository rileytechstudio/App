import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning for back arm vs pelvis boundary x: 140..170, y: 320..380:")
for y in 320...380 {
    var armXs: [Int] = []
    var pelvisXs: [Int] = []
    for x in 140...170 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            if x >= 155 {
                armXs.append(x)
            } else {
                pelvisXs.append(x)
            }
        }
    }
    if armXs.count > 0 || pelvisXs.count > 0 {
        print("y=\(y): pelvis=\(pelvisXs.count > 0 ? "\(pelvisXs.first!)..\(pelvisXs.last!)" : "none") arm=\(armXs.count > 0 ? "\(armXs.first!)..\(armXs.last!)" : "none")")
    }
}
