import Foundation

struct CreateUserResponse: Decodable {
    let user_id: Int
    let username: String
}

struct User: Decodable {
    let user_id: Int
    let username: String
    let password: String
    let bio: String?
}

// API function for signup
func createUser(username: String, password: String, bio: String?, completion: @escaping (Result<CreateUserResponse, Error>) -> Void) {
    let body: [String: Any] = [
        "username": username,
        "password": password,
        "bio": bio ?? ""
    ]
    makeRequest(endpoint: "/users", method: "POST", body: body, completion: completion)
}

// API function for login
func fetchUserByUsername(username: String, completion: @escaping (Result<User, Error>) -> Void) {
    let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username
    let endpoint = "/users/username/\(encodedUsername)" // Ensure proper encoding
    print("Calling endpoint: \(endpoint)") // Debugging log
    makeRequest(endpoint: endpoint, method: "GET", completion: completion)
}

