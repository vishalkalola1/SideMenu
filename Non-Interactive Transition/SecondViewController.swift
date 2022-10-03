//
//  SecondViewController.swift
//  Non-Interactive Transition
//
//  Created by Karan Pal on 02/02/21.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismissClicked(_ sender: Any) {
        test()
    }
    
    @objc func handleTapDismission(recognizer: UIGestureRecognizer) {
        test()
    }
    
    func test() {
        dismiss(animated: true, completion: nil)
    }
}
