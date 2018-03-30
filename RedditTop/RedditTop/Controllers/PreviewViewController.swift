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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imageViews: [UIImageView] = []
    var constraintHeight: NSLayoutConstraint? = nil
    var constraintWidth: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = entity.title
        self.prepareImages()
    }

    func prepareImages() {
        var count: Int = 0
        var hConstraints: String = "H:|"
        var views: [String: Any] = [:]
        var previousView: UIImageView? = nil

        for imageUrl in entity.images! {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            ImageService.getImage(forURL: imageUrl, completion: { (image) in
                imageView.image = image
            })
            contentView.addSubview(imageView)
            imageViews.append(imageView)
            
            var viewName = "view\(count)"
            views[viewName] = imageView
            
            if previousView != nil {
                viewName += "(==view\(count-1))"
            }
            
            hConstraints += "-0-[\(viewName)]"
            
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[\(viewName)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            contentView.addConstraints(constraints)
            
            previousView = imageView
            count += 1
        }
        
        hConstraints += "-0-|"
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: hConstraints, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        contentView.addConstraints(constraints)
        
        constraintHeight = NSLayoutConstraint.init(item: previousView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: scrollView.frame.size.height);
        constraintWidth = NSLayoutConstraint.init(item: previousView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: scrollView.frame.size.width);

        previousView?.addConstraints([constraintHeight!, constraintWidth!])
        
        pageControl.numberOfPages = count
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.constraintHeight?.constant = scrollView.frame.size.height
        self.constraintWidth?.constant = scrollView.frame.size.width
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        let image: UIImage? = imageViews[pageControl.currentPage].image
        guard image != nil else {
            self.showAlertWithOkButton(text: "Cannot save")
            return
        }
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            self.showAlertWithOkButton(text: error!.localizedDescription)
        } else {
            self.showAlertWithOkButton(text: "Saved")
        }
    }

}

extension PreviewViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = lroundf(Float(scrollView.contentOffset.x / scrollView.frame.size.width))
    }
    
}
