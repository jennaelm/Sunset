//
//  SettingsViewController.swift
//  Sunset
//
//  Created by Jenna Miller on 6/26/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var segmentedControlBar: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        if NSUserDefaults.standardUserDefaults().stringForKey("notificationPreference") == "10" {
             self.segmentedControlBar.selectedSegmentIndex = 0
        } else if NSUserDefaults.standardUserDefaults().stringForKey("notificationPreference") == "15" {
             self.segmentedControlBar.selectedSegmentIndex = 1
        } else if NSUserDefaults.standardUserDefaults().stringForKey("notificationPreference") == "20" {
             self.segmentedControlBar.selectedSegmentIndex = 2
        } else {
             self.segmentedControlBar.selectedSegmentIndex = 1
             NSUserDefaults.standardUserDefaults().setObject("15", forKey: "notificationPreference")
        }
    }

    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        if segmentedControlBar.selectedSegmentIndex == 0 {
            NSUserDefaults.standardUserDefaults().setObject("10", forKey: "notificationPreference")
        } else if segmentedControlBar.selectedSegmentIndex == 1 {
            NSUserDefaults.standardUserDefaults().setObject("15", forKey: "notificationPreference")
        } else if segmentedControlBar.selectedSegmentIndex == 2 {
            NSUserDefaults.standardUserDefaults().setObject("20", forKey: "notificationPreference")
        }
    }
    
}
