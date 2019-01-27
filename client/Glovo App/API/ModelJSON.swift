import Foundation

public struct CountryJSON: Decodable {
    let code: String
    let name: String
    
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

struct CitiesJSON: Decodable {
    let code: String
    let name: String
    let countryCode: String
    let workingArea: [String]
    
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

struct CityJSON: Decodable {
    let code: String
    let name: String
    let currency: String
    let countryCode: String
    let enabled: Bool
    let busy: Bool
    let timeZone: String
    let workingArea: [String]
    let languageCode: String
    
    enum CodingKeys: String, CodingKey {        
        case code
        case name
        case currency
        case countryCode = "country_code"
        case enabled
        case busy
        case timeZone = "time_zone"
        case languageCode = "language_code"
        case workingArea = "working_area"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try values.decode(String.self, forKey: .name)
        self.code = try values.decode(String.self, forKey: .code)
        self.currency = try values.decode(String.self, forKey: .currency)
        self.countryCode = try values.decode(String.self, forKey: .countryCode)
        self.enabled = try values.decode(Bool.self, forKey: .enabled)
        self.busy = try values.decode(Bool.self, forKey: .busy)
        self.timeZone = try values.decode(String.self, forKey: .timeZone)
        self.languageCode = try values.decode(String.self, forKey: .languageCode)
        self.workingArea = try values.decode([String].self, forKey: .workingArea)
    }
}
