import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790692100225.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

// Crop x: 110..290 (w: 181), y: 120..640 (h: 521)
let pw = 181
let ph = 521
let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<ph {
    for x in 0..<pw {
        let c = rep.colorAt(x: 110 + x, y: 120 + y)!
        cropRep.setColor(c, atX: x, y: y)
    }
}

let data = cropRep.representation(using: .png, properties: [:])!
try! data.write(to: URL(fileURLWithPath: "scratch/cropped_new_upload.png"))
print("Saved scratch/cropped_new_upload.png")
