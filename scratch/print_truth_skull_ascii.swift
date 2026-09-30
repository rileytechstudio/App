import AppKit

let url = URL(fileURLWithPath: "scratch/cropped_new_upload.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

// Scan y: 5 to 130, x: 20 to 140
for y in stride(from: 8, through: 120, by: 2) {
    var line = String(format: "%3d: ", y)
    for x in stride(from: 25, through: 135, by: 2) {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isWhiteBg = (r > 0.96 && g > 0.96 && b > 0.96)
        let isPink = (r > 0.8 && g < 0.75 && b > 0.75)
        let isDark = (r < 0.35 && g < 0.35 && b < 0.45)
        let isBone = (r > 0.8 && g > 0.8 && b > 0.8 && !isWhiteBg)
        let isBlue = (b > 0.4 && g > 0.35 && !isWhiteBg && !isBone && !isPink && !isDark)
        
        if isDark { line += "#" }
        else if isBone { line += "O" }
        else if isBlue { line += "+" }
        else if isPink { line += "." }
        else if isWhiteBg { line += " " }
        else { line += "?" }
    }
    print(line)
}
