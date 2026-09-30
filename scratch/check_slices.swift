import AppKit

let files = [
    "whole_Bone_older_boy_skull.png",
    "whole_Bone_older_boy_spine.png",
    "whole_Bone_older_boy_ribcage.png",
    "whole_Bone_older_boy_pelvis.png"
]

for f in files {
    let rep = NSBitmapImageRep(data: NSImage(contentsOf: URL(fileURLWithPath: "scratch/\(f)"))!.tiffRepresentation!)!
    print("\(f): \(rep.pixelsWide) x \(rep.pixelsHigh)")
}
