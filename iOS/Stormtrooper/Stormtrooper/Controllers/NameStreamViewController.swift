//
//  NameStreamViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 12/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class NameStreamViewController: UIViewController {

	@IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addVideosButton: UIButton!
    
    private let nameTextFieldSpacingFrame = CGRect(x: 0, y: 0, width: 18, height: 5)
    private let descriptionTextViewSpacingInset = UIEdgeInsets(top: 14, left: 13, bottom: 10, right: 16)
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupTextFields() {
        nameTextField.leftViewMode = .always
        nameTextField.leftView = UIView(frame: nameTextFieldSpacingFrame)
        descriptionTextView.textContainerInset = descriptionTextViewSpacingInset
        descriptionTextView.textColor = UIColor.stormtrooperPlaceholderGray
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
        guard let streamVC = Utils.vcWithNameFromStoryboardWithName("stream", storyboardName: "Stream") as? StreamViewController else {
            return
        }
		streamVC.hostID = FacebookDataManager.sharedInstance.profile?.userID
        streamVC.navigationItem.title = nameTextField.text ?? "My Stream"
        streamVC.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(streamVC, animated: true)
    }
    
    @IBAction func didTapScreen(_ sender: Any) {
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    @IBAction func addVideosTapped(_ sender: Any) {
        guard let addVideosVC = Utils.vcWithNameFromStoryboardWithName("addVideos", storyboardName: "AddVideos") as? AddVideosViewController else {
            return
        }
		addVideosVC.streamName = nameTextField.text
        addVideosVC.navigationItem.title = "Add Videos"
        self.navigationController?.pushViewController(addVideosVC, animated: true)
    }
}

extension NameStreamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.characters.count ?? 0 > 0 {
            addVideosButton.isHidden = false
        }
        else {
            addVideosButton.isHidden = true
        }
    }
}

extension NameStreamViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.stormtrooperPlaceholderGray {
            textView.text = nil
            textView.textColor = UIColor.stormtrooperTextBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description (Optional)"
            textView.textColor = UIColor.stormtrooperPlaceholderGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool  {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
