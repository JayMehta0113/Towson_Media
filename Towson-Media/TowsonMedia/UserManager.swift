import Foundation

class UserManager {
    static let shared = UserManager() 

    private let usernameKey = "username"
    private let passwordKey = "password"
    private let userIdKey = "user_id"

    func saveCredentials(username: String, password: String, userId: String? = nil) {
        UserDefaults.standard.set(username, forKey: usernameKey)
        UserDefaults.standard.set(password, forKey: passwordKey)
        if let userId = userId {
                    UserDefaults.standard.set(userId, forKey: userIdKey)
                }
    }

    func getCredentials() -> (username: String?, password: String?, userId: String?) {
        let username = UserDefaults.standard.string(forKey: usernameKey)
        let password = UserDefaults.standard.string(forKey: passwordKey)
        let userId = UserDefaults.standard.string(forKey: userIdKey)
        return (username, password, userId)
    }

    func clearCredentials() {
        UserDefaults.standard.removeObject(forKey: usernameKey)
        UserDefaults.standard.removeObject(forKey: passwordKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}
