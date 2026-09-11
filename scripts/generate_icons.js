ObjC.import("Cocoa");

function resizeAndSave(size, outPath) {
    var newImg = $.NSImage.alloc.initWithSize($.NSMakeSize(size, size));
    newImg.lockFocus;
    
    // Background squircle / rounded rect
    var rect = $.NSMakeRect(0, 0, size, size);
    var cornerRadius = size * 0.22;
    var path = $.NSBezierPath.bezierPathWithRoundedRectXRadiusYRadius(rect, cornerRadius, cornerRadius);
    
    // Vibrant Riley Gradient (#6d3de8 -> #3d1b82)
    var startColor = $.NSColor.colorWithCalibratedRedGreenBlueAlpha(109/255, 61/255, 232/255, 1.0);
    var endColor = $.NSColor.colorWithCalibratedRedGreenBlueAlpha(61/255, 27/255, 130/255, 1.0);
    var gradient = $.NSGradient.alloc.initWithStartingColorEndingColor(startColor, endColor);
    gradient.drawInBezierPathAngle(path, -45);
    
    // Draw medical cross in center
    var crossColor = $.NSColor.whiteColor;
    crossColor.setFill;
    
    var center = size / 2;
    var crossLength = size * 0.46;
    var crossWidth = size * 0.16;
    var crossRadius = size * 0.04;
    
    // Horizontal bar
    var hRect = $.NSMakeRect(center - crossLength/2, center - crossWidth/2, crossLength, crossWidth);
    var hPath = $.NSBezierPath.bezierPathWithRoundedRectXRadiusYRadius(hRect, crossRadius, crossRadius);
    hPath.fill;
    
    // Vertical bar
    var vRect = $.NSMakeRect(center - crossWidth/2, center - crossLength/2, crossWidth, crossLength);
    var vPath = $.NSBezierPath.bezierPathWithRoundedRectXRadiusYRadius(vRect, crossRadius, crossRadius);
    vPath.fill;
    
    // Subtle inner heart or dot
    var dotColor = $.NSColor.colorWithCalibratedRedGreenBlueAlpha(0/255, 229/255, 255/255, 0.95);
    dotColor.setFill;
    var dotSize = size * 0.08;
    var dotRect = $.NSMakeRect(center - dotSize/2, center - dotSize/2, dotSize, dotSize);
    var dotPath = $.NSBezierPath.bezierPathWithOvalInRect(dotRect);
    dotPath.fill;

    // "RILEY" text at bottom
    var str = $("RILEY");
    var fontSize = size * 0.11;
    var font = $.NSFont.boldSystemFontOfSize(fontSize);
    var attrs = $({
        "NSFont": font,
        "NSColor": $.NSColor.whiteColor
    });
    var textSize = str.sizeWithAttributes(attrs);
    str.drawAtPointWithAttributes($.NSMakePoint(center - textSize.width/2, size * 0.09), attrs);

    newImg.unlockFocus;
    
    var tiff = newImg.TIFFRepresentation;
    var bitmap = $.NSBitmapImageRep.imageRepWithData(tiff);
    var pngData = bitmap.representationUsingTypeProperties($.NSBitmapImageFileTypePNG, $({}));
    pngData.writeToFileAtomically($(outPath), true);
    console.log("Saved: " + outPath + " (" + size + "x" + size + ")");
}

var basePath = "/Users/rileytechstudio/Documents/Gemini/App";
resizeAndSave(512, basePath + "/assets/icons/icon-512.png");
resizeAndSave(192, basePath + "/assets/icons/icon-192.png");
resizeAndSave(180, basePath + "/assets/icons/apple-touch-icon.png");
