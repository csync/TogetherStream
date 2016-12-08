//
//  InviteStreamViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 12/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import MessageUI

class InviteStreamViewController: UIViewController {

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
    @IBAction func doneTapped(_ sender: Any) {
        guard let streamVC = Utils.vcWithNameFromStoryboardWithName("stream", storyboardName: "Main") as? StreamViewController else {
            return
        }
        streamVC.navigationItem.title = "My Stream"
        streamVC.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(streamVC, animated: true)
    }
    
    @IBAction func textTapped(_ sender: Any) {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Download Stormtrooper to join my Stream: http://ibm.biz/BdsMEz";
        //messageVC.recipients = [""]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: true, completion: nil)
    }
    
    @IBAction func emailTapped(_ sender: Any) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        //mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("Check this out!")
        mailComposerVC.setMessageBody("Download Stormtrooper to join my Stream: http://ibm.biz/BdsMEz", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
        
    }

}

extension InviteStreamViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            controller.dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension InviteStreamViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            controller.dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            controller.dismiss(animated: true, completion: nil)
        case .saved:
            print("Message was saved")
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
