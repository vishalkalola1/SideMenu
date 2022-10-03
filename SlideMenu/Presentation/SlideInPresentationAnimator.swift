
import UIKit

final class SlideInPresentationAnimator: NSObject {
    
    enum TransitionType {
        case presenting
        case dismissing
    }
    
    let transitionType: TransitionType
    private let config = SideMenuConfiguration()
    private let direction: Direction
    
    init(transitionType: TransitionType, direction: Direction) {
        self.transitionType = transitionType
        self.direction = direction
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let key: UITransitionContextViewControllerKey = transitionType == .presenting ? .to : .from
        
        guard let controller = transitionContext.viewController(forKey: key) else { return }
        
        if transitionType == .presenting {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        var initialFrame: CGRect = .zero
        var finalFrame: CGRect = .zero
        
        switch direction {
            case .right:
                dismissedFrame.origin.x = presentedFrame.width
                initialFrame = transitionType == .presenting ? dismissedFrame : presentedFrame
                finalFrame = transitionType == .presenting ? presentedFrame : dismissedFrame
            case .left:
                dismissedFrame.origin.x = -presentedFrame.width
                initialFrame = transitionType == .presenting ? dismissedFrame : presentedFrame
                finalFrame = transitionType == .presenting ? presentedFrame : dismissedFrame
            case .top:
                dismissedFrame.origin.y = -presentedFrame.height
                initialFrame = transitionType == .presenting ? dismissedFrame : presentedFrame
                finalFrame = transitionType == .presenting ? presentedFrame : dismissedFrame
            case .bottom:
                dismissedFrame.origin.y = presentedFrame.height
                initialFrame = transitionType == .presenting ? dismissedFrame : presentedFrame
                finalFrame = transitionType == .presenting ? presentedFrame : dismissedFrame
        }
        
        controller.view.frame = initialFrame
        
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                controller.view.frame = finalFrame
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }
}
