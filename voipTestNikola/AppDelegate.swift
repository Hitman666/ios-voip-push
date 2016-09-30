//
//  AppDelegate.swift
//  voipTestNikola
//
//  Created by Nikola on 9/19/16.
//  Copyright © 2016 Nikola. All rights reserved.
//

import UIKit
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Enable all notification type. VoIP Notifications don't present a UI but we will use this to show local nofications later
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        
        //register the notification settings
        application.registerUserNotificationSettings(notificationSettings)
        
        //output what state the app is in. This will be used to see when the app is started in the background
        NSLog("app launched with state \(application.applicationState)")

        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        //register for voip notifications
        let voipRegistry = PKPushRegistry(queue: dispatch_get_main_queue())
        voipRegistry.desiredPushTypes = Set([PKPushTypeVoIP])
        voipRegistry.delegate = self;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(registry: PKPushRegistry!, didUpdatePushCredentials credentials: PKPushCredentials!, forType type: String!) {
        
        //print out the VoIP token. We will use this to test the nofications.
        NSLog("voip token: \(credentials.token)")
    }
    
    func pushRegistry(registry: PKPushRegistry!, didReceiveIncomingPushWithPayload payload: PKPushPayload!, forType type: String!) {
        
        let payloadDict = payload.dictionaryPayload["aps"] as? Dictionary<String, String>
        let message = payloadDict?["alert"]
        
        //present a local notifcation to visually see when we are recieving a VoIP Notification
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
            
            let localNotification = UILocalNotification();
            localNotification.alertBody = message
            localNotification.applicationIconBadgeNumber = 1;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification);
        }
            
        else {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let alert = UIAlertView(title: "VoIP Notification", message: message, delegate: nil, cancelButtonTitle: "Ok");
                alert.show()
            })
        }
        
        NSLog("incoming voip notfication: \(payload.dictionaryPayload)")
    }
    
    func pushRegistry(registry: PKPushRegistry!, didInvalidatePushTokenForType type: String!) {
        
        NSLog("token invalidated")
    }
}