import PhotosUI
import SwiftUI

struct NewPostSheet: View {
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false

    // Network request result state
    @State private var isPosting = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Post Title Section
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .padding(.horizontal)

                        TextField("Enter post title", text: $title)
                            .padding()
                            .cornerRadius(8)
                            .foregroundColor(.yellow)  // Yellow text
                            .font(.title3)
                            .padding(.horizontal)

                        // Post Content (Body Text) Section
                        Text("Body")  // Added description label
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .padding(.horizontal)

                        TextField("Enter post description", text: $content)
                            .padding()
                            .cornerRadius(8)
                            .foregroundColor(.yellow)  // Yellow text
                            .font(.title3)
                            .padding(.horizontal)

                        // Image Display and Removal Section
                        if let selectedImage = selectedImage {
                            VStack {
                                HStack {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .cornerRadius(8)

                                    Button(action: {
                                        self.selectedImage = nil
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.yellow)
                                            .padding()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Spacer()  // Push content up so image picker can be at the bottom
                    }
                    .padding(.top)
                }

                // Image Picker Section (Bottom Left)
                VStack {
                    Spacer()  // Push it down to the bottom
                    HStack {
                        // Show the image picker button only if no image is selected
                        if selectedImage == nil {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)  // Half the size of the previous icon
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    isImagePickerPresented = true
                                }
                                .padding(.leading)  // Add padding to the left edge
                        }

                        Spacer()  // To keep it aligned to the left
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Post Button in top right corner
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        postToBackend()
                    }
                    .foregroundColor(.yellow)
                    .disabled(
                        title.trimmingCharacters(in: .whitespaces).isEmpty
                            || content.trimmingCharacters(in: .whitespaces)
                                .isEmpty
                            || isPosting)
                }

                // Cancel Button in top left corner
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.yellow)
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
        .preferredColorScheme(.dark)  // Enforce dark mode for the sheet
        .accentColor(.yellow)  // Yellow accent color for navigation bar buttons
    }

    func postToBackend() {
        
        guard let userId = UserManager.shared.getCredentials().userId else {
                errorMessage = "User ID not found. Please log in again."
                return
            }
        
        guard
            let url = URL(
                string:
                    "https://tumediabackend-660505262696.us-east1.run.app/posts"
            )
        else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Prepare the data to be sent
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add text fields (title and content)
        appendFormData(
            fieldName: "title", value: title, to: &body, boundary: boundary)
        appendFormData(
            fieldName: "postbody", value: content, to: &body, boundary: boundary
        )
        appendFormData(
            fieldName: "user_id", value: userId, to: &body, boundary: boundary)

        // Add image data if selected
        if let selectedImage = selectedImage,
            let imageData = selectedImage.jpegData(compressionQuality: 0.8)
        {
            let filename = "image.jpg"
            appendImageData(
                fieldName: "media", imageData: imageData, filename: filename,
                boundary: boundary, to: &body)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        isPosting = true
        errorMessage = nil

        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isPosting = false

                if let error = error {
                    errorMessage =
                        "Failed to post: \(error.localizedDescription)"
                    return
                }

                if let data = data {
                    // Check response status code
                    if let httpResponse = response as? HTTPURLResponse,
                        httpResponse.statusCode == 201
                    {
                        print(
                            "Post created: \(String(data: data, encoding: .utf8) ?? "No data")"
                        )
                        isPresented = false
                    } else {
                        errorMessage =
                            "Failed to create post. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    }
                } else {
                    errorMessage = "No data received."
                }
            }
        }.resume()
    }
    // Helper function to append form data
    func appendFormData(
        fieldName: String, value: String, to body: inout Data, boundary: String
    ) {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n"
                .data(using: .utf8)!)
        body.append(value.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
    }

    // Helper function to append image data
    func appendImageData(
        fieldName: String, imageData: Data, filename: String, boundary: String,
        to body: inout Data
    ) {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n"
                .data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate,
        UIImagePickerControllerDelegate
    {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController
                .InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController, context: Context
    ) {}
}
