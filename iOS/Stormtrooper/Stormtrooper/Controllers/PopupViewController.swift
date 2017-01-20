//
//  PopupViewController.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 1/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var primaryButton: UIButton!
    @IBOutlet weak private var secondaryButton: UIButton!
    
    var titleText: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var messageText: String? {
        get { return messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    var descriptionText: String? {
        get { return descriptionLabel.text }
        set { descriptionLabel.text = newValue }
    }
    
    var primaryButtonText: String? {
        get { return primaryButton.titleLabel?.text }
        set { primaryButton.setTitle(newValue, for: .normal) }
    }
    
    var secondaryButtonText: String? {
        get { return secondaryButton.titleLabel?.text }
        set { secondaryButton.setTitle(newValue, for: .normal) }
    }
    
    var completion: () -> Void = { }
    
    private let presentationManager = PopupPresentationManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupViewController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewController()
    }
    
    static func instantiate(
        titleText: String,
        image: UIImage,
        messageText: String,
        descriptionText: String,
        primaryButtonText: String,
        secondaryButtonText: String,
        completion: @escaping () -> Void)
        -> PopupViewController
    {
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "popup") as! PopupViewController
        popupViewController.loadView()
        popupViewController.titleText = titleText
        popupViewController.image = image
        popupViewController.messageText = messageText
        popupViewController.descriptionText = descriptionText
        popupViewController.primaryButtonText = primaryButtonText
        popupViewController.secondaryButtonText = secondaryButtonText
        popupViewController.completion = completion
        return popupViewController
    }
    
    private func setupViewController() {
        transitioningDelegate = presentationManager
        modalPresentationStyle = .custom
    }
    
    @IBAction private func handleTapOverlay(recognizer: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction private func handleTapPrimaryButton() {
        dismiss(animated: true, completion: completion)
    }

    @IBAction private func handleTapSecondaryButton() {
        dismiss(animated: true)
    }
}

private class PopupPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopupPresentationController(presentedViewController: presented, presenting: source)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ZoomTransition(direction: .in)
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ZoomTransition(direction: .out)
        return transition
    }
}

private class PopupPresentationController: UIPresentationController {
    
    private lazy var dimView: UIView = {
        let dimView = UIView()
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = .black
        dimView.alpha = 0.0
        return dimView
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        if let presentingViewController = presentingViewController {
            dimView.frame = presentingViewController.view.bounds
        }
    }
    
    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            dimView.frame = containerView.bounds
            containerView.insertSubview(dimView, at: 0)
        }
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimView.alpha = 0.7
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimView.alpha = 0.0
        })
    }
}

private class ZoomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let inDuration: TimeInterval = 0.22
    private let outDuration: TimeInterval = 0.20
    private let direction: AnimationDirection
    
    init(direction: AnimationDirection) {
        self.direction = direction
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return direction == .in ? inDuration : outDuration
    }
    
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

private enum AnimationDirection {
    case `in`
    case out
}
