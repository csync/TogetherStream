//
//  HomeViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController {

    var hasShownLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
		
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //show login once for now
        //TODO: save logged in state
        if !hasShownLogin {
            self.displayLoginIfNeeded()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func displayLoginIfNeeded() {
        guard let loginVC = Utils.vcWithNameFromStoryboardWithName("login", storyboardName: "Main") as? LoginViewController else {
            return
        }
        self.present(loginVC, animated: true, completion: { _ in
            self.hasShownLogin = true
        })
        
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        guard let settingsVC = Utils.vcWithNameFromStoryboardWithName("settings", storyboardName: "Main") as? SettingsViewController else {
            return
        }
        self.present(settingsVC, animated: true, completion: { _ in
            
        })
    }

    @IBAction func startStreamTapped(_ sender: Any) {
        guard let streamVC = Utils.vcWithNameFromStoryboardWithName("stream", storyboardName: "Main") as? StreamViewController else {
            return
        }
        self.present(streamVC, animated: true, completion: { _ in
            
        })
    }

}