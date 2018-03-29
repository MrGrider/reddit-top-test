//
//  TopTableViewCell.swift
//  RedditTop
//
//  Created by Alexander Grischenko on 3/28/18.
//  Copyright © 2018 grider. All rights reserved.
//

import UIKit

protocol PreviewPresentorProtocol: class {
    func presentPreview(forCell cell: UITableViewCell)
}

class TopTableViewCell: UITableViewCell {

    @IBOutlet weak var imgThumbnail: UIImageView?
    @IBOutlet weak var lblPreviewAvailable: UILabel?
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCommentsCount: UILabel!
    
    weak var presentor: PreviewPresentorProtocol?
    private let tapRecognizer = UITapGestureRecognizer()
    
    override func didMoveToSuperview() {
        guard imgThumbnail != nil else { return }
        guard presentor != nil else { return }
        imgThumbnail?.addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector(thumbnailTap(_:)))
    }
    
    @objc dynamic func thumbnailTap(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        presentor?.presentPreview(forCell: self)
    }
}

