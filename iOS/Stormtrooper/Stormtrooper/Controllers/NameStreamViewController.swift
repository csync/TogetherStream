//
//  NameStreamViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 12/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

/// View controller for the "Naming Stream" screen
class NameStreamViewController: UIViewController {

	@IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    fileprivate var nextBannerView: NextBannerView!
    
    /// Spacing frame to left pad the name text field.
    private let nameTextFieldSpacingFrame = CGRect(x: 0, y: 0, width: 18, height: 5)
    /// Spacing insets to pad the description text view.
    private let descriptionTextViewSpacingInset = UIEdgeInsets(top: 14, left: 13, bottom: 10, right: 16)
    
    /// The placeholder text of the description view.
    fileprivate let descriptionPlaceholder = "Description (optional)"
    /// Determines if the text inside the description view is placeholder or not
    fileprivate var isDescriptionPlaceholder: Bool {
        return descriptionTextView.text == descriptionPlaceholder
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        setupNavigationItems()
        setupTextFields()
        setupAddVideosBanner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
        UIView.setAnimationsEnabled(true)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            Utils.sendGoogleAnalyticsEvent(withCategory: "Name", action: "SelectedBackButton")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Set the navigation items for this view controller
    private func setupNavigationItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    /// Sets up the text fields
    private func setupTextFields() {
        // Add padding
        nameTextField.leftViewMode = .always
        nameTextField.leftView = UIView(frame: nameTextFieldSpacingFrame)
        descriptionTextView.delegate = self
        descriptionTextView.textContainerInset = descriptionTextViewSpacingInset
        descriptionTextView.textColor = UIColor.stormtrooperPlaceholderGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(nameTextFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    /// Sets up the add videos banner
    private func setupAddVideosBanner() {
        //new instance of accessory view
        nextBannerView = NextBannerView.instanceFromNib()
        
        //add selector to dismiss and when editing to sync up both textfields
        nextBannerView.nextButton.addTarget(self, action: #selector(addVideosTapped), for: .touchUpInside)
        
        //actually set accessory view
        nameTextField.inputAccessoryView = nextBannerView
        descriptionTextView.inputAccessoryView = nextBannerView
    }
    
    /// Shows or hides the next banner depending if the name text field
    /// is empty.
    @objc private func nameTextFieldDidChange() {
        if nameTextField.text?.characters.count ?? 0 > 0 {
            nextBannerView.isHidden = false
        }
        else {
            nextBannerView.isHidden = true
        }
    }
    
    /// When next banner is tapped, transition to "Add Videos" screen.
    ///
    /// - Parameter sender: The button tapped.
    @objc private func addVideosTapped(_ sender: Any) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Name", action: "SelectedAddVideos")
        Utils.sendGoogleAnalyticsEvent(withCategory: "Name", action: "DidAddDescription", value:
            isDescriptionPlaceholder ? 0 : 1)
        
        guard let addVideosVC = Utils.vcWithNameFromStoryboardWithName("addVideos", storyboardName: "AddVideos") as? AddVideosViewController else {
            return
        }
        // Create stream object
        let facebookID = FacebookDataManager.sharedInstance.profile?.userID ?? ""
        let descriptionText = isDescriptionPlaceholder ? "" : descriptionTextView.text ?? ""
        let stream = Stream(
            name: nameTextField.text ?? "",
            csyncPath: "streams.\(facebookID)",
            description: descriptionText,
            hostFacebookID: facebookID)
        
        // Configure AddVideosVC
		addVideosVC.stream = stream
        addVideosVC.isCreatingStream = true
        self.navigationController?.pushViewController(addVideosVC, animated: true)
    }
}

extension NameStreamViewController: UITextFieldDelegate {
    /// On text field return, change first responder to
    /// description text field.
    ///
    /// - Parameter textField: The text field returning.
    /// - Returns: If the text field should return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return false
    }
}

extension NameStreamViewController: UITextViewDelegate {
    /// On editing start, clear the placeholder if present.
    ///
    /// - Parameter textView: The text view that will begain editing.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isDescriptionPlaceholder {
            textView.text = nil
            textView.textColor = UIColor.stormtrooperTextBlack
        }
    }
    
    /// On editing end, add the placeholder if text view is empty.
    ///
    /// - Parameter textView: The text view that will end editing.
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = descriptionPlaceholder
            textView.textColor = UIColor.stormtrooperPlaceholderGray
        }
    }
}
