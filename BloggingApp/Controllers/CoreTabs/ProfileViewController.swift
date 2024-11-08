//
//  ProfileViewController.swift
//  BloggingApp
//
//  Created by Linh Vu on 15/10/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let currentEmail: String
    var user: User?
    var posts: [BlogPost] = []
    
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self, forCellReuseIdentifier: PostPreviewTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
    }
    
    private func setupView() {
        setupSignOutButton()
        setupTable()
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupSignOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(didTapSignOut))
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setupTableHeader()
        fetchProfileData()
    }
    
    private func setupTableHeader(profilePhotoUrl: String? = nil, name: String? = nil) {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))
        headerView.isUserInteractionEnabled = true
        headerView.backgroundColor = .systemBlue
        tableView.clipsToBounds = true
        tableView.tableHeaderView = headerView
        
        let profilePhoto = UIImageView(image: UIImage(systemName: "person.circle"))
        profilePhoto.isUserInteractionEnabled = true
        profilePhoto.tintColor = .white
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.frame = CGRect(x: (view.width-(view.width/4))/2,
                                    y: (headerView.height-(view.width/4))/2.5,
                                    width: view.width/4,
                                    height: view.width/4)
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.cornerRadius = profilePhoto.width/2
        headerView.addSubview(profilePhoto)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
        profilePhoto.addGestureRecognizer(tap)
        
        let emailLabel = UILabel()
        emailLabel.text = currentEmail
        emailLabel.textAlignment = .center
        emailLabel.textColor = .white
        emailLabel.font = .systemFont(ofSize: 25, weight: .bold)
        emailLabel.frame = CGRect(x: 20,
                                   y: profilePhoto.bottom+10,
                                   width: view.width-40,
                                   height: 30)
        headerView.addSubview(emailLabel)
        
        if let name = name {
            title = name
        }
        
        if let ref = profilePhotoUrl {
            StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
                guard let url = url else { return }
                
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else { return }
                    
                    DispatchQueue.main.async {
                        profilePhoto.image = UIImage(data: data)
                    }
                }
                task.resume()
            }
        }
    }
    
    private func fetchProfileData() {
        DatabaseManager.shared.getUser(email: currentEmail) { [weak self] user in
            guard let user = user else { return }
            
            self?.user = user
            
            DispatchQueue.main.async {
                self?.setupTableHeader(profilePhotoUrl: user.profilePicture, name: user.name)
            }
        }
    }
    
    @objc private func didTapProfilePhoto() {
        guard let myEmail = UserDefaults.standard.string(forKey: "email"),
              myEmail == currentEmail else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func didTapSignOut() {
        let sheet = UIAlertController(title: "Sign Out", message: "Are you sure you'd like to sign out?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(nil, forKey: "email")
                        UserDefaults.standard.set(nil, forKey: "name")
                        
                        let signInVC = SignInViewController()
                        signInVC.navigationItem.largeTitleDisplayMode = .always
                        
                        let navVC = UINavigationController(rootViewController: signInVC)
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: nil)
                    }
                }
            }
        }))
        present(sheet, animated: true)
    }
    
    private func fetchPosts() {
        DatabaseManager.shared.getPosts(email: currentEmail) { [weak self] posts in
            guard let self = self else { return }
            
            self.posts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewTableViewCell.identifier, for: indexPath) as! PostPreviewTableViewCell
        cell.configure(with: .init(title: post.title, imageUrl: post.headerImageUrl))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ViewPostViewController(post: post)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        StorageManager.shared.uploadUserProfliePicture(email: currentEmail, image: image) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                DatabaseManager.shared.updateProfilePhoto(email: currentEmail) { updated in
                    guard updated else { return }
                    
                    DispatchQueue.main.async {
                        self.fetchProfileData()
                    }
                }
            }
        }
    }
}
