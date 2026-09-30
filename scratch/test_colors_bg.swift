import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let imgSkel = NSImage(contentsOf: urlSkel)!
let repSkel = NSBitmapImageRep(data: imgSkel.tiffRepresentation!)!

let bg = repSkel.colorAt(x: 10, y: 10)!
print(String(format: "BG (10, 10): r:%.3f, g:%.3f, b:%.3f, g-r: %.3f", bg.redComponent, bg.greenComponent, bg.blueComponent, bg.greenComponent - bg.redComponent))

// Sample on cranium (around 780, 420)
let cranium = repSkel.colorAt(x: 780, y: 420)!
print(String(format: "Cranium (780, 420): r:%.3f, g:%.3f, b:%.3f", cranium.redComponent, cranium.greenComponent, cranium.blueComponent))

// Sample on temporal shading (around 810, 450)
let shading = repSkel.colorAt(x: 810, y: 450)!
print(String(format: "Shading (810, 450): r:%.3f, g:%.3f, b:%.3f, g-r: %.3f", shading.redComponent, shading.greenComponent, shading.blueComponent, shading.greenComponent - shading.redComponent))

// Sample on eye socket (around 830, 450)
let eye = repSkel.colorAt(x: 835, y: 450)!
print(String(format: "Eye (835, 450): r:%.3f, g:%.3f, b:%.3f", eye.redComponent, eye.greenComponent, eye.blueComponent))

