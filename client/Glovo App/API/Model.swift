import Foundation

public class Country {
   public let code: String
   public let name: String
    
    public init(code: String, name: String) {
        self.name = name
        self.code = code
    }
}

public class City {
    public let code: String
    public let name: String
    public let currency: String
    public let countryCode: String
    public let enabled: Bool
    public let busy: Bool
    public let timeZone: String
    public let workingArea: [String]
    public let languageCode: String
    
    public init(code: String, name: String, currency: String, countryCode: String,
                enabled: Bool, busy: Bool, timeZone: String, languageCode: String,
                workingArea: [String]) {
        self.name = name
        self.code = code
        self.currency = currency
        self.countryCode = countryCode
        self.enabled = enabled
        self.busy = busy
        self.timeZone = timeZone
        self.workingArea = workingArea
        self.languageCode = languageCode
    }
}
