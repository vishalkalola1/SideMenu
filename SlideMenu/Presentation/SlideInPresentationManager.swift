

import UIKit

struct SideMenuConfiguration {
    var minimumScreenRatioToHide: CGFloat = 0.5
    var animationDuration: TimeInterval = 0.3
}

enum Direction {
    case top
    case bottom
    case left
    case right
    
    var edge: UIRectEdge {
        switch self {
            case .top:
                return .top
            case .bottom:
                return .bottom
            case .left:
                return .left
            case .right:
                return .right
        }
    }
}

final class SlideInPresentationManager: NSObject {
    
    // MARK: - Properties
    typealias Action = () -> ()
    private var edgeView: UIView
    private let presentAction: Action
    private var interactionController: UIPercentDrivenInteractiveTransition? = nil
    private let config = SideMenuConfiguration()
    private let direction: Direction
    
    init(direction: Direction = .bottom,
         edgeView: UIView,
         presentAction: @escaping Action) {
        self.edgeView = edgeView
        self.presentAction = presentAction
        self.direction = direction
        super.init()
        bindGesture()
    }
    
    func bindGesture() {
        let edgePanRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                 action: #selector(handleEdgePan(_:)))
        edgePanRecognizer.edges = direction.edge
        edgePanRecognizer.delegate = self
        edgeView.addGestureRecognizer(edgePanRecognizer)
    }
    
    @objc func handleEdgePan(_ gesture: UIPanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent   = translate.x / gesture.view!.bounds.size.width
        
        switch gesture.state {
            case .began:
                interactionController = UIPercentDrivenInteractiveTransition()
                presentAction()
            case .changed:
                interactionController?.update(percent)
            case .ended, .cancelled:
                let velocity = gesture.velocity(in: gesture.view)
                interactionController?.completionSpeed = 0.999  // https://stackoverflow.com/a/42972283/1271826
                if (percent > config.minimumScreenRatioToHide && velocity.x == 0) || velocity.x > 0 {
                    interactionController?.finish()
                } else {
                    interactionController?.cancel()
                }
                interactionController = nil
            default:
                break
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                                   presenting: presenting,
                                                                   delegate: self,
                                                                   direction: direction)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(transitionType: .presenting, direction: direction)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(transitionType: .dismissing, direction: direction)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SlideInPresentationManager: CustomAdaptiveDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func interactor(_ interactionController: UIPercentDrivenInteractiveTransition?) {
        self.interactionController = interactionController
    }
}

extension SlideInPresentationManager: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


protocol CustomAdaptiveDelegate: UIAdaptivePresentationControllerDelegate {
    func interactor(_ interactionController: UIPercentDrivenInteractiveTransition?)
}
