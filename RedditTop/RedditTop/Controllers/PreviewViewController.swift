//
//  PreviewViewController.swift
//  RedditTop
//
//  Created by Alexander Grischenko on 3/28/18.
//  Copyright © 2018 grider. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    public var entity: EntityModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = entity.title
    }

    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
