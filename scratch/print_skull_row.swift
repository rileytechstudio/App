import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

print("Scanning skull at y=60 across x:")
for x in 40...160 {
    let c = rep.colorAt(x: x, y: 60)!
    let r = c.redComponent
    let g = c.greenComponent
    let b = c.blueComponent
    // identify type:
    var type = "BG"
    if r > 0.85 && g > 0.85 && b > 0.85 {
        type = "BONE_WHITE"
    } else if r > 0.65 && g < 0.65 && b > 0.65 {
        type = "PINK_SIL"
    } else if b > 0.5 && r < 0.4 && g > 0.3 {
        type = "BONE_BLUE"
    } else if r < 0.2 && g < 0.2 && b < 0.3 {
        type = "DARK_EYE"
    }
    if type != "BG" {
        print(String(format: "x=%d: %@ (r:%.2f, g:%.2f, b:%.2f)", x, type, r, g, b))
    }
}
