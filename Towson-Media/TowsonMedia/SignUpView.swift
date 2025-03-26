import SwiftUI

struct SignUpView: View {
    let onBackToLogin: () -> Void
    let onSignUp: (String) -> Void // Pass username to parent
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

                // Sign Up Button
                Button(action: {
                    handleSignUp()
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(20)
                
                // Back to Login Button
                Button(action: onBackToLogin) {
                    Text("Back to Login")
                        .font(.headline)
                        .foregroundColor(.blue)
                }

                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func handleSignUp() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter all fields"
            return
        }

        createUser(username: username, password: password, bio: nil) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    fetchUserByUsername(username: response.username) { fetchResult in
                        DispatchQueue.main.async {
                            switch fetchResult {
                            case .success(let user):
                                // Save credentials with user_id
                                UserManager.shared.saveCredentials(username: user.username, password: password, userId: String(user.user_id))
                                onSignUp(user.username)
                            case .failure(let error):
                                errorMessage = "Failed to retrieve user details: \(error.localizedDescription)"
                            }
                        }
                    }
                case .failure(let error):
                    errorMessage = "Sign-up failed: \(error.localizedDescription)"
                }
            }
        }
    }

}
