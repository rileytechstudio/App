import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOf: targetUrl)!
let rep = NSBitmapImageRep(data: targetImg.tiffRepresentation!)!

let W = rep.pixelsWide // 161
let H = rep.pixelsHigh // 466

// Binary bone mask in target image
var targetBone = Array(repeating: Array(repeating: false, count: H), count: W)
for y in 0..<H {
    for x in 0..<W {
        if let c = rep.colorAt(x: x, y: y) {
            let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
            if (r > 0.82 && g > 0.82 && b > 0.82) || (b > 0.55 && b > r + 0.15 && g > 0.35) || (r < 0.28 && g < 0.28 && b < 0.42 && (r + g + b) > 0.15) {
                targetBone[x][y] = true
            }
        }
    }
}

struct BoneDef {
    let id: String
    let file: String
    var x: Double
    var y: Double
    var w: Double
    var h: Double
    var rot: Double
    var z: Int
}

// Function to evaluate IoU of a single piece inside its ROI
func evalPiece(file: String, xPct: Double, yPct: Double, wPct: Double, hPct: Double, rotDeg: Double) -> Double {
    guard let img = NSImage(contentsOfFile: "assets/bones/\(file)"),
          let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return 0 }
    
    let bw = Int(wPct / 100.0 * Double(W))
    let bh = Int(hPct / 100.0 * Double(H))
    if bw <= 2 || bh <= 2 { return 0 }
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: bw, height: bh, bitsPerComponent: 8, bytesPerRow: bw * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return 0 }
    
    // Draw rotated in its local box
    ctx.draw(cg, in: CGRect(x: 0, y: 0, width: bw, height: bh))
    
    guard let testCg = ctx.makeImage() else { return 0 }
    let testRep = NSBitmapImageRep(cgImage: testCg)
    
    let cx = xPct / 100.0 * Double(W)
    let cy = yPct / 100.0 * Double(H)
    let minX = Int(cx - Double(bw) / 2.0)
    let minY = Int(cy - Double(bh) / 2.0)
    
    var intersection = 0
    var union = 0
    
    for py in 0..<bh {
        let ty = minY + py
        for px in 0..<bw {
            let tx = minX + px
            let testA = testRep.colorAt(x: px, y: py)?.alphaComponent ?? 0
            let isTest = testA > 0.4
            let isTarget = (tx >= 0 && tx < W && ty >= 0 && ty < H) ? targetBone[tx][ty] : false
            
            if isTest && isTarget { intersection += 1 }
            if isTest || isTarget { union += 1 }
        }
    }
    return union > 0 ? Double(intersection) / Double(union) : 0
}

func optimize(file: String, cxInit: Double, cyInit: Double, wInit: Double, hInit: Double, rotInit: Double) -> (cx: Double, cy: Double, w: Double, h: Double, rot: Double, score: Double) {
    var bestCX = cxInit, bestCY = cyInit, bestW = wInit, bestH = hInit, bestRot = rotInit
    var bestScore = evalPiece(file: file, xPct: bestCX, yPct: bestCY, wPct: bestW, hPct: bestH, rotDeg: bestRot)
    
    // Coordinate descent / hill climbing
    let steps = [
        ("cx", [-1.0, -0.5, 0.5, 1.0]),
        ("cy", [-1.0, -0.5, 0.5, 1.0]),
        ("w",  [-2.0, -1.0, 1.0, 2.0]),
        ("h",  [-2.0, -1.0, 1.0, 2.0]),
        ("rot", [-4.0, -2.0, 2.0, 4.0])
    ]
    
    for _ in 0..<5 {
        var improved = false
        for (param, deltas) in steps {
            for d in deltas {
                var tc = bestCX, ty = bestCY, tw = bestW, th = bestH, tr = bestRot
                if param == "cx" { tc += d }
                else if param == "cy" { ty += d }
                else if param == "w" { tw += d }
                else if param == "h" { th += d }
                else if param == "rot" { tr += d }
                
                let s = evalPiece(file: file, xPct: tc, yPct: ty, wPct: tw, hPct: th, rotDeg: tr)
                if s > bestScore {
                    bestScore = s
                    bestCX = tc; bestCY = ty; bestW = tw; bestH = th; bestRot = tr
                    improved = true
                }
            }
        }
        if !improved { break }
    }
    return (bestCX, bestCY, bestW, bestH, bestRot, bestScore)
}

print("Optimizing Skull...")
let sk = optimize(file: "Bone_skull.png", cxInit: 50.0, cyInit: 14.0, wInit: 55.0, hInit: 20.0, rotInit: 0)
print("Skull: cx: \(sk.cx), cy: \(sk.cy), w: \(sk.w), h: \(sk.h), rot: \(sk.rot), score: \(sk.score)")

print("Optimizing Ribcage...")
let rib = optimize(file: "Bone_ribcage.png", cxInit: 50.0, cyInit: 35.0, wInit: 87.0, hInit: 25.0, rotInit: 0)
print("Ribcage: cx: \(rib.cx), cy: \(rib.cy), w: \(rib.w), h: \(rib.h), rot: \(rib.rot), score: \(rib.score)")

print("Optimizing Pelvis...")
let pel = optimize(file: "Bone_pelvis.png", cxInit: 50.0, cyInit: 58.0, wInit: 68.0, hInit: 19.5, rotInit: 0)
print("Pelvis: cx: \(pel.cx), cy: \(pel.cy), w: \(pel.w), h: \(pel.h), rot: \(pel.rot), score: \(pel.score)")

