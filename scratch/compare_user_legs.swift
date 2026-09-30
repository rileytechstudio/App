import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let image = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!

func saveCrop(x: Int, y: Int, w: Int, h: Int, name: String) {
    let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    
    for cy in 0..<h {
        for cx in 0..<w {
            let px = x + cx
            let py = y + cy
            if px >= 0 && px < rep.pixelsWide && py >= 0 && py < rep.pixelsHigh {
                let color = rep.colorAt(x: px, y: py)!
                cropRep.setColor(color, atX: cx, y: cy)
            }
        }
    }
    
    let data = cropRep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: "scratch/\(name).png"))
    print("Saved scratch/\(name).png")
}

saveCrop(x: 140, y: 310, w: 45, h: 100, name: "user_left_femur")
saveCrop(x: 140, y: 390, w: 40, h: 80, name: "user_left_tibia")
saveCrop(x: 125, y: 450, w: 50, h: 50, name: "user_left_foot")

saveCrop(x: 195, y: 310, w: 45, h: 100, name: "user_right_femur")
saveCrop(x: 205, y: 390, w: 40, h: 80, name: "user_right_tibia")
saveCrop(x: 210, y: 450, w: 50, h: 50, name: "user_right_foot")

