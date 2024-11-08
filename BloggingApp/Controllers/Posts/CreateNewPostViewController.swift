//
//  CreateNewPostViewController.swift
//  BloggingApp
//
//  Created by Linh Vu on 15/10/24.
//

import UIKit

protocol CreateNewPostViewControllerDelegate {
    func didCreateNewPost()
}

class CreateNewPostViewController: UITabBarController {
    
    var createNewPostDelegate: CreateNewPostViewControllerDelegate?
    
    private let titleField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Enter Title..."
        field.backgroundColor = .secondarySystemBackground
        field.autocorrectionType = .yes
        field.autocapitalizationType = .words
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 28)
        return textView
    }()
    
    private var selectedHeaderImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleField.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.width-20, height: 50)
        headerImageView.frame = CGRect(x: 0, y: titleField.bottom+5, width: view.width, height: 160)
        textView.frame = CGRect(x: 10, y: headerImageView.bottom+10, width: view.width-20, height: view.height-210-view.safeAreaInsets.top)
    }
    
    private func setupView() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(didTapPost))
        
        view.addSubview(titleField)
        view.addSubview(headerImageView)
        view.addSubview(textView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        headerImageView.addGestureRecognizer(tap)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapPost() {
        guard let title = titleField.text,
              let body = textView.text,
              let headerImage = selectedHeaderImage,
              let email = UserDefaults.standard.string(forKey: "email"),
        !title.trimmingCharacters(in: .whitespaces).isEmpty,
        !body.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "Enter Post Details", message: "Please enter a title, body and select image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let newPostId = UUID().uuidString
        
        StorageManager.shared.uploadBlogHeaderImage(email: email, image: headerImage, postId: newPostId) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                
                StorageManager.shared.downloadUrlForBlogHeaderImage(email: email, postId: newPostId) { url in
                    guard let url = url else { return }
                    
                    let post = BlogPost(identifier: UUID().uuidString,
                                        title: title,
                                        timestamp: Date().timeIntervalSince1970,
                                        headerImageUrl: url,
                                        text: body)
                    
                    DatabaseManager.shared.insertBlogPost(blogPost: post, email: email) { posted in
                        guard posted else { return }
                        
                        DispatchQueue.main.async {
                            self.didTapCancel()
                            
                            self.createNewPostDelegate?.didCreateNewPost()
                        }
                    }
                }
            }
        }
    }
    
    @objc private func didTapHeader() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension CreateNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        selectedHeaderImage = image
        headerImageView.image = image
    }
}
