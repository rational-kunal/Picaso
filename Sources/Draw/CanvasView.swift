import UIKit

internal class CanvasView: UIView {

    private var startPoint: CGPoint = .zero
    private var endPoint: CGPoint = .zero

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        startPoint = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        endPoint = touch.location(in: self)
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !startPoint.equalTo(.zero), !endPoint.equalTo(.zero) else { return }

        let rectangle = CGRect(x: min(startPoint.x, endPoint.x), y: min(startPoint.y, endPoint.y),
                               width: abs(startPoint.x - endPoint.x), height: abs(startPoint.y - endPoint.y))
        let roundedRectangle = UIBezierPath(roundedRect: rectangle, cornerRadius: 3.5)
        roundedRectangle.lineWidth = 2.5

        UIColor.clear.setFill()
        UIColor.red.setStroke()
        roundedRectangle.stroke()
    }

}
