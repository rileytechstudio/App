ObjC.import("Cocoa");

var files = ["packet.png", "ripped packet.png", "rip effect.png", "packet wipe.png"];
var basePath = "/Users/rileytechstudio/Documents/Gemini/App/IV Game/";

files.forEach(function(f) {
    var full = basePath + f;
    var img = $.NSImage.alloc.initWithContentsOfFile($(full));
    var rep = $.NSBitmapImageRep.imageRepWithData(img.TIFFRepresentation);
    var w = rep.pixelsWide;
    var h = rep.pixelsHigh;
    
    var minX = w, maxX = 0, minY = h, maxY = 0;
    for (var y = 0; y < h; y += 2) {
        for (var x = 0; x < w; x += 2) {
            var color = rep.colorAtXY(x, y);
            if (color.alphaComponent > 0.05) {
                if (x < minX) minX = x;
                if (x > maxX) maxX = x;
                if (y < minY) minY = y;
                if (y > maxY) maxY = y;
            }
        }
    }
    console.log(f + " bbox: minX=" + minX + ", maxX=" + maxX + ", minY=" + minY + ", maxY=" + maxY + " (w=" + (maxX - minX + 1) + ", h=" + (maxY - minY + 1) + ")");
});
