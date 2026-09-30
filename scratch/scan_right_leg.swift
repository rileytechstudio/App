import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning right knee (x=115..140, y=495..515):")
for y in 495...515 {
    var femurXs: [Int] = []
    var tibiaXs: [Int] = []
    for x in 110...145 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            // let us see if there is a gap or separation
            femurXs.append(x)
        }
    }
    print("y=\(y): count=\(femurXs.count) range=\(femurXs.first ?? 0)..\(femurXs.last ?? 0)")
}

print("\nScanning right ankle (x=120..155, y=610..635):")
for y in 610...635 {
    var ankleXs: [Int] = []
    for x in 120...155 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            ankleXs.append(x)
        }
    }
    print("y=\(y): count=\(ankleXs.count) range=\(ankleXs.first ?? 0)..\(ankleXs.last ?? 0)")
}
