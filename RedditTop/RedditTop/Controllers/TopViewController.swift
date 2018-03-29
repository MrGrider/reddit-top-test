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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadData(after: after)
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
        cell.lblPreviewAvailable?.isHidden = entity.images?.count == 0
        if entity.thumbnail != nil {
            // TODO: implement image loading
            cell.imgThumbnail?.image = UIImage(named: "icon-no-thumbnail")
        }
        return cell
    }
    
}

extension TopViewController {
    
    func loadData(after: String?) {
        if sessionTask != nil {
            sessionTask?.cancel()
        }
        
        sessionTask = WebService.getTopReddit(after: after, range: .all) { [weak self] (data, after, error) in
            guard let strongSelf = self else { return }

            strongSelf.after = after
            if error != nil {
                strongSelf.showErrorAlert(text: error!.localizedDescription)
            } else if data != nil {
                if strongSelf.after != nil {
                    strongSelf.entitiesList += data!
                } else {
                    strongSelf.entitiesList = data!
                }
                strongSelf.tableView.reloadData()
            } else {
                strongSelf.showErrorAlert(text: "Couldn't retrieve data")
            }
        }
    }
    
}

extension TopViewController: PreviewPresentorProtocol {
    
    func presentPreview(forCell cell: UITableViewCell) {
        let index = tableView.indexPath(for: cell)?.row
        let entity = entitiesList[index!]
        
        let previewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        previewController.entity = entity
        let navigationController = UINavigationController.init(rootViewController: previewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
}
