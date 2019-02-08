import Foundation

public final class Configurator {
    public struct Key {
        static let onBoarding = "KIM_BackgroundMusic"
    }

    public static let shared = Configurator()
    private init() {}
    
    public var onBoardingIsTerminated: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.onBoarding)
        }
        
        get {
            return UserDefaults.standard.bool(forKey: Key.onBoarding)
        }
    }
}
