//
//  AppDelegate.swift
//  Radio-iOS
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import UIKit

protocol ApplicationDelegate {
    func appWillTerminate()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    var delegate: ApplicationDelegate?

    // MARK: - App Delegate

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        delegate?.appWillTerminate()
    }


}

