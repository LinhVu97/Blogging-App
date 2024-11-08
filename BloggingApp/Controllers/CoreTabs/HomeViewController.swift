//
//  ViewController.swift
//  BloggingApp
//
//  Created by Linh Vu on 15/10/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    var posts: [BlogPost] = []
    
    private let composeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "square.and.pencil",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)),
                        for: .normal)
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.label.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 10
        return button
    }()
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        composeButton.frame = CGRect(x: view.frame.width - 88,
                                     y: view.frame.height - 88 - view.safeAreaInsets.bottom,
                                     width: 80,
                                     height: 80)
        
        tableView.frame = view.bounds
    }
    
    private func setupView() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            let vc = PayWallViewController()
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true)
        }
        
        view.addSubview(tableView)
        view.addSubview(composeButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        composeButton.addTarget(self, action: #selector(didTapCreatePost), for: .touchUpInside)
        
        fetchAllPosts()
    }
    
    @objc private func didTapCreatePost() {
        let vc = CreateNewPostViewController()
        vc.createNewPostDelegate = self
        vc.title = "Create Post"
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func fetchAllPosts() {
        DatabaseManager.shared.getAllPosts() { [weak self] posts in
            self?.posts = posts
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
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

extension HomeViewController: CreateNewPostViewControllerDelegate {
    func didCreateNewPost() {
        fetchAllPosts()
    }
}
