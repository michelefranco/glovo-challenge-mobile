import Foundation

final public class Router {
    private let baseEndpoint: URL? = {
        let url = URL(string: "http://localhost:3000/api/")
        return url
    }()
    
    static let shared = Router()
    
    private init() {}
    
    //MARK: Methods
    public func countries(timeOut: TimeInterval = 10, _ completion: @escaping (APIResponse<[Country]>) -> ()) {
        
        let errorLocation = "Router.countries -"
        
        guard let endpoint = self.baseEndpoint?.appendingPathComponent("countries")
            else {
                let error = APIError.invalidURL(message: "\(errorLocation) invalidURL with baseEndpoint: \(String(describing: self.baseEndpoint?.absoluteString))")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: error))
                }
                return
        }
        
        let configuration = self.configuration(timeout: timeOut)
        URLSession(configuration: configuration).dataTask(with: endpoint) { data, response, error in
            guard error == nil else {
                let error = APIError.failedRequest(message: "\(errorLocation) \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: error))
                }
                return
            }
            
            guard let data = data else {
                let error = APIError.failedRequest(message: "\(errorLocation) no data returned")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: error))
                }
                return
            }
            
            do {
                let countriesJSON = try JSONDecoder().decode([CountryJSON].self, from: data)
                let countries = countriesJSON.map { Country(from: $0) }
                DispatchQueue.main.async {
                    completion(APIResponse.success(result: countries))
                }
            } catch {
                let err = APIError.decodingJSON(message: "\(errorLocation) error during decoding countries : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: err))
                }
                
                return
            }
            
            }.resume()
    }
    
    //MARK: Methods
    public func city(cityCode: String, timeOut: TimeInterval = 10, _ completion: @escaping (APIResponse<City>) -> ()) {
        let errorLocation = "Router.city -"
        
        let url = self.baseEndpoint?.appendingPathComponent("cities").appendingPathComponent("\(cityCode)")
        
        guard let endpoint = url else {
            let error = APIError.invalidURL(message: "\(errorLocation) invalidURL with baseEndpoint: \(String(describing: self.baseEndpoint?.absoluteString))")
            DispatchQueue.main.async {
                completion(APIResponse.failure(error: error))
            }
            return
        }
        
        let configuration = self.configuration(timeout: timeOut)
        URLSession(configuration: configuration).dataTask(with: endpoint) { data, response, error in
            guard error == nil else {
                let error = APIError.failedRequest(message: "\(errorLocation) \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: error))
                }
                return
            }
            
            guard let data = data else {
                let error = APIError.failedRequest(message: "\(errorLocation) no data returned")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: error))
                }
                return
            }
            
            do {
                let cityDetailJSON = try JSONDecoder().decode(CityDetailJSON.self, from: data)
                let cities = City(from: cityDetailJSON)
                DispatchQueue.main.async {
                    completion(APIResponse.success(result: cities))
                }
            } catch {
                let err = APIError.decodingJSON(message: "\(errorLocation) error during decoding countries : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: err))
                }
                
                return
            }
            }.resume()
    }
    
    public func cities(timeOut: TimeInterval = 10, _ completion: @escaping (APIResponse<[City]>) -> ()) {
        
        let errorLocation = "Router.cities -"
        
        guard let endpoint = self.baseEndpoint?.appendingPathComponent("cities")
            else {
                let error = APIError.invalidURL(message: "\(errorLocation) invalidURL with baseEndpoint: \(String(describing: self.baseEndpoint?.absoluteString))")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: error))
                }
                return
        }
        
        let configuration = self.configuration(timeout: timeOut)
        URLSession(configuration: configuration).dataTask(with: endpoint) { data, response, error in
            guard error == nil else {
                let error = APIError.failedRequest(message: "\(errorLocation) \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: error))
                }
                return
            }
            
            guard let data = data else {
                let error = APIError.failedRequest(message: "\(errorLocation) no data returned")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: error))
                }
                return
            }
            
            do {
                let citiesJSON = try JSONDecoder().decode([CityJSON].self, from: data)
                let cities = citiesJSON.map { City(from: $0) }
                DispatchQueue.main.async {
                    completion(APIResponse.success(result: cities))
                }
            } catch {
                let err = APIError.decodingJSON(message: "\(errorLocation) error during decoding countries : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(APIResponse.failure(error: err))
                }
                
                return
            }
            }.resume()
    }
    
    
    //MARK: private methods
    private func configuration(timeout: TimeInterval) -> URLSessionConfiguration {
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForResource = timeout
        return urlconfig
    }
    
}
