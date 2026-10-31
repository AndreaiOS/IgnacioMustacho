import SwiftUI
import UIKit

/// UIKit provides monotonic event timestamps; SwiftUI's release callback does not.
struct TouchSurface: UIViewRepresentable {
    let model: GameModel
    func makeUIView(context: Context) -> CourtTouchView {
        let view = CourtTouchView()
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = false
        view.model = model
        return view
    }
    func updateUIView(_ view: CourtTouchView, context: Context) { view.model = model }
}

final class CourtTouchView: UIView {
    weak var model: GameModel?
    private var start = CGPoint.zero
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        start = touch.location(in: self)
        model?.touchBegan(at: touch.timestamp)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        model?.touchMoved(x: point.x - start.x, y: point.y - start.y, at: touch.timestamp)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        model?.touchEnded(x: point.x - start.x, y: point.y - start.y, at: touch.timestamp)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { model?.cancelTouch() }
}
