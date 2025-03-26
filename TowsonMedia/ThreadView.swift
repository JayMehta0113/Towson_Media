import SwiftUI

struct ThreadView: View {
    var post: Post // The selected post passed from HomePage
    @State private var isNewCommentViewPresented = false // Track if NewCommentSheet is presented

    var body: some View {
        VStack {
            // Header Section
            HStack {
                Spacer()
                Text(post.pTitle) // Dynamic post title
                    .font(.title)
                    .bold()
                    .padding()
                Spacer()
                Text("*Profile Picture*")
                    .frame(width: 50, height: 50)
                    .padding()
                    .foregroundColor(.white)
            }
            .background(
                RoundedRectangle(cornerRadius: 5.0)
                    .fill(.yellow)
            )

            ScrollView {
                // Post Content Section
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.pTitle) // Dynamic post title
                            .font(.title2)
                            .bold()
                            .foregroundColor(.yellow)

                        Text("Posted by u/\(post.username) • 2 hours ago") // Dynamic username
                            .font(.caption)
                            .foregroundColor(.yellow.opacity(0.7))

                        if let pImage = post.pImage, !pImage.isEmpty, UIImage(named: pImage) != nil {
                            Image(pImage)
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(10)
                                .padding(.vertical, 8)
                        }

                        Text(post.pDescription) // Dynamic post body
                            .font(.body)
                            .foregroundColor(.yellow)
                            .padding(.top, 4)

                        HStack {
                            Image(systemName: "arrow.up.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.yellow)
                            
                            Text("\(post.upVotes)") // Dynamic upvote count
                                .font(.body)
                                .foregroundColor(.yellow)

                            Image(systemName: "arrow.down.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                // Comments Section
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(0..<10, id: \.self) { index in // Replace with dynamic comments
                        VStack(alignment: .leading, spacing: 4) {
                            Text("u/commenter\(index)")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.yellow)
                            
                            Text("This is a comment. It’s just some placeholder text to represent user comments.")
                                .font(.body)
                                .foregroundColor(.yellow)
                                .padding(.leading, 16)
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }

            // New Comment Button Section
            HStack {
                Spacer()
                Button(action: {
                    isNewCommentViewPresented.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus.bubble")
                        Text("Add Comment")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.yellow)
                    )
                }
                Spacer()
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $isNewCommentViewPresented) {
            NewCommentSheet(isPresented: $isNewCommentViewPresented, postId: post.id.uuidString)
        }
    }
}
