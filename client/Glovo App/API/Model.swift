import Foundation

public class Country {
   public let code: String
   public let name: String
    
    public init(code: String, name: String) {
        self.name = name
        self.code = code
    }
    
    public convenience init(from json: CountryJSON) {
        self.init(code: json.code, name: json.name)
    }
    
    private static let flagByCountry = ["AR": "🇦🇷", "BR": "🇧🇷", "PA": "🇵🇦", "CL": "🇨🇱", "PE": "🇵🇪",
                                 "PT": "🇵🇹", "FR": "🇫🇷", "IT": "🇮🇹", "CR": "🇨🇷", "EG": "🇪🇬" , "ES": "🇪🇸"]
    
    class func flag(countryCode: String) -> String? {
        return self.flagByCountry[countryCode]
    }
    
}

public class City: Hashable {
    public let code: String
    public let name: String
    public let countryCode: String
    public let workingArea: [String]
    public private(set) var languageCode: String?
    public private(set) var timeZone: String?
    public private(set) var currency: String?
    public private(set) var busy: Bool?
    public private(set) var enabled: Bool?
    
    public var hashValue: Int {
         return self.countryCode.hashValue + self.code.hashValue
    }
    
    public init(code: String, name: String, countryCode: String, workingArea: [String]) {
        self.name = name
        self.code = code
        self.countryCode = countryCode
        self.workingArea = workingArea.filter { !$0.isEmpty }
    }
    
    public convenience init(from json: CityJSON) {
        self.init(code: json.code,
                  name: json.name,
                  countryCode: json.countryCode,
                  workingArea: json.workingArea)
    }
    
    public convenience init(from json: CityDetailJSON) {
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
    
    public static func ==(lhs: City, rhs: City) -> Bool {
        return (lhs.countryCode == rhs.countryCode) && (lhs.code == rhs.code)
    }
}
