
import Foundation
import Result


public struct SBXDataUtil {
    
    public enum ApiMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
    }
    
    
    public enum SBXDataError: Error {
        case NoData
        case InvalidJSON
        case ConversionFailed
        case FieldNotPresent
        case ErrorResponse(String)        
        case CustomError(Error)
    }
    
    
    public static func getJSON(method: ApiMethod, host:String, port:Int?, secure:Bool = true ,path: String, body: Data?, params: [String: String]?, headers: [String: String], completionHandler: @escaping (Result<[String:Any], SBXDataError>) -> ()) {
        
        var url = URLComponents()
        url.host = host
        
        if let port = port {
            url.port = port
        }
        
        
        url.path = path
        url.scheme = secure ? "https":"http"
        
        if let params = params {
            url.queryItems = params.map {
                return URLQueryItem(name: $0, value: $1)
            }
        }
        
        guard let endpoint = url.url else {
            completionHandler(.failure(.NoData))
            return
        }
        
        
        var clientReq = URLRequest(url: endpoint)
        
        clientReq.httpBody = body
        
        
        headers.forEach {
            clientReq.addValue($1, forHTTPHeaderField: $0)
        }
        
        clientReq.addValue("application/json", forHTTPHeaderField: "accept")
        clientReq.httpMethod = method.rawValue
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: clientReq){
            (data, res, err) in
            
            
            guard err == nil else{
                completionHandler(.failure(.CustomError(err!)))
                return
            }
            
            do {
                
                guard let data = data else {
                    completionHandler(.failure(.NoData))
                    return
                }
                
                guard let json:[String:Any] =  try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completionHandler(.failure(.ConversionFailed))
                    return
                }
                
                completionHandler(.success(json))
                
            }catch {
                completionHandler(.failure(.CustomError(error)))
            }
        }.resume()
    }


}




