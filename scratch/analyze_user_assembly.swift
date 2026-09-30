import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOfFile: targetUrl.path)!
let targetRep = NSBitmapImageRep(data: targetImg.tiffRepresentation!)!

// Let's check the distances between joints in user target:
// Skull chin to Clavicle
// Clavicle to Shoulder
// Shoulder to Elbow
// Elbow to Wrist
// Wrist to Fingertips
// Clavicle to Pelvis
// Pelvis to Knee
// Knee to Ankle
// Ankle to Foot sole

print("Target dimensions: \(targetRep.pixelsWide) x \(targetRep.pixelsHigh)")

// Compare ratio of Arm length to Torso height in target vs original Skeleton_Assembled
let skelUrl = URL(fileURLWithPath: "assets/Skeleton_Assembled.png")
let skelImg = NSImage(contentsOfFile: skelUrl.path)!
let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!)!
print("Original Skeleton_Assembled: \(skelRep.pixelsWide) x \(skelRep.pixelsHigh)")

// In original Skeleton:
// Skull: y: 25..298 (h = 273)
// Ribcage: y: 279..603 (h = 324)
// Pelvis: y: 718..937 (h = 219)
// Humerus: y: 349..652 (h = 303)
// Radius: y: 656..937 (h = 281)
// Femur: y: 870..1254 (h = 384)
// Tibia: y: 1245..1582 (h = 337)
// Feet: y: 1558..1690 (h = 132)

// In target:
// Skull: y: 18..110 (h = 92)
// Ribcage: y: 105..220 (h = 115)
// Pelvis: y: 225..315 (h = 90)
// Left Humerus: y: 123..215 (h = 92)
// Left Radius: y: 200..260 (h = 60)
// Left Femur: y: 275..375 (h = 100)
// Left Tibia: y: 360..435 (h = 75)
// Left Foot: y: 420..465 (h = 45)

// Notice the ratios!
// In Original Skeleton:
// Ribcage height / Skull height = 324 / 273 = 1.186
// In Target:
// Ribcage height / Skull height = 115 / 92 = 1.250! (Almost identical!)

// In Original:
// Pelvis height / Skull height = 219 / 273 = 0.802
// In Target:
// Pelvis height / Skull height = 90 / 92 = 0.978!

// In Original:
// Femur height / Skull height = 384 / 273 = 1.406
// In Target:
// Femur height / Skull height = 100 / 92 = 1.087! (Femur is SHORTER in target!)

// In Original:
// Radius height / Skull height = 281 / 273 = 1.029
// In Target:
// Radius height / Skull height = 60 / 92 = 0.652! (Radius is MUCH SHORTER in target!)

