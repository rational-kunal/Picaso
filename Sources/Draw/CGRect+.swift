import Foundation

internal extension CGRect {
    var x: CGFloat {
        get { return origin.x }
        set { origin.x = newValue }
    }
    var y: CGFloat {
        get { return origin.y }
        set { origin.y = newValue }
    }
    var width: CGFloat {
        get { return size.width }
        set { size.width = newValue }
    }
    var height: CGFloat {
        get { return size.height }
        set { size.height = newValue }
    }
    
    var left: CGFloat {
        get { return x }
        set {
            let oldRight = right
            x = newValue
            width += oldRight - right
        }
    }
    var top: CGFloat {
        get { return y }
        set {
            let oldBottom = bottom
            y = newValue
            height += oldBottom - bottom
        }
    }
    var right: CGFloat {
        get { return x + width }
        set { width = newValue - x }
    }
    var bottom: CGFloat {
        get { return y + height }
        set { height = newValue - y }
    }
    
    // Standardizes the origin as well
    var standardized: CGRect {
        var standardizedRect = self

        if width < 0 {
            standardizedRect.x += width
            standardizedRect.width = -width
        }

        if height < 0 {
            standardizedRect.y += height
            standardizedRect.height = -height
        }

        return standardizedRect
    }

    var topLeft: CGPoint {
        get { return CGPoint(x: minX, y: minY) }
        set {
            origin.x = newValue.x
            origin.y = newValue.y
        }
    }
    var topRight: CGPoint {
        get { return CGPoint(x: maxX, y: minY) }
        set {
            let width = newValue.x - origin.x
            origin.y = newValue.y
            size.width = width
        }
    }
    var bottomLeft: CGPoint {
        get { return CGPoint(x: minX, y: maxY) }
        set {
            let height = newValue.y - origin.y
            origin.x = newValue.x
            size.height = height
        }
    }
    var bottomRight: CGPoint { 
        get { return CGPoint(x: maxX, y: maxY) }
        set {
            let width = newValue.x - origin.x
            let height = newValue.y - origin.y
            size = CGSize(width: width, height: height)
        }
    }
}
