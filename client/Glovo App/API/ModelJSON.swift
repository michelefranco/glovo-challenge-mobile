import Foundation

public struct CountryJSON: Decodable {
    public let code: String
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
       
        self.code = try values.decode(String.self, forKey: .code)
        self.name = try values.decode(String.self, forKey: .name)
    }
}

public struct CityJSON: Decodable {
    public let code: String
    public let name: String
    public let countryCode: String
    public let workingArea: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case code
        case countryCode = "country_code"
        case workingArea = "working_area"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decode(String.self, forKey: .code)
        self.name = try values.decode(String.self, forKey: .name)
        self.countryCode = try values.decode(String.self, forKey: .countryCode)
        self.workingArea = try values.decode([String].self, forKey: .workingArea)
        
    }
}

public struct CityDetailJSON: Decodable {
    public let code: String
    public let name: String
    public let countryCode: String
    public let workingArea: [String]
    public let currency: String
    public let enabled: Bool
    public let busy: Bool
    public let timeZone: String
    public let languageCode: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case code
        case countryCode = "country_code"
        case workingArea = "working_area"
        case currency
        case enabled
        case busy
        case timeZone = "time_zone"
        case languageCode = "language_code"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try values.decode(String.self, forKey: .code)
        self.name = try values.decode(String.self, forKey: .name)
        self.countryCode = try values.decode(String.self, forKey: .countryCode)
        self.currency = try values.decode(String.self, forKey: .currency)
        self.enabled = try values.decode(Bool.self, forKey: .enabled)
        self.busy = try values.decode(Bool.self, forKey: .busy)
        self.timeZone = try values.decode(String.self, forKey: .timeZone)
        self.languageCode = try values.decode(String.self, forKey: .languageCode)
        self.workingArea = try values.decode([String].self, forKey: .workingArea)
    }
}
