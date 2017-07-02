//
//  AppDelegate.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 1/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let dataClient = CoreDataClient()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        
        let provider = APIClient(
            base: .develop,
            jsonContext: dataClient.jsonContext,
            viewContext: dataClient.viewContext)
        
        let listingsViewController = CategoriesViewController(provider: provider)
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [listingsViewController]
        
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [navigationController]
        splitViewController.preferredDisplayMode = .allVisible
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}
