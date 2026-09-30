import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOfFile: targetUrl.path)!
let targetRep = NSBitmapImageRep(data: targetImg.tiffRepresentation!)!

let soloImg = NSImage(contentsOfFile: "assets/Character_YoungerBoy_Solo.png")!
let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!)!

print("Target dimensions: \(targetRep.pixelsWide) x \(targetRep.pixelsHigh)")
print("Solo dimensions: \(soloRep.pixelsWide) x \(soloRep.pixelsHigh)")

// In target, let's check the arm width at y = 260 (wrist/hand level):
// Target y = 260 maps to solo y = 260 / 466 * 538 = 300
var targetArmMinX = 999, targetArmMaxX = 0
for x in 0..<161 {
    let c = targetRep.colorAt(x: x, y: 260)!
    // If not purple bg
    let isBg = c.redComponent < 0.45 && c.blueComponent > 0.55
    if !isBg {
        targetArmMinX = min(targetArmMinX, x)
        targetArmMaxX = max(targetArmMaxX, x)
    }
}
print("Target body span at y=260: x in [\(targetArmMinX)..\(targetArmMaxX)], span = \(targetArmMaxX - targetArmMinX + 1)")
print("Target span as %: left: \(Double(targetArmMinX)/161.0*100)%, right: \(Double(targetArmMaxX)/161.0*100)%")

var soloArmMinX = 999, soloArmMaxX = 0
for x in 0..<186 {
    let a = soloRep.colorAt(x: x, y: 300)!.alphaComponent
    if a > 0.1 {
        soloArmMinX = min(soloArmMinX, x)
        soloArmMaxX = max(soloArmMaxX, x)
    }
}
print("Solo body span at y=300: x in [\(soloArmMinX)..\(soloArmMaxX)], span = \(soloArmMaxX - soloArmMinX + 1)")
print("Solo span as %: left: \(Double(soloArmMinX)/186.0*100)%, right: \(Double(soloArmMaxX)/186.0*100)%")

