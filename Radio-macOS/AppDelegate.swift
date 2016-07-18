//
//  AppDelegate.swift
//  Radio-macOS
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import Cocoa

protocol ApplicationDelegate {
    func appWillTerminate()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    
    var delegate: ApplicationDelegate?
    
    // MARK: - App Delegate
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        UserPreferences.registerDefaults()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        delegate?.appWillTerminate()
    }

}

