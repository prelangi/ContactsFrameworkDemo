//
//  AppDelegate.swift
//  ContactsFramework
//
//  Created by Prasanthi Relangi on 4/27/16.
//  Copyright © 2016 prasanthi. All rights reserved.
//

import UIKit
import Contacts




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var contactStore = CNContactStore()
    
    //Handy function to get App Delegate
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    //Handy function to show alert controller
    func showMessage(message: String) {
        let alertController = UIAlertController(title: "Birthdays", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        
        }
        
        alertController.addAction(dismissAction)
        
        //An Alert Controller can only be presented by a view controller and the App Delegate is not a view controller
        //So,
        let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        
        presentedViewController.presentViewController(alertController, animated: true, completion: nil)
    }




    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
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
    
    
    //Request access for contacts on the phone 
    func requestForAccess(completionHandler: (accessGranted:Bool)-> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        switch(authorizationStatus) {
            
        case .Authorized:
            completionHandler(accessGranted: true)
        case .Denied,.NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, error) in
                
                if access {
                    completionHandler(accessGranted: true)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(error!.localizedDescription)\n\n Please allow app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })
        default: completionHandler(accessGranted: false)
            
        }
    }
 


}

