import SwiftUI

struct PostRow: View {
    var post: Post

    var body: some View {
        VStack {
            HStack {
                Image(post.profilePicture)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .clipShape(Circle())
                Text("u/\(post.username)")
                    .foregroundStyle(.black)
                Spacer()
            }

            Text(post.pTitle)
                .bold()
                .foregroundStyle(.black)

            if let pImage = post.pImage, !pImage.isEmpty {
                Image(pImage)
                    .resizable()
                    .frame(width: 320, height: 200)
                    .cornerRadius(8)
            } else {
                Text(post.pDescription)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.black)
            }

            HStack {
                VotingButtons(post: post) // Pass Post directly
                Spacer()
                Text("\(post.commentNum) comments")
                    .foregroundStyle(.black)
            }
        }
    }
}

struct VotingButtons: View {
    var post: Post

    var body: some View {
        HStack {
            Button {
            } label: {
                Image(systemName: "arrow.up.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.green)
            }
            Text("\(post.upVotes)")
                .foregroundStyle(.black)
            Button {
            } label: {
                Image(systemName: "arrow.down.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.red)
            }
        }
    }
}
