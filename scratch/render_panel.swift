import AppKit

let truthUrl = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let soloUrl = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let reassemblyUrl = URL(fileURLWithPath: "scratch/final_truth_reassembly.png")
let userShotUrl = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790692100225.png")

guard let imgTruth = NSImage(contentsOf: truthUrl) else { print("fail truth"); exit(1) }
guard let imgSolo = NSImage(contentsOf: soloUrl) else { print("fail solo"); exit(1) }
guard let imgReassembly = NSImage(contentsOf: reassemblyUrl) else { print("fail reassembly"); exit(1) }
guard let imgUserShot = NSImage(contentsOf: userShotUrl) else { print("fail userShot"); exit(1) }

let panelW: CGFloat = 220
let panelH: CGFloat = 681
let totalW = panelW * 3 + 40
let totalH = panelH + 60

let canvas = NSImage(size: NSSize(width: totalW, height: totalH))
canvas.lockFocus()

NSColor(calibratedRed: 0.08, green: 0.09, blue: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: totalW, height: totalH).fill()

let font = NSFont.boldSystemFont(ofSize: 14)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white
]

// Panel 1: User Upload Reference
"1. User Upload Reference".draw(at: NSPoint(x: 10, y: panelH + 25), withAttributes: attrs)
let shotRep = NSBitmapImageRep(data: imgUserShot.tiffRepresentation!)!
let shotH = CGFloat(shotRep.pixelsHigh)
let cropRect = NSRect(x: 117, y: shotH - 636, width: 166, height: 511)
imgUserShot.draw(in: NSRect(x: 10, y: 15, width: panelW, height: panelH),
                 from: cropRect, operation: .sourceOver, fraction: 1.0)

// Panel 2: Reassembled Slices on Solo
"2. Reassembled Natural Slices".draw(at: NSPoint(x: 20 + panelW, y: panelH + 25), withAttributes: attrs)
imgReassembly.draw(in: NSRect(x: 20 + panelW, y: 15, width: panelW, height: panelH),
                   from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

// Panel 3: Ground Truth Skeleton Overlay on Solo
"3. Ground Truth Skeleton Overlay".draw(at: NSPoint(x: 30 + panelW * 2, y: panelH + 25), withAttributes: attrs)
imgSolo.draw(in: NSRect(x: 30 + panelW * 2, y: 15, width: panelW, height: panelH),
             from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
imgTruth.draw(in: NSRect(x: 30 + panelW * 2, y: 15, width: panelW, height: panelH),
              from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

canvas.unlockFocus()

let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let destPath = "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/older_boy_skeleton_final_verification.png"
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: destPath))
print("Saved verification image to \(destPath)")
