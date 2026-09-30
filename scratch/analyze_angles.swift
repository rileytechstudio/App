import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOf: targetUrl)!
let rep = NSBitmapImageRep(data: targetImg.tiffRepresentation!)!

let W = rep.pixelsWide
let H = rep.pixelsHigh

func isBonePixel(_ x: Int, _ y: Int) -> Bool {
    guard x >= 0 && x < W && y >= 0 && y < H else { return false }
    guard let c = rep.colorAt(x: x, y: y) else { return false }
    let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
    if r > 0.82 && g > 0.82 && b > 0.82 { return true }
    if b > 0.55 && b > r + 0.15 && g > 0.35 { return true }
    if r < 0.28 && g < 0.28 && b < 0.42 && (r + g + b) > 0.15 { return true }
    return false
}

// Compute principal angle using image moments (PCA / inertia axis)
func computeAngle(xRange: ClosedRange<Int>, yRange: ClosedRange<Int>, name: String) {
    var m00 = 0.0, m10 = 0.0, m01 = 0.0
    for y in yRange {
        for x in xRange {
            if isBonePixel(x, y) {
                m00 += 1.0
                m10 += Double(x)
                m01 += Double(y)
            }
        }
    }
    guard m00 > 10 else {
        print("\(name): Not enough pixels")
        return
    }
    let cx = m10 / m00
    let cy = m01 / m00
    
    var mu20 = 0.0, mu02 = 0.0, mu11 = 0.0
    for y in yRange {
        for x in xRange {
            if isBonePixel(x, y) {
                let dx = Double(x) - cx
                let dy = Double(y) - cy
                mu20 += dx * dx
                mu02 += dy * dy
                mu11 += dx * dy
            }
        }
    }
    
    // Principal axis angle (relative to vertical y-axis)
    // Note: In image coords, y increases downwards.
    // Vertical is dy != 0, dx = 0.
    // theta = 0.5 * atan2(2 * mu11, mu20 - mu02)
    // Angle with y-axis:
    let angleRad = 0.5 * atan2(2.0 * mu11, mu02 - mu20)
    let angleDeg = angleRad * 180.0 / Double.pi
    print("\(name): Center: (\(String(format: "%.1f", cx)), \(String(format: "%.1f", cy))), Angle from vertical: \(String(format: "%.1f", angleDeg))°")
}

computeAngle(xRange: 5...35, yRange: 125...215, name: "Left Humerus")
computeAngle(xRange: 125...157, yRange: 125...215, name: "Right Humerus")
computeAngle(xRange: 1...28, yRange: 200...260, name: "Left Radius")
computeAngle(xRange: 130...160, yRange: 200...260, name: "Right Radius")
computeAngle(xRange: 0...25, yRange: 245...289, name: "Left Hand")
computeAngle(xRange: 136...160, yRange: 245...291, name: "Right Hand")
computeAngle(xRange: 31...70, yRange: 275...375, name: "Left Femur")
computeAngle(xRange: 85...129, yRange: 275...375, name: "Right Femur")
computeAngle(xRange: 33...65, yRange: 360...435, name: "Left Tibia")
computeAngle(xRange: 95...129, yRange: 360...435, name: "Right Tibia")
computeAngle(xRange: 19...58, yRange: 420...464, name: "Left Foot")
computeAngle(xRange: 105...146, yRange: 420...465, name: "Right Foot")

