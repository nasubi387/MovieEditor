//
//  AppDelegate.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let contensView = ContentsWireframe.assembleModule()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = contensView
        window?.makeKeyAndVisible()
        
        return true
    }
}

