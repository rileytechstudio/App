import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning for pixels between x: 45..65, y: 345..365:")
for y in 345...365 {
    var handXs: [Int] = []
    var pelvisXs: [Int] = []
    var gaps: [Int] = []
    for x in 45...65 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            if x <= 53 { handXs.append(x) }
            else { pelvisXs.append(x) }
        } else {
            gaps.append(x)
        }
    }
    print("y=\(y): hand=\(handXs.count > 0 ? "\(handXs.first!)..\(handXs.last!)" : "none") gap=\(gaps.count > 0 ? "\(gaps.first!)..\(gaps.last!)" : "none") pelvis=\(pelvisXs.count > 0 ? "\(pelvisXs.first!)..\(pelvisXs.last!)" : "none")")
}
