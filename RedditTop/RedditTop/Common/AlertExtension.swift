//
//  AlertExtension.swift
//  RedditTop
//
//  Created by Alexander Grischenko on 3/29/18.
//  Copyright © 2018 grider. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func showAlertWithOkButton(text: String) {
        let alertController = UIAlertController.init(title: text,
                                                     message: nil,
                                                     preferredStyle: .alert)
        let alertAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

