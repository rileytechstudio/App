import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let image = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!

// Let's crop out the user image's bones and save them to scratch
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

saveCrop(x: 145, y: 40, w: 95, h: 100, name: "user_skull")
saveCrop(x: 120, y: 125, w: 145, h: 130, name: "user_ribcage")
saveCrop(x: 130, y: 255, w: 125, h: 95, name: "user_pelvis")
saveCrop(x: 110, y: 150, w: 40, h: 95, name: "user_left_humerus")
saveCrop(x: 110, y: 230, w: 35, h: 65, name: "user_left_radius")
saveCrop(x: 110, y: 280, w: 30, h: 50, name: "user_left_hand")

