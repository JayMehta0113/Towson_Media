import SwiftUI

struct ProfileView: View {
    @State private var username: String = ""
    let onLogout: () -> Void // Callback to handle logout action

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(Color.yellow)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                
                Text("Profile")
                    .padding(.top, 47)
                    .foregroundColor(.black)
                    .font(.system(size: 30))
                    .bold()
            }
            
            Spacer()
            
            HStack {
                Text("Username:")
                    .font(.headline)
                Text(username) // Display the username
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding() // Add some spacing for visual clarity
            
            Spacer()
            
            // Logout Button
            Button(action: {
                UserManager.shared.clearCredentials() // Clear stored credentials
                onLogout() // Trigger the logout action
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20) // Add some spacing below the button
        }
        .onAppear {
            loadUsername() // Load username when the view appears
        }
        .ignoresSafeArea(edges: .top)
    }

    // Function to load the username from persistent storage
    private func loadUsername() {
        if let storedUsername = UserManager.shared.getCredentials().username {
            username = storedUsername
        } else {
            username = "SampleUser" // Default value if no username is found
        }
    }
}

#Preview {
    ProfileView(onLogout: {
        print("Logout triggered in preview")
    }) // Mock logout callback for testing
}
