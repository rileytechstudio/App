import AppKit

let bgUrl = URL(fileURLWithPath: "assets/Selected Background.png")
let skelUrl = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")
let soloUrl = URL(fileURLWithPath: "assets/Character_YoungerBoy_Solo.png")

guard let bgImg = NSImage(contentsOf: bgUrl),
      let bgRep = NSBitmapImageRep(data: bgImg.tiffRepresentation!),
      let skelImg = NSImage(contentsOf: skelUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!),
      let soloImg = NSImage(contentsOf: soloUrl),
      let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!) else {
    print("Could not load")
    exit(1)
}

let W = 1366
let H = 1024

// Let's see: How tall is the character in the exploration frame?
// In CSS:
// .anatomy-exploration-frame: 1366x1024
// .anatomy-exploration-char-container: bottom: 5% (51.2px from bottom => y = 1024 - 51.2 = 972.8 bottom), height: 90.3% (924.6px tall)
// BUT wait, how tall is the solo character in reality?
// Let's check how the exploration frame renders in preview/index.html or how it renders in iOS!

print("Solo character size: \(soloRep.pixelsWide) x \(soloRep.pixelsHigh)")
print("Skel bounds: x: 549..817 (w: 269), y: 102..844 (h: 743)")

// Let's crop the skeleton to its non-transparent bounds:
let skelMinX = 549
let skelMinY = 102
let skelW = 817 - 549 + 1 // 269
let skelH = 844 - 102 + 1 // 743

print("Skel cropped aspect ratio: \(Double(skelW) / Double(skelH)) (269 / 743 = \(269.0 / 743.0))")
print("Solo character aspect ratio: \(Double(soloRep.pixelsWide) / Double(soloRep.pixelsHigh)) (186 / 538 = \(186.0 / 538.0))")

