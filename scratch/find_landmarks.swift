import AppKit

let userUrl = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let userImg = NSImage(contentsOf: userUrl)!
let rep = NSBitmapImageRep(data: userImg.tiffRepresentation!)!

let sMinX = 111.0
let sMinY = 31.0
let charW = 161.0
let charH = 466.0

func toPctX(_ px: Double) -> Double { ((px - sMinX) / charW) * 100.0 }
func toPctY(_ py: Double) -> Double { ((py - sMinY) / charH) * 100.0 }
func toPctW(_ pw: Double) -> Double { (pw / charW) * 100.0 }
func toPctH(_ ph: Double) -> Double { (ph / charH) * 100.0 }

// Is it bone white?
func isBoneWhite(_ x: Int, _ y: Int) -> Bool {
    guard x >= 0 && x < rep.pixelsWide && y >= 0 && y < rep.pixelsHigh else { return false }
    guard let c = rep.colorAt(x: x, y: y) else { return false }
    return c.redComponent > 0.85 && c.greenComponent > 0.85 && c.blueComponent > 0.85
}

// Is it bone blue / dark accent?
func isBoneAny(_ x: Int, _ y: Int) -> Bool {
    guard x >= 0 && x < rep.pixelsWide && y >= 0 && y < rep.pixelsHigh else { return false }
    guard let c = rep.colorAt(x: x, y: y) else { return false }
    let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
    // White
    if r > 0.85 && g > 0.85 && b > 0.85 { return true }
    // Blue accent
    if b > 0.55 && b > r + 0.15 && g > 0.35 { return true }
    // Bone dark lines / sockets
    if r < 0.25 && g < 0.25 && b < 0.4 { return true }
    return false
}

// 1. Skull landmarks
// Find topmost bone pixel near x=191, y=30..70
var skullTop = 999
for y in 30...80 {
    for x in 180...205 {
        if isBoneAny(x, y) {
            skullTop = min(skullTop, y)
        }
    }
}
// Find bottom chin pixel near x=191, y=100..150
var skullBot = 0
for y in (100...150).reversed() {
    for x in 180...205 {
        if isBoneAny(x, y) {
            skullBot = max(skullBot, y)
        }
    }
}
// Find left and right edges of skull
var skullLeft = 999, skullRight = 0
for y in skullTop...skullBot {
    for x in 140...240 {
        if isBoneAny(x, y) {
            skullLeft = min(skullLeft, x)
            skullRight = max(skullRight, x)
        }
    }
}
print("Skull: top=\(skullTop), bot=\(skullBot), left=\(skullLeft), right=\(skullRight)")
let skW = Double(skullRight - skullLeft + 1)
let skH = Double(skullBot - skullTop + 1)
let skCX = Double(skullLeft + skullRight) / 2.0
let skCY = Double(skullTop + skullBot) / 2.0
print("Skull -> x: \(String(format: "%.1f", toPctX(skCX)))%, y: \(String(format: "%.1f", toPctY(skCY)))%, w: \(String(format: "%.1f", toPctW(skW)))%, h: \(String(format: "%.1f", toPctH(skH)))%")

// 2. Ribcage landmarks
// Find clavicle top near y=140..170
var ribTop = 999, ribBot = 0, ribLeft = 999, ribRight = 0
for y in 145...245 {
    for x in 125...260 {
        if isBoneAny(x, y) {
            ribTop = min(ribTop, y)
            ribBot = max(ribBot, y)
            ribLeft = min(ribLeft, x)
            ribRight = max(ribRight, x)
        }
    }
}
print("Ribcage: top=\(ribTop), bot=\(ribBot), left=\(ribLeft), right=\(ribRight)")
let ribW = Double(ribRight - ribLeft + 1)
let ribH = Double(ribBot - ribTop + 1)
let ribCX = Double(ribLeft + ribRight) / 2.0
let ribCY = Double(ribTop + ribBot) / 2.0
print("Ribcage -> x: \(String(format: "%.1f", toPctX(ribCX)))%, y: \(String(format: "%.1f", toPctY(ribCY)))%, w: \(String(format: "%.1f", toPctW(ribW)))%, h: \(String(format: "%.1f", toPctH(ribH)))%")

// 3. Pelvis landmarks
var pelTop = 999, pelBot = 0, pelLeft = 999, pelRight = 0
for y in 260...345 {
    for x in 140...245 {
        if isBoneAny(x, y) {
            pelTop = min(pelTop, y)
            pelBot = max(pelBot, y)
            pelLeft = min(pelLeft, x)
            pelRight = max(pelRight, x)
        }
    }
}
print("Pelvis: top=\(pelTop), bot=\(pelBot), left=\(pelLeft), right=\(pelRight)")
let pelW = Double(pelRight - pelLeft + 1)
let pelH = Double(pelBot - pelTop + 1)
let pelCX = Double(pelLeft + pelRight) / 2.0
let pelCY = Double(pelTop + pelBot) / 2.0
print("Pelvis -> x: \(String(format: "%.1f", toPctX(pelCX)))%, y: \(String(format: "%.1f", toPctY(pelCY)))%, w: \(String(format: "%.1f", toPctW(pelW)))%, h: \(String(format: "%.1f", toPctH(pelH)))%")

// 4. Spine landmarks
// Spine is along x ~ 188..195
var spTop = 999, spBot = 0, spLeft = 999, spRight = 0
for y in 125...305 {
    for x in 187...196 {
        if isBoneAny(x, y) {
            spTop = min(spTop, y)
            spBot = max(spBot, y)
            spLeft = min(spLeft, x)
            spRight = max(spRight, x)
        }
    }
}
print("Spine: top=\(spTop), bot=\(spBot), left=\(spLeft), right=\(spRight)")
let spW = Double(spRight - spLeft + 1)
let spH = Double(spBot - spTop + 1)
let spCX = Double(spLeft + spRight) / 2.0
let spCY = Double(spTop + spBot) / 2.0
print("Spine -> x: \(String(format: "%.1f", toPctX(spCX)))%, y: \(String(format: "%.1f", toPctY(spCY)))%, w: \(String(format: "%.1f", toPctW(spW)))%, h: \(String(format: "%.1f", toPctH(spH)))%")

