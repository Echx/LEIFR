//
//  LFInboxViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 18/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFInboxViewController: LFViewController {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var titleLabel: UILabel!
	
	fileprivate var incomingPaths = [LFIncomingPath]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        configure(tableView: self.tableView)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadPaths()
	}
	
	fileprivate func loadPaths() {
		incomingPaths = LFLocalFileManager.shared.getAllIncommingPaths()
		self.tableView.reloadData()
		self.titleLabel.text = "Inbox (\(incomingPaths.count))"
	}
	
	fileprivate func deletePath(at indexPath: IndexPath) {
		let incomingPath = incomingPaths[indexPath.row]
		incomingPath.delete()
		incomingPaths.remove(at: indexPath.row)
		var indexPaths = [IndexPath]()
		for row in indexPath.row..<self.incomingPaths.count {
			indexPaths.append(IndexPath(row: row, section: 0))
		}
		self.tableView.deleteRows(at: [indexPath], with: .automatic)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
			self.tableView.reloadRows(at: indexPaths, with: .fade)
		})
		
		self.titleLabel.text = "Inbox (\(self.incomingPaths.count))"
	}
	
	fileprivate var documentInteractionController: UIDocumentInteractionController?
    
	fileprivate func sharePath(at indexPath: IndexPath) {
		let url = incomingPaths[indexPath.row].url
		let documentController = UIDocumentInteractionController(url: URL(fileURLWithPath: url!))
		documentController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
		self.documentInteractionController = documentController
	}
}

extension LFInboxViewController: UITableViewDataSource {
	
	fileprivate func configure(tableView: UITableView) {
		let topBarHeight: CGFloat = 84
		let bottomBarHeight: CGFloat = 64
		tableView.contentInset = UIEdgeInsets(top: topBarHeight, left: 0, bottom: bottomBarHeight, right: 0)
		tableView.scrollIndicatorInsets = UIEdgeInsets(top: topBarHeight, left: 0, bottom: bottomBarHeight, right: 0)
		tableView.backgroundColor = self.view.backgroundColor
		tableView.rowHeight = 80
		
		let label = UILabel()
		label.text = "Inbox is empty".uppercased()
		label.textColor = UIColor.white
		label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(rawValue: 0.01))
		tableView.backgroundView = label
		
		tableView.backgroundColor = UIColor(hexString: "#E9DAD2")
		
		registerCells(for: tableView)
	}
	
	fileprivate func registerCells(for tableView: UITableView) {
		LFInboxTableViewCell.registerCell(tableView: tableView, reuseIdentifier: LFInboxTableViewCell.identifier)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableView.backgroundView?.isHidden = incomingPaths.count != 0
		return incomingPaths.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LFInboxTableViewCell.identifier, for: indexPath) as! LFInboxTableViewCell
		cell.indexPath = indexPath
		cell.incomingPath = incomingPaths[indexPath.row]
		return cell
	}
}

extension LFInboxViewController: UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = self.incomingPaths[indexPath.row].path
        let pathsPlayingManager = LFPathsPlayingManager.shared
        pathsPlayingManager.clearAllPaths()
        pathsPlayingManager.addPaths([path!])
        
        // refactoring needed for the button index
        LFHoverTabViewController.defaultInstance.clickButton(atIndex: 1)
        LFHoverTabBaseController.defaultInstance.switchToPage(index: 1)
        LFHoverTabBaseController.defaultInstance.openTabView()
        self.dismissWithAnimation()
    }
}
