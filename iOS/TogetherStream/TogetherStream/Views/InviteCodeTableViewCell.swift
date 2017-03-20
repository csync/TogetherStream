//
//  InviteCodeTableViewCell.swift
//  TogetherStream
//
//  Created by Daniel Firsht on 2/27/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class InviteCodeTableViewCell: UITableViewCell {
    @IBOutlet weak var shareCodeButton: UIButton!
    @IBOutlet weak var inviteCodeTextField: UITextField!
    
    var didSelectShareCode: (() -> Void)?
    var didSelectCodeTextField: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareCodeButton.layer.borderWidth = 1
        shareCodeButton.layer.borderColor = UIColor.togetherStreamOrange.cgColor
        shareCodeButton.cornerRadius = 16
        
        inviteCodeTextField.layer.borderWidth = 1
        inviteCodeTextField.layer.borderColor = UIColor.togetherStreamBorderGray.cgColor
    }
    
    @IBAction func didSelectShareCode(_ sender: Any) {
        didSelectShareCode?()
    }
}

extension InviteCodeTableViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        didSelectCodeTextField?()
        return false
    }
}
