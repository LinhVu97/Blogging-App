//
//  StorageManager.swift
//  BloggingApp
//
//  Created by Linh Vu on 15/10/24.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage()
    
    private init() {}
    
    func uploadUserProfliePicture(email: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        let path = email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")
        guard let pngData = image?.pngData() else { return }
        
        storage.reference(withPath: "profile_picture/\(path)/photo.png")
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    func downloadUrlForProfilePicture(path: String, completion: @escaping (URL?) -> Void) {
        storage.reference(withPath: path).downloadURL { url, _ in
            completion(url)
        }
    }
    
    func uploadBlogHeaderImage(email: String, image: UIImage, postId: String, completion: @escaping (Bool) -> Void) {
        let path = email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")
        guard let pngData = image.pngData() else { return }
        
        storage.reference(withPath: "post_headers/\(path)/\(postId)/photo.png")
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    func downloadUrlForBlogHeaderImage(email: String, postId: String, completion: @escaping (URL?) -> Void) {
        let emailComponent = email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")
        
        storage.reference(withPath: "post_headers/\(emailComponent)/\(postId)/photo.png")
            .downloadURL { url, _ in
                completion(url)
            }
    }
}
