import XCTest
@testable import Glovo_App

private let countryTest = Country(code: "ES", name: "Spain")



class GlovoAPITest: XCTestCase {
    func testCountries() {
        let expectation = self.expectation(description: "api_call_countries")
        
        let url = Bundle(for: type(of: self)).url(forResource: "countriesTest", withExtension: "json")!
        
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
        let jsonCode = json["code"] as! String
        let jsoonName = json["name"] as! String
        
        Router.shared.countries { response in
            switch response {
            case .success(let countries):
                let country = countries.filter { $0.code == "ES" }.first!
                XCTAssertEqual(country.code, jsonCode, "Code incorrect")
                XCTAssertEqual(country.name, jsoonName, "Name incorrect")
            case .failure(let message):
                XCTFail(message.description)
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 1)
    }
    
    func testCities() {
        let expectation = self.expectation(description: "api_call_cities")

        let url = Bundle(for: type(of: self)).url(forResource: "citiesTest", withExtension: "json")!

        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]

        Router.shared.cities { response in
            switch response {
            case .success(let cities):
                let city = cities.filter { $0.code == "FIR" }.first!

                XCTAssertEqual(city.code, json["code"] as! String, "Code incorrect")
                XCTAssertEqual(city.name, json["name"] as! String, "Name incorrect")
                XCTAssertEqual(city.countryCode, json["country_code"] as! String, "Country Code incorrect")

                let workingAreaJSON = json["working_area"] as! [String]
                XCTAssertEqual(city.workingArea, workingAreaJSON, "Working area incorrect")
            case .failure(let message):
                XCTFail(message.description)
            }

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

func testFIR() {
    let expectation = self.expectation(description: "api_call_city_FIR")
    
    let url = Bundle(for: type(of: self)).url(forResource: "firTest", withExtension: "json")!
    
    let data = try! Data(contentsOf: url)
    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
    
    Router.shared.city(cityCode: "FIR") { response in
        switch response {
        case .success(let city):
            XCTAssertEqual(city.code, json["code"] as! String, "Code incorrect")
            XCTAssertEqual(city.name, json["name"] as! String, "Name incorrect")
            XCTAssertEqual(city.countryCode, json["country_code"] as! String, "Country Code incorrect")
            
            let workingAreaJSON = json["working_area"] as! [String]
            XCTAssertEqual(city.workingArea, workingAreaJSON, "Working area incorrect")
        case .failure(let message):
            XCTFail(message.description)
        }
        
        expectation.fulfill()
    }
    
    self.waitForExpectations(timeout: 1)
    }
}
