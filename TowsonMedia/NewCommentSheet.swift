import SwiftUI

struct NewCommentSheet: View {
    @Binding var isPresented: Bool
    @State private var comment: String = ""  // The comment text
    @State private var isPosting = false
    @State private var errorMessage: String? = nil
    
    var postId: String  // The post ID that the comment belongs to

    var body: some View {
        NavigationView {
            VStack {
                // Comment TextBox Section
                TextEditor(text: $comment)
                    .frame(minHeight: 100)  // Set minimum height for the text editor
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.yellow, lineWidth: 2)  // Yellow border around text box
                    )
                    .foregroundColor(.yellow)  // Yellow text
                    .font(.body)
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)  // Remove the "New Post" title
            .toolbar {
                // Cancel Button in top left corner
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.yellow)
                }
                
                // Comment Button in top right corner
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Comment") {
                        postComment()
                    }
                    .foregroundColor(.yellow)
                    .disabled(comment.trimmingCharacters(in: .whitespaces).isEmpty || isPosting)  // Disable button if comment is empty
                }
            }
        }
        .preferredColorScheme(.dark)  // Enforce dark mode for the sheet
        .accentColor(.yellow)  // Yellow accent color for navigation bar buttons
        .background(Color.black.opacity(0.9))  // Remove default gray background and set black color
    }

    func postComment() {
        guard let url = URL(string: "https://tumediabackend-660505262696.us-east1.run.app/comments") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the data to be sent
        let parameters: [String: Any] = [
            "user_id": 2,  // Hardcoded user ID for testing
            "post_id": postId,  // Dynamic post ID
            "body": comment  // User-inputted comment
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            errorMessage = "Failed to serialize JSON"
            return
        }
        
        isPosting = true
        errorMessage = nil
        
        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isPosting = false
                
                if let error = error {
                    errorMessage = "Failed to post comment: \(error.localizedDescription)"
                    return
                }
                
                if let data = data {
                    // Check response status code
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                        print("Comment posted: \(String(data: data, encoding: .utf8) ?? "No data")")
                        isPresented = false
                    } else {
                        errorMessage = "Failed to create comment. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    }
                } else {
                    errorMessage = "No data received."
                }
            }
        }.resume()
    }
}
