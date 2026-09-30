import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning for right elbow x: 140..180, y: 265..285:")
for y in 265...285 {
    var xs: [Int] = []
    for x in 140...180 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            xs.append(x)
        }
    }
    print("y=\(y): count=\(xs.count) range=\(xs.first ?? 0)..\(xs.last ?? 0)")
}

print("\nScanning for right wrist x: 155..190, y: 345..365:")
for y in 345...365 {
    var xs: [Int] = []
    for x in 155...190 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            xs.append(x)
        }
    }
    print("y=\(y): count=\(xs.count) range=\(xs.first ?? 0)..\(xs.last ?? 0)")
}
