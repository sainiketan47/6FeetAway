//
//  AppDelegate.swift
//  Ranging
//
//  Created by ketan on 26/03/20.
//  Copyright © 2020 ELEK. All rights reserved.
///// settingdfdf

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.isIdleTimerDisabled = true
        sleep(1)
        return true
    }
    
    // MARK: Application Lifecycle
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

}

