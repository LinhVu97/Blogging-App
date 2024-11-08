//
//  AppDelegate.swift
//  BloggingApp
//
//  Created by Linh Vu on 15/10/24.
//

import UIKit
import FirebaseCore
import Purchases
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
//        Purchases.configure(withAPIKey: "mgByuJPTRCAzIyGwIATAhYNgsYXpNcZB")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            let vc: UIViewController
            
            if AuthManager.shared.isSignedIn {
                vc = TabbarViewController()
            } else {
                let signInVC = SignInViewController()
                signInVC.navigationItem.largeTitleDisplayMode = .always

                let navVC = UINavigationController(rootViewController: signInVC)
                navVC.navigationBar.prefersLargeTitles = true

                vc = navVC
            }
            
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        return true
    }

}

