import UIKit
import FloatingPanel

public final class PanelCompactLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .hidden
    }
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 216.0 // A bottom inset from the safe area
        default: return 0 // Or `case .hidden: return nil`
        }
    }
}
