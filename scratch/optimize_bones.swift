import AppKit

struct BonePieceDef {
    var id: String
    var file: String
    var x: Double
    var y: Double
    var w: Double
    var h: Double
    var rot: Double
    var z: Int
}

struct FitResult {
    let total: Int
    let outside: Int
    var pct: Double { total > 0 ? (Double(outside) / Double(total) * 100.0) : 0 }
}

class BoneFitter {
    let charName: String
    let W: Int
    let H: Int
    let charCg: CGImage
    let charPtr: UnsafePointer<UInt8>
    let charBpr: Int
    let charBpp: Int
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    var boneCache: [String: CGImage] = [:]

    init?(character: String) {
        self.charName = character
        let charPath = "assets/bones/../../assets/Character_\(character)_Solo.png"
        guard let img = NSImage(contentsOfFile: charPath),
              let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        self.charCg = cg
        self.W = cg.width
        self.H = cg.height
        guard let data = cg.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else { return nil }
        self.charPtr = ptr
        self.charBpr = cg.bytesPerRow
        self.charBpp = cg.bitsPerPixel / 8
    }

    func loadBone(_ file: String) -> CGImage? {
        if let cached = boneCache[file] { return cached }
        guard let img = NSImage(contentsOfFile: "assets/bones/\(file)"),
              let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        boneCache[file] = cg
        return cg
    }

    func testPiece(_ piece: BonePieceDef) -> FitResult {
        guard let boneCg = loadBone(piece.file) else { return FitResult(total: 0, outside: 0) }
        guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return FitResult(total: 0, outside: 0)
        }
        ctx.translateBy(x: 0, y: CGFloat(H))
        ctx.scaleBy(x: 1.0, y: -1.0)

        let cx = CGFloat(piece.x / 100.0 * Double(W))
        let cy = CGFloat(piece.y / 100.0 * Double(H))
        let bw = CGFloat(piece.w / 100.0 * Double(W))
        let bh = CGFloat(piece.h / 100.0 * Double(H))

        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: CGFloat(piece.rot * .pi / 180.0))
        ctx.draw(boneCg, in: CGRect(x: -bw / 2.0, y: -bh / 2.0, width: bw, height: bh))

        guard let pieceCg = ctx.makeImage(),
              let pieceData = pieceCg.dataProvider?.data,
              let piecePtr = CFDataGetBytePtr(pieceData) else {
            return FitResult(total: 0, outside: 0)
        }
        let pBpr = pieceCg.bytesPerRow
        let pBpp = pieceCg.bitsPerPixel / 8

        var total = 0
        var outside = 0
        for y in 0..<H {
            for x in 0..<W {
                let off = y * pBpr + x * pBpp
                if piecePtr[off + 3] > 25 {
                    total += 1
                    let cOff = y * charBpr + x * charBpp
                    if charPtr[cOff + 3] < 20 {
                        outside += 1
                    }
                }
            }
        }
        return FitResult(total: total, outside: outside)
    }

    func optimizePiece(_ initial: BonePieceDef, maxDeltaX: Double = 5.0, maxDeltaY: Double = 5.0, maxDeltaRot: Double = 20.0) -> BonePieceDef {
        var best = initial
        var bestRes = testPiece(best)
        if bestRes.outside == 0 { return best }

        // Grid search on rot, x, y, scale
        for scale in [1.0, 0.95, 0.9, 0.85, 0.8, 0.75] {
            for dRot in stride(from: -maxDeltaRot, through: maxDeltaRot, by: 3.0) {
                for dx in stride(from: -maxDeltaX, through: maxDeltaX, by: 1.0) {
                    for dy in stride(from: -maxDeltaY, through: maxDeltaY, by: 1.0) {
                        var candidate = initial
                        candidate.w = initial.w * scale
                        candidate.h = initial.h * scale
                        candidate.x = initial.x + dx
                        candidate.y = initial.y + dy
                        candidate.rot = initial.rot + dRot

                        let res = testPiece(candidate)
                        if res.outside == 0 {
                            // Perfect!
                            print("  Found 0 outside for \(candidate.file): x=\(candidate.x), y=\(candidate.y), w=\(candidate.w), h=\(candidate.h), rot=\(candidate.rot), scale=\(scale)")
                            return candidate
                        }
                        if res.outside < bestRes.outside {
                            best = candidate
                            bestRes = res
                        }
                    }
                }
            }
        }
        print("  Best for \(best.file): outside=\(bestRes.outside) (\(String(format: "%.1f", bestRes.pct))%)")
        return best
    }
}

guard let fitter = BoneFitter(character: "YoungerBoy") else { exit(1) }

let piecesToTune: [BonePieceDef] = [
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 15.0, y: 44.0, w: 14.0, h: 13.0, rot: 16.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 9.0, y: 56.0, w: 14.0, h: 10.0, rot: 18.0, z: 6),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 85.0, y: 44.0, w: 14.0, h: 13.0, rot: -16.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 91.0, y: 56.0, w: 14.0, h: 10.0, rot: -18.0, z: 6),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 38.0, y: 80.0, w: 13.0, h: 17.0, rot: 2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 34.0, y: 94.0, w: 24.0, h: 7.0, rot: 0.0, z: 8),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 62.0, y: 80.0, w: 13.0, h: 17.0, rot: -2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 66.0, y: 94.0, w: 24.0, h: 7.0, rot: 0.0, z: 8)
]

for p in piecesToTune {
    _ = fitter.optimizePiece(p)
}
