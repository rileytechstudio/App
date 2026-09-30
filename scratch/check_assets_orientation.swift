import AppKit

func checkOrientation(path: String) {
    guard let img = NSImage(contentsOfFile: path),
          let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
        print("\(path): Failed to load")
        return
    }
    let w = rep.pixelsWide
    let h = rep.pixelsHigh
    var m00 = 0.0, m10 = 0.0, m01 = 0.0
    for y in 0..<h {
        for x in 0..<w {
            if rep.colorAt(x: x, y: y)!.alphaComponent > 0.1 {
                m00 += 1.0
                m10 += Double(x)
                m01 += Double(y)
            }
        }
    }
    guard m00 > 10 else { return }
    let cx = m10 / m00
    let cy = m01 / m00
    var mu20 = 0.0, mu02 = 0.0, mu11 = 0.0
    for y in 0..<h {
        for x in 0..<w {
            if rep.colorAt(x: x, y: y)!.alphaComponent > 0.1 {
                let dx = Double(x) - cx
                let dy = Double(y) - cy
                mu20 += dx * dx
                mu02 += dy * dy
                mu11 += dx * dy
            }
        }
    }
    let angleRad = 0.5 * atan2(2.0 * mu11, mu02 - mu20)
    let angleDeg = angleRad * 180.0 / Double.pi
    print("\(path) (\(w)x\(h)): angle = \(String(format: "%.1f", angleDeg))°")
}

checkOrientation(path: "assets/bones/Bone_humerus_left.png")
checkOrientation(path: "assets/bones/Bone_humerus_right.png")
checkOrientation(path: "assets/bones/Bone_radius_ulna_left.png")
checkOrientation(path: "assets/bones/Bone_radius_ulna_right.png")
checkOrientation(path: "assets/bones/Bone_hands_left.png")
checkOrientation(path: "assets/bones/Bone_hands_right.png")
checkOrientation(path: "assets/bones/Bone_femur_left.png")
checkOrientation(path: "assets/bones/Bone_femur_right.png")
checkOrientation(path: "assets/bones/Bone_fibula_tibia_left.png")
checkOrientation(path: "assets/bones/Bone_fibula_tibia_right.png")
checkOrientation(path: "assets/bones/Bone_feet_left.png")
checkOrientation(path: "assets/bones/Bone_feet_right.png")

