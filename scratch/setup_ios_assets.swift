import Foundation

let mapping: [(assetName: String, file: String)] = [
    ("AnatomyBoneYoungerBoySkull", "Bone_younger_boy_skull.png"),
    ("AnatomyBoneYoungerBoySpine", "Bone_younger_boy_spine.png"),
    ("AnatomyBoneYoungerBoyRibcage", "Bone_younger_boy_ribcage.png"),
    ("AnatomyBoneYoungerBoyPelvis", "Bone_younger_boy_pelvis.png"),
    ("AnatomyBoneYoungerBoyHumerusLeft", "Bone_younger_boy_humerus_left.png"),
    ("AnatomyBoneYoungerBoyRadiusUlnaLeft", "Bone_younger_boy_radius_ulna_left.png"),
    ("AnatomyBoneYoungerBoyHandsLeft", "Bone_younger_boy_hands_left.png"),
    ("AnatomyBoneYoungerBoyHumerusRight", "Bone_younger_boy_humerus_right.png"),
    ("AnatomyBoneYoungerBoyRadiusUlnaRight", "Bone_younger_boy_radius_ulna_right.png"),
    ("AnatomyBoneYoungerBoyHandsRight", "Bone_younger_boy_hands_right.png"),
    ("AnatomyBoneYoungerBoyFemurLeft", "Bone_younger_boy_femur_left.png"),
    ("AnatomyBoneYoungerBoyFibulaTibiaLeft", "Bone_younger_boy_fibula_tibia_left.png"),
    ("AnatomyBoneYoungerBoyFeetLeft", "Bone_younger_boy_feet_left.png"),
    ("AnatomyBoneYoungerBoyFemurRight", "Bone_younger_boy_femur_right.png"),
    ("AnatomyBoneYoungerBoyFibulaTibiaRight", "Bone_younger_boy_fibula_tibia_right.png"),
    ("AnatomyBoneYoungerBoyFeetRight", "Bone_younger_boy_feet_right.png")
]

let xcassetsPath = "iOS/RileyApp/Assets.xcassets"
let fm = FileManager.default

for item in mapping {
    let folder = "\(xcassetsPath)/\(item.assetName).imageset"
    try? fm.createDirectory(atPath: folder, withIntermediateDirectories: true)
    
    // Copy png
    let srcPng = "assets/bones/\(item.file)"
    let dstPng = "\(folder)/\(item.assetName).png"
    if fm.fileExists(atPath: dstPng) {
        try? fm.removeItem(atPath: dstPng)
    }
    try! fm.copyItem(atPath: srcPng, toPath: dstPng)
    
    // Write Contents.json
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

print("Created all 16 Xcode imagesets successfully!")
