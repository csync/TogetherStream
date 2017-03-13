//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit

/// View controller for "License Agreement" screen
class LicenseAgreementViewController: UIViewController {
    @IBOutlet weak var licenseTextView: UITextView!
    
    var onDisplayFinished: ((Bool) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        // Fix bug where the view is not scrolled to top
        licenseTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    /// On pressing agree button, dismiss view and send did accept to callback.
    ///
    /// - Parameter sender: The button pressed.
    @IBAction func didPressAgree(_ sender: Any) {
        dismiss(animated: true) {
            self.onDisplayFinished?(true)
        }
    }

    /// On pressing cancel button, dismiss view and send did not accept to callback.
    ///
    /// - Parameter sender: The button pressed.
    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true) {
            self.onDisplayFinished?(false)
        }
    }
}
