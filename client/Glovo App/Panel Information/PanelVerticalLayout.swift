import UIKit
import FloatingPanel

final class PanelCompactLayout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .hidden
    }
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 216.0 // A bottom inset from the safe area
        default: return 0 // Or `case .hidden: return nil`
        }
    }
}
