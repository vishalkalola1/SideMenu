//
//  ViewController.swift
//  Non-Interactive Transition
//
//  Created by Karan Pal on 02/02/21.
//

import UIKit

class ViewController: UIViewController {

    var slideInPresentationDelegate: SlideInPresentationManager!
    var direction: Direction = .left
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDelegate()
    }
    
    func updateDelegate() {
        slideInPresentationDelegate = SlideInPresentationManager(direction: direction, edgeView: self.view, presentAction: { [weak self] in
            self?.presentSideMenu()
        })
    }
    
    @IBAction func presentClicked(_ sender: Any) {
        presentSideMenu()
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                direction = .left
            case 1:
                direction = .right
            case 2:
                direction = .top
            case 3:
                direction = .bottom
            default:
                direction = .left
        }
        updateDelegate()
    }
    
    func presentSideMenu() {
        let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        secondVC.modalPresentationStyle = .custom
        secondVC.transitioningDelegate = slideInPresentationDelegate
        self.present(secondVC, animated: true, completion: nil)
    }
}


