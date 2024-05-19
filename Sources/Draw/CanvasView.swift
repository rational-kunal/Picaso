import UIKit

enum CanvasStateEditing {
    case None, TopLeft, TopRight, BottomLeft, BottomRight
}

enum CanvasState: Equatable {
    case None, InitialDrawing, Editing(CanvasStateEditing)
}

internal class CanvasView: UIView {

    private var borderRectangle: CGRect = .zero
    private var canvasState: CanvasState = .None

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)

        switch canvasState {
        case .None:
            // Start drawing
            canvasState = .InitialDrawing
            borderRectangle.topLeft = touchPoint
        case .InitialDrawing:
            break // No-op: Invalid state
        case .Editing(let canvasStateEditing):
            guard canvasStateEditing == .None else { return }
            var editingState: CanvasStateEditing = .None
            if touchPoint.distance(to: borderRectangle.topLeft) <= Constants.HotRadius {
                editingState = .TopLeft
            } else if touchPoint.distance(to: borderRectangle.topRight) <= Constants.HotRadius {
                editingState = .TopRight
            } else if touchPoint.distance(to: borderRectangle.bottomLeft) <= Constants.HotRadius {
                editingState = .BottomLeft
            } else if touchPoint.distance(to: borderRectangle.bottomRight) <= Constants.HotRadius {
                editingState = .BottomRight
            }

            canvasState = .Editing(editingState)
            updateBorderRadius(forTouchPoint: touchPoint, editingState: editingState)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)

        switch canvasState {
        case .None:
            break // No-op: Invalid
        case .InitialDrawing:
            borderRectangle.bottomRight = touchPoint
        case .Editing(let canvasStateEditing):
            updateBorderRadius(forTouchPoint: touchPoint, editingState: canvasStateEditing)
        }

        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch canvasState {
        case .None:
            break // No-op: Invalid
        case .InitialDrawing:
            canvasState = .Editing(.None)
        case .Editing(let canvasStateEditing):
            canvasState = .Editing(.None)
        }

        borderRectangle = borderRectangle.standardized
        
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !borderRectangle.topLeft.equalTo(.zero), !borderRectangle.bottomRight.equalTo(.zero) else { return }

        let roundedRectangle = UIBezierPath(roundedRect: borderRectangle.standardized, cornerRadius: Constants.DefaultBorderCorderRadius)
        roundedRectangle.lineWidth = Constants.DefaultBorderWidth

        UIColor.clear.setFill()
        UIColor.red.setStroke()
        roundedRectangle.stroke()
    }

    private func updateBorderRadius(forTouchPoint touchPoint: CGPoint, editingState: CanvasStateEditing) {
        guard canvasState == .Editing(editingState) else { return }
        switch editingState {
        case .None:
            break // No-op: Invalid state
        case .TopLeft:
            borderRectangle.top = touchPoint.y
            borderRectangle.left = touchPoint.x
        case .TopRight:
            borderRectangle.top = touchPoint.y
            borderRectangle.right = touchPoint.x
        case .BottomLeft:
            borderRectangle.bottom = touchPoint.y
            borderRectangle.left = touchPoint.x
        case .BottomRight:
            borderRectangle.bottom = touchPoint.y
            borderRectangle.right = touchPoint.x
        }
    }

}
