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
	
    @IBOutlet private weak var tableView: UITableView!

    private let skipButtonFrame = CGRect(x: 0, y: 0, width: 35, height: 17)
    let defaultCellHeight = CGFloat(64.0)
    let headerCellHeight = CGFloat(47.0)

	var stream: Stream?
    var isCreatingStream = false
    var showSkipButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        checkIfCreatingStream()
        setupTableView()

        if showSkipButton {
            let skipButton = UIButton(type: .custom)
            skipButton.setTitle("Skip", for: .normal)
            skipButton.frame = skipButtonFrame
            skipButton.addTarget(self, action: #selector(InviteStreamViewController.doneTapped), for: .touchUpInside)
            let skipItem = UIBarButtonItem(customView: skipButton)

            self.navigationItem.setRightBarButtonItems([skipItem], animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TextEmailTableViewCell", bundle: nil), forCellReuseIdentifier: "textEmailCell")
        tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
        tableView.register(UINib(nibName: "InviteFriendsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "friendsHeaderCell")

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
			streamVC.stream = stream
            streamVC.navigationItem.title = stream?.name ?? ""
            streamVC.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(streamVC, animated: true)
        }
        else { //not creating stream, so dismiss
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textTapped() {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Download Stormtrooper to join my Stream: http://ibm.biz/BdsMEz";
        //messageVC.recipients = [""]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: true, completion: nil)
    }
    
    func emailTapped() {
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
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        sendMailErrorAlert.addAction(defaultAction)
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

extension InviteStreamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped row \(indexPath.item)")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.item {
        case 0:
            //show text
            guard let textCell = tableView.dequeueReusableCell(withIdentifier: "textEmailCell") as? TextEmailTableViewCell else {
                return UITableViewCell()
            }
            textCell.selectionStyle = .none
            textCell.textEmailLabel.text = "Invite via Text"
            return textCell
        case 1:
            //show email
            guard let emailCell = tableView.dequeueReusableCell(withIdentifier: "textEmailCell") as? TextEmailTableViewCell else {
                return UITableViewCell()
            }
            emailCell.selectionStyle = .none
            emailCell.textEmailLabel.text = "Invite via Email"
            return emailCell
        case 2:
            //show header view
            guard let friendsHeaderCell = tableView.dequeueReusableCell(withIdentifier: "friendsHeaderCell") as? InviteFriendsHeaderTableViewCell else {
                return UITableViewCell()
            }
            friendsHeaderCell.selectionStyle = .none
            friendsHeaderCell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0); // Moving seperator out of the screen
            return friendsHeaderCell
        case 3...10:
            //number of stormtrooper friends
            guard let friendCell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as? FriendTableViewCell else {
                return UITableViewCell()
            }
            friendCell.selectionStyle = .none
            return friendCell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            //clicked text
            textTapped()
            break
        case 1:
            //clicked email
            emailTapped()
            break
        case 3...10:
            //click a stormtrooper friends
            break
        default:
            // do nothing
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            //show text
            return defaultCellHeight
        case 1:
            //show email
            return defaultCellHeight
        case 2:
            //show header view
            return headerCellHeight
        case 3...10:
            //number of stormtrooper friends
            return defaultCellHeight
        default:
            return defaultCellHeight
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}
