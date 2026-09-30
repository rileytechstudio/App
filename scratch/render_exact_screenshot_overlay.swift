import AppKit

// 1. Extract clean high-res transparent skeleton from Older Boy Skeleton.png
let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let imgSkel = NSImage(contentsOf: urlSkel)!
let repSkel = NSBitmapImageRep(data: imgSkel.tiffRepresentation!)!

// Skeleton bounds: x: 596..967 (w:372), y: 372..1633 (h:1262)
let skelMinX = 596
let skelMinY = 372
let skelW = 372
let skelH = 1262

let cleanSkelRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: skelW, pixelsHigh: skelH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<skelH {
    for x in 0..<skelW {
        let sx = skelMinX + x
        let sy = skelMinY + y
        let c = repSkel.colorAt(x: sx, y: sy)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        // Bone white:
        let isWhite = r > 0.8 && g > 0.8 && b > 0.8
        // Bone cyan:
        let isCyan = b > 0.4 && g > 0.35 && g > r + 0.04
        // Eye socket and nasal cavity in head (x: 810..865, y: 440..510 in source image):
        let isEyeOrNose = (sx >= 810 && sx <= 865 && sy >= 440 && sy <= 510 && r < 0.25 && g < 0.25 && b < 0.35)
        
        if isWhite || isCyan || isEyeOrNose {
            cleanSkelRep.setColor(c, atX: x, y: y)
        } else {
            cleanSkelRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

let cleanPng = cleanSkelRep.representation(using: .png, properties: [:])!
try! cleanPng.write(to: URL(fileURLWithPath: "scratch/clean_assembled_hires.png"))
print("Saved clean hires skeleton")

// 2. Load Character_OlderBoy_Solo.png
let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = repSolo.pixelsWide // 220
let charH = repSolo.pixelsHigh // 681

// Placement from screenshot:
// originX = 2.90%, originY = 1.88%, totalW = 89.13%, totalH = 97.65%
let destX = 0.0290 * Double(charW)
let destY = 0.0188 * Double(charH)
let destW = 0.8913 * Double(charW)
let destH = 0.9765 * Double(charH)

print(String(format: "Dest rect on Solo (220x681): x:%.1f, y:%.1f, w:%.1f, h:%.1f", destX, destY, destW, destH))

let compositeImg = NSImage(size: NSSize(width: charW, height: charH))
compositeImg.lockFocus()

// Draw solo character
imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

// Draw clean skeleton
// Note: In Cocoa NSImage.draw, y=0 is at bottom!
let flippedDestY = Double(charH) - destY - destH
let cleanImg = NSImage(data: cleanPng)!
cleanImg.draw(in: NSRect(x: destX, y: flippedDestY, width: destW, height: destH))

compositeImg.unlockFocus()

let compRep = NSBitmapImageRep(data: compositeImg.tiffRepresentation!)!
let compPng = compRep.representation(using: .png, properties: [:])!
try! compPng.write(to: URL(fileURLWithPath: "scratch/test_exact_screenshot_overlay.png"))
print("Saved scratch/test_exact_screenshot_overlay.png")

