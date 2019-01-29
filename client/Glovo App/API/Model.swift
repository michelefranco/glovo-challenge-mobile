import Foundation

public class Country {
   public let code: String
   public let name: String
    
    public init(code: String, name: String) {
        self.name = name
        self.code = code
    }
    
    convenience init(from json: CountryJSON) {
        self.init(code: json.code, name: json.name)
    }
}

public class City {
    public let code: String
    public let name: String
    public let countryCode: String
    public let workingArea: [String]
    public private(set) var languageCode: String?
    public private(set) var timeZone: String?
    public private(set) var currency: String?
    public private(set) var busy: Bool?
    public private(set) var enabled: Bool?
    
    public init(code: String, name: String, countryCode: String, workingArea: [String]) {
        self.name = name
        self.code = code
        self.countryCode = countryCode
        self.workingArea = workingArea.filter { !$0.isEmpty }
    }
    
    convenience init(from json: CityJSON) {
        self.init(code: json.code,
                  name: json.name,
                  countryCode: json.countryCode,
                  workingArea: json.workingArea)
    }
    
    convenience init(from json: CityDetailJSON) {
        self.init(code: json.code,
                  name: json.name,
                  countryCode: json.countryCode,
                  workingArea: json.workingArea)
        
        self.busy = json.busy
        self.enabled = json.enabled
        self.currency = json.currency
        self.timeZone = json.timeZone
        self.languageCode = json.languageCode
    }
}
