import Foundation

let mapping: [(assetName: String, file: String)] = [
    ("AnatomyBoneOlderBoySkull", "Bone_older_boy_skull.png"),
    ("AnatomyBoneOlderBoySpine", "Bone_older_boy_spine.png"),
    ("AnatomyBoneOlderBoyRibcage", "Bone_older_boy_ribcage.png"),
    ("AnatomyBoneOlderBoyPelvis", "Bone_older_boy_pelvis.png"),
    ("AnatomyBoneOlderBoyHumerusLeft", "Bone_older_boy_humerus_left.png"),
    ("AnatomyBoneOlderBoyRadiusUlnaLeft", "Bone_older_boy_radius_ulna_left.png"),
    ("AnatomyBoneOlderBoyHandsLeft", "Bone_older_boy_hands_left.png"),
    ("AnatomyBoneOlderBoyHumerusRight", "Bone_older_boy_humerus_right.png"),
    ("AnatomyBoneOlderBoyRadiusUlnaRight", "Bone_older_boy_radius_ulna_right.png"),
    ("AnatomyBoneOlderBoyHandsRight", "Bone_older_boy_hands_right.png"),
    ("AnatomyBoneOlderBoyFemurLeft", "Bone_older_boy_femur_left.png"),
    ("AnatomyBoneOlderBoyFibulaTibiaLeft", "Bone_older_boy_fibula_tibia_left.png"),
    ("AnatomyBoneOlderBoyFeetLeft", "Bone_older_boy_feet_left.png"),
    ("AnatomyBoneOlderBoyFemurRight", "Bone_older_boy_femur_right.png"),
    ("AnatomyBoneOlderBoyFibulaTibiaRight", "Bone_older_boy_fibula_tibia_right.png"),
    ("AnatomyBoneOlderBoyFeetRight", "Bone_older_boy_feet_right.png")
]

let xcassetsPath = "iOS/RileyApp/Assets.xcassets"
let fm = FileManager.default

for item in mapping {
    let folder = "\(xcassetsPath)/\(item.assetName).imageset"
    try? fm.createDirectory(atPath: folder, withIntermediateDirectories: true)
    
    let srcPng = "assets/bones/\(item.file)"
    let dstPng = "\(folder)/\(item.assetName).png"
    if fm.fileExists(atPath: dstPng) {
        try? fm.removeItem(atPath: dstPng)
    }
    try! fm.copyItem(atPath: srcPng, toPath: dstPng)
    
    let json = """
    {
      "images": [
        {
          "filename": "\(item.assetName).png",
          "idiom": "universal",
          "scale": "1x"
        }
      ],
      "info": {
        "author": "xcode",
        "version": 1
      }
    }
    """
    try! json.write(toFile: "\(folder)/Contents.json", atomically: true, encoding: .utf8)
}

print("Created all 16 Xcode imagesets for Older Boy successfully!")
