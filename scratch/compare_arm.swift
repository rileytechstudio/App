import AppKit

let userShotUrl = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790692100225.png")
let soloUrl = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let reassemblyUrl = URL(fileURLWithPath: "scratch/final_truth_reassembly.png")
let truthUrl = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")

let imgUserShot = NSImage(contentsOf: userShotUrl)!
let imgSolo = NSImage(contentsOf: soloUrl)!
let imgReassembly = NSImage(contentsOf: reassemblyUrl)!
let imgTruth = NSImage(contentsOf: truthUrl)!

let canvas = NSImage(size: NSSize(width: 400, height: 400))
canvas.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .none

// Zoom into left arm elbow/wrist area (x: 0..70, y: 220..380)
// Panel A: User shot (crop)
let shotRep = NSBitmapImageRep(data: imgUserShot.tiffRepresentation!)!
let shotH = CGFloat(shotRep.pixelsHigh)
// scale ratio: 166 -> 220 (1.325), 511 -> 681 (1.3326)
// In user shot: character is x: 117..282, y: 125..635
// Top-down y: 220 in solo corresponds to 125 + 220 / 1.3326 = 290 in user shot
// x: 0..70 corresponds to 117..170 in user shot
let cropA = NSRect(x: 117, y: shotH - (125 + 380 / 1.3326), width: 70 / 1.325, height: 160 / 1.3326)
imgUserShot.draw(in: NSRect(x: 0, y: 0, width: 133, height: 400),
                 from: cropA, operation: .sourceOver, fraction: 1.0)

// Panel B: Reassembled
imgReassembly.draw(in: NSRect(x: 133, y: 0, width: 133, height: 400),
                   from: NSRect(x: 0, y: 681 - 380, width: 70, height: 160),
                   operation: .sourceOver, fraction: 1.0)

// Panel C: Solo + Truth
imgSolo.draw(in: NSRect(x: 266, y: 0, width: 133, height: 400),
             from: NSRect(x: 0, y: 681 - 380, width: 70, height: 160),
             operation: .sourceOver, fraction: 1.0)
imgTruth.draw(in: NSRect(x: 266, y: 0, width: 133, height: 400),
              from: NSRect(x: 0, y: 681 - 380, width: 70, height: 160),
              operation: .sourceOver, fraction: 1.0)

canvas.unlockFocus()

let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/zoom_elbow_wrist_compare.png"))
print("Saved zoom_elbow_wrist_compare.png")
