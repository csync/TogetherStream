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
	
	var streamName: String?
    
    var isCreatingStream = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        checkIfCreatingStream()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func checkIfCreatingStream() {
        guard let _ = self.navigationController else {
            //if inviting from stream, not in nav controller, so will dismiss when done is tapped rather than moving forward in stream creation process
            isCreatingStream = false
            return
        }
        //if navigation controller exists, user is creating stream, so push forward in flow
        isCreatingStream = true
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
        if isCreatingStream { //move to next screen in flow
            guard let streamVC = Utils.vcWithNameFromStoryboardWithName("stream", storyboardName: "Stream") as? StreamViewController else {
                return
            }
			streamVC.hostID = FacebookDataManager.sharedInstance.profile?.userID
            streamVC.navigationItem.title = streamName ?? "My Stream"
            streamVC.navigationItem.hidesBackButton = true
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(streamVC, animated: true)
            }
        }
        else { //not creating stream, so dismiss
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func textTapped(_ sender: Any) {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Download Stormtrooper to join my Stream: http://ibm.biz/BdsMEz";
        //messageVC.recipients = [""]
        messageVC.messageComposeDelegate = self
        DispatchQueue.main.async {
            self.present(messageVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func emailTapped(_ sender: Any) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        //mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("Check this out!")
        mailComposerVC.setMessageBody("Download Stormtrooper to join my Stream: http://ibm.biz/BdsMEz", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            DispatchQueue.main.async {
                self.present(mailComposerVC, animated: true, completion: nil)
            }
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        DispatchQueue.main.async {
            let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
        
    }

}

extension InviteStreamViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
            }
        case .failed:
            print("Message failed")
            DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
            }
        case .sent:
            print("Message was sent")
            DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension InviteStreamViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
            }
        case .failed:
            print("Message failed")
            DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
            }
        case .sent:
            print("Message was sent")
            DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
            }
        case .saved:
            print("Message was saved")
            DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
            }
        }
    }
}
