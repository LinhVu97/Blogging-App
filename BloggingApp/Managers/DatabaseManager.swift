//
//  DatabaseManager.swift
//  BloggingApp
//
//  Created by Linh Vu on 15/10/24.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    func insertBlogPost(blogPost: BlogPost, email: String, completion: @escaping (Bool) -> Void) {
        let userEmail = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        
        let data: [String: Any] = [
            "id": blogPost.identifier,
            "title": blogPost.title,
            "body": blogPost.text,
            "created": blogPost.timestamp,
            "headerImageUrl": blogPost.headerImageUrl?.absoluteString ?? ""
        ]
        
        db.collection("users")
            .document(userEmail)
            .collection("posts")
            .document(blogPost.identifier)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    func getAllPosts(completion: @escaping ([BlogPost]) -> Void) {
        
        db.collection("users")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }
                
                let emails: [String] = documents.compactMap { return $0["email"] as? String }
                
                guard !emails.isEmpty else {
                    return completion([])
                }
                
                let group = DispatchGroup()
                var result: [BlogPost] = []
                
                for email in emails {
                    group.enter()
                    self.getPosts(email: email) { userPosts in
                        defer {
                            group.leave()
                        }
                        
                        result.append(contentsOf: userPosts)
                    }
                }
                
                group.notify(queue: .global()) {
                    print("Feed posts: \(result.count)")
                    completion(result)
                }
            }
    }
    
    func getPosts(email: String, completion: @escaping ([BlogPost]) -> Void) {
        let userEmail = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        
        db.collection("users")
            .document(userEmail)
            .collection("posts")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }
                
                let posts: [BlogPost] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String,
                          let title = dictionary["title"] as? String,
                          let text = dictionary["body"] as? String,
                          let timestamp = dictionary["created"] as? TimeInterval,
                          let headerImageUrl = dictionary["headerImageUrl"] as? String else {
                        print("Invalid post fetch conversion")
                        return nil
                    }
                    
                    let post = BlogPost(identifier: id, title: title, timestamp: timestamp, headerImageUrl: URL(string: headerImageUrl), text: text)
                    
                    return post
                })
                completion(posts)
            }
    }
    
    func insertUser(user: User, completion: @escaping (Bool) -> Void) {
        let documentId = user.email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        
        let data: [String: Any] = [
            "name": user.name,
            "email": user.email
        ]
        
        db.collection("users")
            .document(documentId)
            .setData(data) { error in
            completion(error == nil)
        }
    }
    
    func getUser(email: String, completion: @escaping (User?) -> Void) {
        let documentId = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        
        db.collection("users").document(documentId).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil, let name = data["name"] as? String else {
                completion(nil)
                return
            }
            
            let ref = data["profile_photo"] as? String
            let user = User(name: name, email: email, profilePicture: ref)
            completion(user)
        }
    }
    
    func updateProfilePhoto(email: String, completion: @escaping(Bool) -> Void) {
        let path = email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")
        let ref = "profile_picture/\(path)/photo.png"
        
        db.collection("users").document(path).getDocument { [weak self] snapshot, error in
            guard var data = snapshot?.data(), error == nil else { return }
            
            data["profile_photo"] = ref
            
            self?.db.collection("users").document(path).setData(data) { error in
                completion(error == nil)
            }
        }
    }
}
