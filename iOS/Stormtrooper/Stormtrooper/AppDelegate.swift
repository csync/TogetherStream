//
//  AppDelegate.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import AVFoundation
import FBSDKLoginKit
import UserNotifications
import Fabric
import Crashlytics
import Google

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Fabric and the Crashlytics kit
        Fabric.with([Crashlytics.self])
        
        // Initialize Google Analytics
        setupGoogleAnalytics()
        
        self.setAudioToPlayWhileSilenced()
		requestAuthorizationForNotifications(for: application)
		
        //set status bar to light
        UIApplication.shared.statusBarStyle = .lightContent
        
		UNUserNotificationCenter.current().delegate = self
		// Clear notifications
		UIApplication.shared.applicationIconBadgeNumber = 0
		
		// autoupdates profile when access token changes
		FBSDKProfile.enableUpdates(onAccessTokenChange: true)
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Set back button appearance
        UINavigationBar.appearance().tintColor = UIColor.white
        
        return true
    }
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
		UserDefaults.standard.set(deviceTokenString, forKey: "deviceToken")
	}

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Utils.sendGoogleAnalyticsEvent(withCategory: "AppDelegate", action: "EnteredBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
		// Clear notifications
		UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		FBSDKAppEvents.activateApp()
        Utils.sendGoogleAnalyticsEvent(withCategory: "AppDelegate", action: "BecameActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
	
    
    func setAudioToPlayWhileSilenced() {
        // Audio from videos will play even if silence switch is enabled on the device
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            // report for an errorapplication.registerForRemoteNotifications()
            print("Error setting AVAudioSession category!")
        }
    }
	
	
	func requestAuthorizationForNotifications(for application: UIApplication) {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
			if !accepted {
				print("Notification access denied.")
			}
			application.registerForRemoteNotifications()
		}
	}
    
    private func setupGoogleAnalytics() {
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.verbose // TODO: remove before app release
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
	// Process notification when app is terminated or running in background
	func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void)
    {
        if let json = response.notification.request.content.userInfo as? [String: Any] {
            if let stream = Stream(jsonDictionary: json) {
                presentStreamInvite(stream: stream)
            }
        }
		completionHandler()
	}
	
	// Process notification when app is running in foreground
	func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        if let json = notification.request.content.userInfo as? [String: Any] {
            if let stream = Stream(jsonDictionary: json) {
                presentStreamInvite(stream: stream)
            }
        }
		completionHandler([])
	}

    // Present a stream invite
    private func presentStreamInvite(stream: Stream) {
        guard let rootViewController = window?.rootViewController else { return }
        let viewController = rootViewController.mostActiveViewController
        
        // refresh the stream list, if necessary
        if let homeViewController = viewController as? HomeViewController {
            homeViewController.refreshStreams()
        }
        
        // define callback to present the stream
        let presentStream = {
            guard let streamVC = Utils.instantiateViewController(withIdentifier: "stream", fromStoryboardNamed: "Stream") as? StreamViewController else {
                return
            }
            streamVC.stream = stream
            streamVC.navigationItem.title = stream.name
            DispatchQueue.main.async {
                // view controller was popped if hosting, so we need to reload it
                guard let rootViewController = self.window?.rootViewController else { return }
                let viewController = rootViewController.mostActiveViewController
                viewController.navigationController?.pushViewController(streamVC, animated: true)
            }
        }
        
        // define popup with default user profile picture and name
        let popup = PopupViewController.instantiate(
            titleText: "YOU'VE BEEN INVITED",
            image: #imageLiteral(resourceName: "profile_85"),
            messageText: stream.name,
            descriptionText: "",
            primaryButtonText: "JOIN STREAM",
            secondaryButtonText: "Dismiss",
            completion: { self.presentConfirmation(viewController: viewController, callback: presentStream) }
        )
        
        // present popup
        viewController.present(popup, animated: true)
        
        // update popup with user profile picture and name from Facebook
        FacebookDataManager.sharedInstance.fetchInfoForUser(withID: stream.hostFacebookID) { error, user in
            guard error == nil else { return }
            if let user = user {
                popup.descriptionText = "by \(user.name)"
                user.fetchProfileImage { error, image in
                    guard error == nil else { return }
                    if let image = image {
                        popup.image = image
                    }
                }
            }
        }
    }
    
    // If hosting, then present a confirmation to end the stream.
    // If not hosting, then execute the callback immediately.
    private func presentConfirmation(viewController: UIViewController, callback: @escaping (Void) -> Void) {
        guard let streamViewController = viewController as? StreamViewController,
            let stream = streamViewController.stream,
            streamViewController.isHost
        else {
            callback()
            return
        }
        
        streamViewController.leaveStream { callback() }
    }
}

