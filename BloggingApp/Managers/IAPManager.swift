//
//  IAPManager.swift
//  BloggingApp
//
//  Created by Linh Vu on 15/10/24.
//

import Foundation
import Purchases

final class IAPManger {
    static let shared = IAPManger()
    
    private init() {}
    
    func isPremium() -> Bool {
        return false
    }
    
    func getSubcriptionStatus() {
        
    }
    
    func fetchPackages(completion: @escaping (Purchases.Package?) -> Void) {
        
    }
    
    func subscribe(pakage: Purchases.Package) {
        
    }
    
    func restorePurchases() {
        
    }
}
