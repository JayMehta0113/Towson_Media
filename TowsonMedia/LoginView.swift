import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var isShowingSignUp = false
    @State private var username: String = ""

    var body: some View {
        Group {
            if isLoggedIn {
                // No need for user_id in HomePage
                HomePage(onLogout: handleLogout)
            } else if isShowingSignUp {
                SignUpView(
                    onBackToLogin: { isShowingSignUp = false },
                    onSignUp: { enteredUsername in
                        username = enteredUsername
                        isLoggedIn = true
                        UserManager.shared.saveCredentials(username: enteredUsername, password: "UserPassword")
                    }
                )
            } else {
                LoginView(
                    onLogin: { enteredUsername in
                        username = enteredUsername
                        isLoggedIn = true
                        UserManager.shared.saveCredentials(username: enteredUsername, password: "UserPassword")
                    },
                    onSignUp: { isShowingSignUp = true }
                )
            }
        }
        .onAppear {
            initializeLoginState()
        }
    }

    private func handleLogout() {
        UserManager.shared.clearCredentials()
        isLoggedIn = false
        username = ""
    }

    private func initializeLoginState() {
        let credentials = UserManager.shared.getCredentials()
        if let savedUsername = credentials.username, let _ = credentials.password {
            username = savedUsername
            isLoggedIn = true
        }
    }
}

struct LoginView: View {
    let onLogin: (String) -> Void // Pass username to parent
    let onSignUp: () -> Void
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)

                    Text("TOWSON MEDIA")
                        .padding(.top, 47)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                        .bold()
                }
                
                Image("TM_Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(50)

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Username Input
                TextField("Username", text: $username)
                    .frame(width: 200)
                    .padding()
                    .border(Color.secondary)
                    .foregroundColor(.black)

                // Password Input
                SecureField("Password", text: $password)
                    .frame(width: 200)
                    .padding()
                    .border(Color.secondary)
                    .foregroundColor(.black)
                
                // Login Button
                Button(action: {
                    handleLogin()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(20)

                // Sign Up Button
                Button(action: onSignUp) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.blue)
                }

                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func handleLogin() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter all fields"
            return
        }

        fetchUserByUsername(username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    if user.password == password {
                        // Save credentials with user_id
                        UserManager.shared.saveCredentials(username: user.username, password: password, userId: String(user.user_id))
                        onLogin(user.username)
                    } else {
                        errorMessage = "Invalid username or password."
                    }
                case .failure(let error):
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
