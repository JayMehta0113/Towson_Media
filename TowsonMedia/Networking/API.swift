import Foundation

struct API {
    static let baseURL = "https://tumediabackend-660505262696.us-east1.run.app"
}

enum APIError: Error {
    case invalidResponse
    case noData
    case decodingError
    case serverError(String)
}

func makeRequest<T: Decodable>(
    endpoint: String,
    method: String,
    body: [String: Any]? = nil,
    completion: @escaping (Result<T, Error>) -> Void
) {
    guard let url = URL(string: "\(API.baseURL)\(endpoint)") else {
        completion(.failure(APIError.invalidResponse))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = method
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    if let body = body {
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(APIError.noData))
            return
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            completion(.failure(APIError.serverError("Server returned status code \(httpResponse.statusCode)")))
            return
        }

        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedResponse))
        } catch {
            completion(.failure(APIError.decodingError))
        }
    }.resume()
}

