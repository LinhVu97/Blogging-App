//
//  SignUpViewController.swift
//  BloggingApp
//
//  Created by Linh Vu on 15/10/24.
//

import UIKit

class SignUpViewController: UITabBarController {
    private let headerView = SignInHeaderView()
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Full name"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Email Adress"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Create account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        title = "Create Account"
        view.addSubview(headerView)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/3.5)
        nameField.frame = CGRect(x: 20, y: headerView.bottom, width: view.width-40, height: 50)
        emailField.frame = CGRect(x: 20, y: nameField.bottom+10, width: view.width-40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-40, height: 50)
        signUpButton.frame = CGRect(x: 20, y: passwordField.bottom+20, width: view.width-40, height: 50)
    }
    
    @objc private func didTapSignUp() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let name = nameField.text, !name.isEmpty else  {
            return
        }
        
        AuthManager.shared.signUp(email: email, password: password) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                let newUser = User(name: name, email: email, profilePicture: nil)
                DatabaseManager.shared.insertUser(user: newUser) { inserted in
                    guard inserted else { return }
                    
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(name, forKey: "name")
                    DispatchQueue.main.async {
                        let vc = TabbarViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            } else {
                print("Sign Up Failed")
            }
        }
    }
}
