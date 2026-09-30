import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!
let w = rep.pixelsWide
let h = rep.pixelsHigh

var visited = Array(repeating: Array(repeating: false, count: h), count: w)
var comp0: Set<Int> = [] // encoded x*1000 + y

// Find component 0 starting from x=100, y=50 (skull)
var q: [(x: Int, y: Int)] = [(100, 50)]
visited[100][50] = true
comp0.insert(100 * 1000 + 50)
var head = 0
while head < q.count {
    let curr = q[head]
    head += 1
    for dx in -1...1 {
        for dy in -1...1 {
            if dx == 0 && dy == 0 { continue }
            let nx = curr.x + dx
            let ny = curr.y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h && !visited[nx][ny] {
                let nc = rep.colorAt(x: nx, y: ny)!
                if nc.alphaComponent > 0.05 {
                    visited[nx][ny] = true
                    comp0.insert(nx * 1000 + ny)
                    q.append((nx, ny))
                }
            }
        }
    }
}

print("Skull component pixels count: \(comp0.count)")
let minX = comp0.map { $0 / 1000 }.min()!
let maxX = comp0.map { $0 / 1000 }.max()!
let minY = comp0.map { $0 % 1000 }.min()!
let maxY = comp0.map { $0 % 1000 }.max()!
print("Skull bounds: x: \(minX)..\(maxX), y: \(minY)..\(maxY)")

// Check if spine connects to skull
var spineNearSkull: [(Int, Int)] = []
for y in 80...115 {
    for x in 60...120 {
        if !comp0.contains(x * 1000 + y) {
            let c = rep.colorAt(x: x, y: y)!
            if c.alphaComponent > 0.05 {
                spineNearSkull.append((x, y))
            }
        }
    }
}
print("Spine pixels near skull count: \(spineNearSkull.count)")
let spMinY = spineNearSkull.map { $0.1 }.min()
let spMaxY = spineNearSkull.map { $0.1 }.max()
print("Spine near skull y range: \(spMinY ?? -1)..\(spMaxY ?? -1)")
