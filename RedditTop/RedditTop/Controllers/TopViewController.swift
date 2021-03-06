//
//  ViewController.swift
//  RedditTop
//
//  Created by Alexander Grischenko on 3/28/18.
//  Copyright © 2018 grider. All rights reserved.
//

import UIKit

class TopViewController: UITableViewController {

    private var entitiesList: [EntityModel] = []
    private var after: String? = nil
    private var sessionTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40

        self.loadData(after: after)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if sessionTask != nil {
            sessionTask?.cancel()
        }
    }
    
    // MARK: - Table view data source
    
    let cellWithThumbnailIdentifier = "CellWithThumbnailIdentifier"
    let cellWithoutThumbnailIdentifier = "CellWithoutThumbnailIdentifier"

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entitiesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = entitiesList[indexPath.row]
        let cellIdentifier = (entity.thumbnail != nil) ? cellWithThumbnailIdentifier : cellWithoutThumbnailIdentifier
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TopTableViewCell
        cell.presentor = self
        
        cell.lblTitle.text = entity.title
        cell.lblDate.text = "\(Util.timeAgo(since: entity.timestamp)) by \(entity.author!)"
        cell.lblCommentsCount.text = String(format: NSLocalizedString("%d comments", comment: ""), entity.commentsCount)
        cell.lblPreviewAvailable?.isHidden = entity.images == nil 
        if entity.thumbnail != nil {
            cell.imgThumbnail?.image = UIImage(named: "icon-no-thumbnail")
            ImageService.getImage(forURL: entity.thumbnail!, completion: { (image) in
                cell.imgThumbnail?.image = image
            })
        }
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator .animate(alongsideTransition: { [weak self] (context) in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }, completion: nil)
    }
    
}

extension TopViewController {
    
    @objc func refresh() {
        self.loadData(after: nil)
    }
    
    func loadData(after: String?) {
        if sessionTask != nil {
            sessionTask?.cancel()
        }
        
        sessionTask = WebService.getTopReddit(after: after, range: .all) { [weak self] (data, after, error) in
            guard let strongSelf = self else { return }
            
            strongSelf.sessionTask = nil
            
            if strongSelf.refreshControl!.isRefreshing {
                strongSelf.refreshControl!.endRefreshing()
            }
            
            strongSelf.after = after
            if error != nil {
                strongSelf.showAlertWithOkButton(text: error!.localizedDescription)
            } else if data != nil {
                if strongSelf.after != nil {
                    strongSelf.entitiesList += data!
                } else {
                    strongSelf.entitiesList = data!
                }
                strongSelf.tableView.reloadData()
            }
        }
    }
    
}

extension TopViewController: PreviewPresentorProtocol {
    
    func presentPreview(forCell cell: UITableViewCell) {
        let index = tableView.indexPath(for: cell)?.row
        let entity = entitiesList[index!]
        guard entity.images != nil else { return }
        
        let previewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        previewController.entity = entity
        let navigationController = UINavigationController.init(rootViewController: previewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
}
