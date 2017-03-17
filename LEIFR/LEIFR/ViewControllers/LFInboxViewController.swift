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
		label.font = UIFont.systemFont(ofSize: 15, weight: 0.01)
		tableView.backgroundView = label
		
		tableView.backgroundColor = UIColor(hexString: "#D4C6BF")
		
		registerCells(for: tableView)
	}
	
	fileprivate func registerCells(for tableView: UITableView) {
		LFInboxTableViewCell.registerCell(tableView: tableView, reuseIdentifier: LFInboxTableViewCell.identifier)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return incomingPaths.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LFInboxTableViewCell.identifier, for: indexPath) as! LFInboxTableViewCell
		cell.indexPath = indexPath
		cell.incomingPath = incomingPaths[indexPath.row]
		return cell
	}
}
