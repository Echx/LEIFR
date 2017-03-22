//
//  LFMyTrackViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 17/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFMyTrackViewController: LFViewController {
	
	fileprivate let amountToLoad = 10
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var titleLabel: UILabel!
	
	fileprivate var paths = [LFPath]()
	fileprivate var shouldHideLoadMoreButton = false
	fileprivate var isLoading = false;
	
	enum Section: Int {
		case tracks = 0
		case loadMoreButton
		case count
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		configure(tableView: tableView)
		loadDatabasePaths()
		loadDatabasePathCount()
    }
	
	fileprivate func loadDatabasePathCount() {
		LFDatabaseManager.shared.getPathCount(completion: {
			count in
			self.titleLabel.text = "My Tracks (\(count))"
		})
	}
	
	fileprivate func pathCount() -> Int {
		return paths.count
	}
	
	fileprivate func path(at indexPath: IndexPath) -> LFPath {
		return paths[indexPath.row]
	}
	
	fileprivate func removePath(at indexPath: IndexPath) {
		paths.remove(at: indexPath.row)
	}

	fileprivate func loadDatabasePaths() {
		guard !isLoading else {
			return
		}
		
		isLoading = true
		
		let from = paths.isEmpty ? nil : paths.last!.identifier! - 1
		LFDatabaseManager.shared.getPaths(from: from, amount: amountToLoad, completion: {
			incomingPaths in
			if !incomingPaths.isEmpty{
				let originalCount = self.pathCount()
				var indexPaths = [IndexPath]()
				for row in originalCount..<originalCount + incomingPaths.count {
					indexPaths.append(IndexPath(row: row, section: 0))
				}
				self.paths.append(contentsOf: incomingPaths)
				self.tableView.insertRows(at: indexPaths, with: .automatic)
			}
			
			if incomingPaths.count < self.amountToLoad {
				self.shouldHideLoadMoreButton = true
				let indexSet = IndexSet(integer: 1)
				self.tableView.deleteSections(indexSet, with: .automatic)
			}
			
			self.isLoading = false
		})
	}
	
	fileprivate func deletePath(at indexPath: IndexPath) {
		let path = self.path(at: indexPath)
		path.delete(completion: {
			error in
			DispatchQueue.main.async {
				if error == nil {
					self.removePath(at: indexPath)
					var indexPaths = [IndexPath]()
					for row in indexPath.row..<self.pathCount() {
						indexPaths.append(IndexPath(row: row, section: 0))
					}
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
						self.tableView.reloadRows(at: indexPaths, with: .fade)
					})
					
					self.loadDatabasePathCount()
				}
			}
		})
	}
	
	fileprivate var documentInteractionController: UIDocumentInteractionController?
	fileprivate func sharePath(at indexPath: IndexPath) {
		let path = self.path(at: indexPath)
		let filePath = NSTemporaryDirectory() + "Path-\(path.identifier!).leifr"
		let success = NSKeyedArchiver.archiveRootObject(path, toFile: filePath)
		if success {
			let documentController = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
			documentController.delegate = self
			documentController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
			self.documentInteractionController = documentController
		}
	}
}

extension LFMyTrackViewController: UIDocumentInteractionControllerDelegate {
	func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
		if let url = controller.url {
			try! FileManager.default.removeItem(at: url)
		}
	}
}

extension LFMyTrackViewController: UITableViewDataSource {
	
	fileprivate func configure(tableView: UITableView) {
		let topBarHeight: CGFloat = 84
		let bottomBarHeight: CGFloat = 64
		tableView.contentInset = UIEdgeInsets(top: topBarHeight, left: 0, bottom: bottomBarHeight, right: 0)
		tableView.scrollIndicatorInsets = UIEdgeInsets(top: topBarHeight, left: 0, bottom: bottomBarHeight, right: 0)
		tableView.backgroundColor = self.view.backgroundColor
		tableView.rowHeight = 80
		
		let label = UILabel()
		label.text = "No Track Available".uppercased()
		label.textColor = UIColor.white
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 15, weight: 0.01)
		tableView.backgroundView = label
		
		registerCells(for: tableView)
	}
	
	fileprivate func registerCells(for tableView: UITableView) {
		LFTrackTableViewCell.registerCell(tableView: tableView, reuseIdentifier: LFTrackTableViewCell.identifier)
		LFButtonCell.registerCell(tableView: tableView, reuseIdentifier: LFButtonCell.identifier)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return shouldHideLoadMoreButton ? Section.loadMoreButton.rawValue : Section.count.rawValue
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableView.backgroundView?.isHidden = pathCount() != 0
		return section == Section.tracks.rawValue ? pathCount() : 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == Section.tracks.rawValue {
			let cell = tableView.dequeueReusableCell(withIdentifier: LFTrackTableViewCell.identifier, for: indexPath) as! LFTrackTableViewCell
			cell.indexPath = indexPath
			cell.path = self.path(at: indexPath)
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: LFButtonCell.identifier, for: indexPath) as! LFButtonCell
			cell.buttonTitleLabel.text = "Load More"
			return cell
		}
	}
}

extension LFMyTrackViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let shareRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Share", handler:{
			_, indexpath in
			self.sharePath(at: indexPath)
		})
		shareRowAction.backgroundColor = UIColor(hexString: "#3498db");
		
		let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{
			_, indexpath in
			self.deletePath(at: indexPath)
		})
		deleteRowAction.backgroundColor = UIColor(hexString: "#e74c3c");
		
		return [deleteRowAction, shareRowAction];
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section == Section.tracks.rawValue
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == Section.tracks.rawValue {
			let path = self.path(at: indexPath)
            let pathsPlayingManager = LFPathsPlayingManager.shared
            pathsPlayingManager.clearAllPaths()
            pathsPlayingManager.addPaths([path])
            
            // refactoring needed for the button index
            LFHoverTabViewController.defaultInstance.clickButton(atIndex: 1)
            LFHoverTabBaseController.defaultInstance.switchToPage(index: 1)
            
            self.dismissWithAnimation()
		} else {
			self.loadDatabasePaths()
		}
	}
}
