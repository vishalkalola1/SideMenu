import UIKit

final class SlideInPresentationController: UIPresentationController {
    // MARK: - Properties
    private var dimmingView: UIView!
    private let config = SideMenuConfiguration()
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var direction: Direction
    
    // MARK: - Initializers
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         delegate: CustomAdaptiveDelegate,
         direction: Direction) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.delegate = delegate
        setupDimmingView()
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        let size = size(forChildContentContainer: presentedViewController,
                        withParentContainerSize: containerView!.bounds.size)
        frame.size = size
        switch direction {
            case .top:
                frame.origin = .zero
            case .bottom:
                frame.origin = .init(x: 0, y: containerView!.bounds.height - size.height)
            case .left:
                frame.origin = .zero
            case .right:
                frame.origin = .init(x: containerView!.bounds.width - size.width, y: 0)
                print(frame.origin)
        }
        
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        guard let dimmingView = dimmingView else {
            return
        }
        containerView?.insertSubview(dimmingView, at: 0)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["dimmingView": dimmingView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["dimmingView": dimmingView]))
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        if direction == .left || direction == .right {
            return CGSize(width: parentSize.width*0.8, height: parentSize.height)
        } else {
            return CGSize(width: parentSize.width, height: parentSize.height * 0.8)
        }
    }
}

// MARK: - Private
extension SlideInPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
        
        
        let panRecognizer = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePan(_:)))
        dimmingView.addGestureRecognizer(panRecognizer)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    @objc func handlePan(_ panGesture: UIPanGestureRecognizer) {
        progressView(panGesture)
    }
    
    func progressView(_ gesture: UIPanGestureRecognizer) {
        
        let translate = gesture.translation(in: gesture.view)
        var percent   = 0.0
        switch direction {
            case .top:
                percent = -translate.y / gesture.view!.bounds.size.height
            case .bottom:
                percent = translate.y / gesture.view!.bounds.size.height
            case .right:
                percent = translate.x / gesture.view!.bounds.size.width
            case .left:
                percent = -translate.x / gesture.view!.bounds.size.width
        }
        
        switch gesture.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            (self.delegate as? CustomAdaptiveDelegate)?.interactor(interactionController)
            self.presentedViewController.dismiss(animated: true, completion: nil)
        case .changed:
            interactionController?.update(percent)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: gesture.view)
            interactionController?.completionSpeed = 0.999  // https://stackoverflow.com/a/42972283/1271826
            finishInteraction(percent, velocity: velocity)
            (self.delegate as? CustomAdaptiveDelegate)?.interactor(nil)
        default:
            break
        }
    }
    
    private func finishInteraction(_ percent: Double, velocity: CGPoint) {
        
        if percent > config.minimumScreenRatioToHide {
            interactionController?.finish()
        } else {
            interactionController?.cancel()
        }
    }
}
