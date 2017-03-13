//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit

/// View controller for popupw windows.
class PopupViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var primaryButton: UIButton!
    @IBOutlet weak private var secondaryButton: UIButton?
    
    /// The title text in the popup.
    var titleText: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    /// The image displayed in the popup.
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    /// The message in the popup.
    var messageText: String? {
        get { return messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    /// The description in the popup.
    var descriptionText: String? {
        get { return descriptionLabel.text }
        set { descriptionLabel.text = newValue }
    }
    
    /// The text of the primary action of the popup.
    var primaryButtonText: String? {
        get { return primaryButton.titleLabel?.text }
        set { primaryButton.setTitle(newValue, for: .normal) }
    }
    
    /// The text of the secondary action of the popup.
    var secondaryButtonText: String? {
        get { return secondaryButton?.titleLabel?.text }
        set { secondaryButton?.setTitle(newValue, for: .normal) }
    }
    
    /// Method to call on primary button completion.
    var primaryCompletion: () -> Void = { }
    
    /// Manager to control popup presentation.
    private let presentationManager = PopupPresentationManager()
    
    /// Creates a new empty popup view controller and sets it up.
    init() {
        super.init(nibName: nil, bundle: nil)
        setupViewController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewController()
    }
    
    /// Creates a new popup and sets memeber variables based on the
    /// passed in parameters.
    ///
    /// - Parameters:
    ///   - titleText: The title text in the popup.
    ///   - image: The image displayed in the popup.
    ///   - messageText: The message text in the popup.
    ///   - descriptionText: The description text in the popup.
    ///   - primaryButtonText: The text of the primary action of the popup.
    ///   - secondaryButtonText: The text of the secondary action of the popup.
    ///   - completion: Method to call on primary button completion.
    /// - Returns: The newly created popup view controller.
    static func instantiate(
        titleText: String,
        image: UIImage,
        messageText: String,
        descriptionText: String,
        primaryButtonText: String,
        secondaryButtonText: String? = nil,
        completion: @escaping () -> Void)
        -> PopupViewController
    {
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        let popupViewController: PopupViewController
        if secondaryButtonText == nil {
            popupViewController = storyboard.instantiateViewController(withIdentifier: "popup-1button") as! PopupViewController
        } else {
            popupViewController = storyboard.instantiateViewController(withIdentifier: "popup-2button") as! PopupViewController
        }
        
        popupViewController.loadView()
        popupViewController.titleText = titleText
        popupViewController.image = image
        popupViewController.messageText = messageText
        popupViewController.descriptionText = descriptionText
        popupViewController.primaryButtonText = primaryButtonText
        popupViewController.secondaryButtonText = secondaryButtonText
        popupViewController.primaryCompletion = completion
        return popupViewController
    }
    
    /// Sets up the view controller.
    private func setupViewController() {
        transitioningDelegate = presentationManager
        modalPresentationStyle = .custom
    }
    
    /// Dismisses the popup if tapped outside if there's a secondary action.
    ///
    /// - Parameter recognizer: The tap recognizer
    @IBAction private func handleTapOverlay(recognizer: UITapGestureRecognizer) {
        if secondaryButtonText != nil {
            dismiss(animated: true)
        }
    }
    
    /// Dismiss the popup and call the primary completion callback.
    @IBAction private func handleTapPrimaryButton() {
        dismiss(animated: true, completion: primaryCompletion)
    }

    /// Dismiss the popup.
    @IBAction private func handleTapSecondaryButton() {
        dismiss(animated: true)
    }
}

/// Manager to present the popup.
private class PopupPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    /// Returns the presentation controller for the custom presentation style.
    ///
    /// - Parameters:
    ///   - presented: The view controller being presented.
    ///   - presenting: The view controller that will be presenting the presented
    /// view controller.
    ///   - source: The view controller that is the source of the custom presentation.
    /// - Returns: The custom presentation controller for managing the modal presentation.
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopupPresentationController(presentedViewController: presented, presenting: source)
        return presentationController
    }
    
    /// Asks your delegate for the transition animator object to use when presenting a view controller.
    ///
    /// - Parameters:
    ///   - presented: The view controller being presented.
    ///   - presenting: The view controller that will be presenting the presented
    /// view controller.
    ///   - source: The view controller that is the source of the custom presentation.
    /// - Returns: The animator object to use when presenting the view controller.
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ZoomTransition(direction: .in)
        return transition
    }
    
    /// Asks your delegate for the transition animator object to use when dismissing a view controller.
    ///
    /// - Parameter dismissed: The view controller being dismissed.
    /// - Returns: The animator object to use when dismissing the view controller
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ZoomTransition(direction: .out)
        return transition
    }
}

/// Presentation controller for presenting the popup.
private class PopupPresentationController: UIPresentationController {
    /// Blur view around the popup.
    private lazy var blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.effect = nil
        return blurView
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        if let presentingViewController = presentingViewController {
            blurView.frame = presentingViewController.view.bounds
        }
    }
    
    /// Animates the presenting of the popup.
    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            blurView.frame = containerView.bounds
            containerView.insertSubview(blurView, at: 0)
        }
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurView.effect = UIBlurEffect(style: .dark)
        })
    }
    
    /// Animates the dismissing of the popup
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurView.effect = nil
        })
    }
}

/// Transition to zoom the popup in and out.
private class ZoomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// The duration of zooming in.
    private let inDuration: TimeInterval = 0.22
    /// The duration of zooming out.
    private let outDuration: TimeInterval = 0.20
    /// What direction the popup is currently zooming.
    private let direction: AnimationDirection
    
    /// Creates a new zoom transition starting with the given transition.
    ///
    /// - Parameter direction: The starting direction of the zoom.
    init(direction: AnimationDirection) {
        self.direction = direction
        super.init()
    }
    
    /// Returns the duration of the transition.
    ///
    /// - Parameter transitionContext: The context of the transition.
    /// - Returns: The duration of the transition.
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return direction == .in ? inDuration : outDuration
    }
    
    /// Performs the transition animation.
    ///
    /// - Parameter transitionContext: The context of the transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.viewController(forKey: .to) else { return }
        guard let from = transitionContext.viewController(forKey: .from) else { return }
        switch direction {
        case .in:
            let container = transitionContext.containerView
            container.addSubview(to.view)
            to.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(
                withDuration: 0.6,
                delay: 0.0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: [.curveEaseOut],
                animations: { to.view.transform = CGAffineTransform(scaleX: 1, y: 1) },
                completion: { completed in transitionContext.completeTransition(completed) }
            )
        case .out:
            UIView.animate(
                withDuration: outDuration,
                delay: 0.0,
                options: [.curveEaseIn],
                animations: {
                    from.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    from.view.alpha = 0.0
                },
                completion: { completed in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            )
        }
    }
}

/// The direction that is being animated.
///
/// - `in`: Animation is zooming in.
/// - out: Animation is zooming out.
private enum AnimationDirection {
    case `in`
    case out
}
