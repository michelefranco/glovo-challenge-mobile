//
//  AppDelegate.swift
//  Glovo App
//
//  Created by Michele Franco on 26/01/2019.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = LauncherViewController()
        self.window!.makeKeyAndVisible()
       
        return true
    }

}

