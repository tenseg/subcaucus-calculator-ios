//
//  AppDelegate.swift
//  SubCalc
//
//  Created by Eric Celeste on 2015.12.01.
//  Copyright © 2019 Tenseg LLC.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
	
	func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
		if let urlComps = URLComponents(url: url, resolvingAgainstBaseURL: true) {
			var allowURLHandling = true
			// allow only some hosts on the released app
			#if RELEASE // see https://kitefaster.com/2016/01/23/how-to-specify-debug-and-release-flags-in-xcode-with-swift/
				let allowedHosts = [
					"import"
				]
				allowURLHandling = allowedHosts.contains(urlComps.host!)
			#endif
			// only route if the url is for our app
			if urlComps.scheme == "subcalc" && allowURLHandling {
				if let viewController = self.window?.rootViewController as? ViewController {
					viewController.handleSubcalcURLComponents(urlComps)
				}
				return true
			}
		}
		return false
	}
	
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		// if coming from universal links
		if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
			if let urlComps = URLComponents(url: userActivity.webpageURL!, resolvingAgainstBaseURL: false) {
				if let viewController = self.window?.rootViewController as? ViewController {
					viewController.importQuery(urlComps.queryItems)
				}
			}
		}
		return true
	}

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

	override func buildMenu(with builder: UIMenuBuilder) {
		super.buildMenu(with: builder)
		guard builder.system == .main else { return }

		// remove menu items
		builder.remove(menu: .services)
		builder.remove(menu: .file)
		builder.remove(menu: .edit)
		builder.remove(menu: .format)
		builder.remove(menu: .toolbar)
		
		// add menu items
	}
}
