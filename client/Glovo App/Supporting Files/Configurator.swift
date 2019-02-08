import Foundation


final class Configurator {
    struct Key {
        static let onBoarding = "KIM_BackgroundMusic"
    }

    static let shared = Configurator()
    private init() {}
    
    var onBoardingIsTerminated: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.onBoarding)
        }
        
        get {
            return UserDefaults.standard.bool(forKey: Key.onBoarding)
        }
    }
}
