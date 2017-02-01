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
    
    fileprivate var accessoryView: NextBannerView!
    
    private let nameTextFieldSpacingFrame = CGRect(x: 0, y: 0, width: 18, height: 5)
    private let descriptionTextViewSpacingInset = UIEdgeInsets(top: 14, left: 13, bottom: 10, right: 16)
    
    fileprivate let descriptionPlaceholder = "Description (optional)"
    fileprivate var isDescriptionPlaceholder: Bool {
        return descriptionTextView.text == descriptionPlaceholder
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupAddVideosBanner()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
        UIView.setAnimationsEnabled(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupTextFields() {
        nameTextField.leftViewMode = .always
        nameTextField.leftView = UIView(frame: nameTextFieldSpacingFrame)
        descriptionTextView.delegate = self
        descriptionTextView.textContainerInset = descriptionTextViewSpacingInset
        descriptionTextView.textColor = UIColor.stormtrooperPlaceholderGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(nameTextFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    private func setupAddVideosBanner() {
        //new instance of accessory view
        accessoryView = NextBannerView.instanceFromNib()
        
        //add selector to dismiss and when editing to sync up both textfields
        accessoryView.nextButton.addTarget(self, action: #selector(addVideosTapped), for: .touchUpInside)
        
        //actually set accessory view
        nameTextField.inputAccessoryView = accessoryView
        descriptionTextView.inputAccessoryView = accessoryView
    }
    
    @objc private func nameTextFieldDidChange() {
        if nameTextField.text?.characters.count ?? 0 > 0 {
            accessoryView.isHidden = false
        }
        else {
            accessoryView.isHidden = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc private func addVideosTapped(_ sender: Any) {
        guard let addVideosVC = Utils.vcWithNameFromStoryboardWithName("addVideos", storyboardName: "AddVideos") as? AddVideosViewController else {
            return
        }
        let facebookID = FacebookDataManager.sharedInstance.profile?.userID ?? ""
        let descriptionText = isDescriptionPlaceholder ? "" : descriptionTextView.text ?? ""
        let stream = Stream(
            name: nameTextField.text ?? "",
            csyncPath: "streams.\(facebookID)",
            description: descriptionText,
            hostFacebookID: facebookID)
		addVideosVC.stream = stream
        self.navigationController?.pushViewController(addVideosVC, animated: true)
    }
}

extension NameStreamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.characters.count ?? 0 > 0 {
            accessoryView.isHidden = false
        }
        else {
            accessoryView.isHidden = true
        }
        
        return true
    }
}

extension NameStreamViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isDescriptionPlaceholder {
            textView.text = nil
            textView.textColor = UIColor.stormtrooperTextBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = descriptionPlaceholder
            textView.textColor = UIColor.stormtrooperPlaceholderGray
        }
    }
}
