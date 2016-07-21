//
//  DataManager.swift
//  Sunset
//
//  Created by Jenna Miller on 6/26/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol DataManagerDelegate {
    func sunsetUpdated(time: String)
}

class DataManager : NSObject {
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var delegate : DataManagerDelegate?
    
// Parsing JSON

    func getSunsetTime(latitude: String, longitude: String) {
        let url = NSURL(string:"http://api.sunrise-sunset.org/json?lat=\(latitude)&lng=\(longitude)&formatted=0")
        let request = NSURLRequest(URL: url!)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            do {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                let results = jsonDict!["results"] as? NSDictionary
                let sunsetTime = results!["sunset"] as? String
                self.formatTime(sunsetTime!)
                self.createDailyNotifications(sunsetTime!)
            } catch let error as NSError {
                print("Error fetching sunset time. Error: \(error.localizedDescription)")
                self.fetchStoredSunset()
            }
        })
      task.resume()
    }

// Time Formatting
    
    func formatTime(utcTime: String) {
        let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+00:00"
        let sunsetDate = dateFormatter.dateFromString(utcTime)
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
        let formattedDate = dateFormatter.stringFromDate(sunsetDate!)
        self.delegate?.sunsetUpdated(formattedDate)
        persistSunset(formattedDate)
    }
    
// Notifications
    
    func createDailyNotifications(utcTime: String) {
        let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+00:00"
        
        var timeInterval : NSTimeInterval! = 15
        var timeUntilSunset = ""

        if NSUserDefaults.standardUserDefaults().stringForKey("notificationPreference") == "10" {
            timeUntilSunset = "10"
            timeInterval = 10
        } else if NSUserDefaults.standardUserDefaults().stringForKey("notificationPreference") == "15" {
            timeUntilSunset = "15"
            timeInterval = 15 as NSTimeInterval
        } else if NSUserDefaults.standardUserDefaults().stringForKey("notificationPreference") == "20" {
            timeUntilSunset = "20"
            timeInterval = 20 as NSTimeInterval
        } else {
            NSUserDefaults.standardUserDefaults().setObject("15", forKey: "notificationPreference")
            timeUntilSunset = "15"
            timeInterval = 15 as NSTimeInterval
        }
        
        if UIApplication.sharedApplication().scheduledLocalNotifications != nil {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
        let dateToFire = (dateFormatter.dateFromString(utcTime))!.dateByAddingTimeInterval(timeInterval * -60)
        
        let notification = UILocalNotification()
            notification.alertBody = "Sunset is in about \(timeUntilSunset) minutes"
            notification.fireDate = dateToFire
            notification.timeZone = NSTimeZone.localTimeZone()
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.repeatInterval = NSCalendarUnit.Day
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

// Core Data
    
    func persistSunset(time: String) {
        let request = NSFetchRequest(entityName: "SunsetObject")
        var results : [AnyObject]?
        
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
        }
        
        if results != nil {
            let infoFetched = results as? [SunsetObject]!
            for sunset in infoFetched! {
                sunset.time = time
            }
        } else {
            let firstSunset = NSEntityDescription.insertNewObjectForEntityForName("SunsetObject", inManagedObjectContext: context) as! SunsetObject
            firstSunset.time = time
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func fetchStoredSunset() {
        let request = NSFetchRequest(entityName: "SunsetObject")
        var results : [AnyObject]?
        
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
        }
        
        if results != nil {
            let infoFetched = results as? [SunsetObject]!
            for sunset in infoFetched! {
                self.formatTime(sunset.time!)
            }
        }
    }
}