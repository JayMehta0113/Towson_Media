import SwiftUI

struct HomePage: View {
    @State private var threadView = false
    @State private var newPostView = false
    @State private var selection: Post? = nil
    @State private var posts: [Post] = PostList.posts

    let onLogout: () -> Void // Logout callback

    var body: some View {
        NavigationStack {
            VStack {
                // Header Section
                HStack {
                    Spacer()
                    Text("Towson Media")
                        .font(.title)
                        .bold()
                        .padding()
                    Spacer()
                    NavigationLink(destination: ProfileView( onLogout: onLogout)) { // Pass onLogout
                        Text("*Profile Picture*")
                            .frame(width: 50, height: 50)
                            .padding()
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.gray))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 5.0)
                        .fill(.yellow)
                )

                // Post List Section
                List(posts, id: \.id) { post in
                    Button {
                        selection = post
                        threadView = true
                    } label: {
                        PostRow(post: post)
                    }
                }
                .navigationTitle("Home")
                .sheet(isPresented: $threadView) {
                    if let selectedPost = selection {
                        ThreadView(post: selectedPost)
                    } else {
                        EmptyView()
                    }
                }

                // New Post Button Section
                HStack {
                    Spacer()
                    Button {
                        newPostView.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("New Post")
                        }
                        .frame(width: 150, height: 50)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 5.0)
                                .fill(.gray)
                        )
                    }
                    Spacer()
                }
                .sheet(isPresented: $newPostView) {
                    NewPostSheet(isPresented: $newPostView)
                }
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    HomePage(onLogout: {
        print("Logout triggered in HomePage preview")
    })
}
