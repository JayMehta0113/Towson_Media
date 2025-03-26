//
//  Post.swift
//  TowsonMedia
//
//  Created by Jacob on 11/14/24.
//

import Foundation
import SwiftUI

struct Post: Identifiable {
    let id = UUID()
    let profilePicture: String
    let username: String
    let pTitle: String
    let pDescription: String
    let pImage: String?
    var upVotes: Int
    var commentNum: Int
}

struct PostList {
    static let posts: [Post] = [
        Post(profilePicture: "ProfileOne", username: "Tester1", pTitle: "Help! I dont know how to program", pDescription: "Please help me program this assignment, I am stuck on how to print 'Hello World' and dont know what to do!", pImage: "HelloError", upVotes: 2, commentNum: 9),
        Post(profilePicture: "ProfileTwo", username: "Tester2", pTitle: "Help! I also dont know how to program", pDescription: "Please help me program this assignment, I am stuck on how to print 'Hello World' and I also dont know what to do!", pImage: "", upVotes: 1, commentNum: 9)
    ]
    
}
