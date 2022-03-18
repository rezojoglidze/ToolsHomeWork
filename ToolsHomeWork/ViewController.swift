//
//  ViewController.swift
//  ToolsHomeWork
//
//  Created by Igor Kupreev on 9/30/18.
//  Copyright © 2018 Igor Kupreev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapStartButton(sender: Any) {
        let board = UIStoryboard.init(name: "Time", bundle: nil)
        if let vc = board.instantiateInitialViewController(){
            present(vc, animated: true, completion: nil)
        }
    }
}



