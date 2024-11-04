//
//  FRNetworkingService.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 11/3/24.
//

import Foundation

enum FRNetworkError : Error, LocalizedError {
    case badURL
    case cannotDecodeData
    case failedResponse
    case noServerConnection
    case updateQuestionError
    
    var errorDescription: String? {
        switch self {
            
        case .badURL:
            return NSLocalizedString("Could not create proper URL", comment: "Bad URL")
        case .cannotDecodeData:
            return NSLocalizedString("Could not decode data", comment: "Data Not Decoded")
        case .failedResponse:
            return NSLocalizedString("The server responds with an unexpected format or status code", comment: "No Server Connection")
        case .noServerConnection:
            return NSLocalizedString("Unable to connect. Please ensure your VPN is turned on, or you are connected to Penn's network.", comment: "No Server Connection")
        case .updateQuestionError:
            return NSLocalizedString("Could not parse Question/Answer.", comment: "Bad Q/A Parsing")
        }
    }
}

protocol FRNetworkRequestable {
    var baseURL: String { get set }
}

extension FRNetworkRequestable {
    
    func fetchData<T: Codable>(of type: T.Type, with endpoint: String) async throws -> Result<T,Error> {
        
        guard let url = URL(string: endpoint) else {
            throw FRNetworkError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print(request)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try self.handleRequestResponse(data, response, for: T.self)
        } catch {
            throw error
        }
    }
    
    func postUserRating<T: Codable>(_ ratingData: T, to endpoint: String) async throws -> Result<String, Error> {
        guard let url = URL(string: endpoint) else {
            throw FRNetworkError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(ratingData)
            request.httpBody = jsonData

            let (data, _) = try await URLSession.shared.data(for: request)
            let responseString = String(data: data, encoding: .utf8) ?? "Success"
            
            return .success(responseString)
        } catch {
            return .failure(error)
        }
    }
    
    /// Constructs the file URL for the Attractiveness.mlpackage model located in the AI_Models folder via Bundle/
    func createAttractivenessModel(with data: Data) throws -> Result<URL, Error> {
        // 1. Get the app's document directory to store the downloaded model if it doesn't exist in the bundle
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let modelURL = documentDirectory.appendingPathComponent("AI_Models/Attractiveness.mlpackage")
        
        // 2. Make sure the directory exists by creating the "AI_Models" directory if necessary
        let aiModelsDirectory = documentDirectory.appendingPathComponent("AI_Models")
        do {
            try FileManager.default.createDirectory(at: aiModelsDirectory, withIntermediateDirectories: true, attributes: nil)
            try data.write(to: modelURL)
            print("Model saved to \(modelURL.path)")
            return .success(modelURL)
        } catch {
            print("Error saving model data: \(error)")
            throw error
            
        }
    }
    
    func downloadModel(from url: String) async throws -> Result<URL,Error> {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let fileURL = Bundle.main.url(forResource: "AI_Models/Attractiveness", withExtension: "mlpackage") else {
                return try createAttractivenessModel(with: data)
            }
            // Over-write the current model with the returned data
            
            try data.write(to: fileURL)
            
            return .success(fileURL)
        } catch {
            throw error
        }
    }
    
    func handleRequestResponse<T:Codable>(_ data: Data, _ response: URLResponse, for type: T.Type) throws -> Result<T,Error> {
        
        guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
            throw FRNetworkError.failedResponse
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            
            return .success(decodedData)
        } catch {
            
            throw error
        }
    }
    
}
