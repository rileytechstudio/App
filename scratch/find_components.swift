import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!
let w = rep.pixelsWide
let h = rep.pixelsHigh

var visited = Array(repeating: Array(repeating: false, count: h), count: w)
var components: [[(x: Int, y: Int)]] = []

for y in 0..<h {
    for x in 0..<w {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 && !visited[x][y] {
            // BFS
            var comp: [(x: Int, y: Int)] = []
            var q: [(x: Int, y: Int)] = [(x, y)]
            visited[x][y] = true
            
            var head = 0
            while head < q.count {
                let curr = q[head]
                head += 1
                comp.append(curr)
                
                for dx in -1...1 {
                    for dy in -1...1 {
                        if dx == 0 && dy == 0 { continue }
                        let nx = curr.x + dx
                        let ny = curr.y + dy
                        if nx >= 0 && nx < w && ny >= 0 && ny < h && !visited[nx][ny] {
                            let nc = rep.colorAt(x: nx, y: ny)!
                            if nc.alphaComponent > 0.05 {
                                visited[nx][ny] = true
                                q.append((nx, ny))
                            }
                        }
                    }
                }
            }
            if comp.count > 20 {
                components.append(comp)
            }
        }
    }
}

print("Found \(components.count) connected components with > 20 pixels:")
for (idx, comp) in components.enumerated() {
    let minX = comp.map { $0.x }.min()!
    let maxX = comp.map { $0.x }.max()!
    let minY = comp.map { $0.y }.min()!
    let maxY = comp.map { $0.y }.max()!
    print("Component \(idx): count=\(comp.count), x: \(minX)..\(maxX), y: \(minY)..\(maxY)")
}
