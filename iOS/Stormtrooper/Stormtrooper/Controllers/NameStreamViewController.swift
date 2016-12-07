//
//  NameStreamViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 12/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class NameStreamViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func skipToStreamTapped(_ sender: Any) {
        guard let streamVC = Utils.vcWithNameFromStoryboardWithName("stream", storyboardName: "Main") as? StreamViewController else {
            return
        }
        streamVC.navigationItem.title = "My Stream"
        streamVC.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(streamVC, animated: true)
    }
    
    @IBAction func inviteFriendsTapped(_ sender: Any) {
        guard let inviteVC = Utils.vcWithNameFromStoryboardWithName("inviteStream", storyboardName: "Main") as? InviteStreamViewController else {
            return
        }
        inviteVC.navigationItem.title = "Invite to Stream"
        self.navigationController?.pushViewController(inviteVC, animated: true)
    }
    

}
