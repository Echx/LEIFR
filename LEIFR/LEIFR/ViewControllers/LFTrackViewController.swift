//
//  LFTrackViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 17/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFTrackViewController: LFViewController {
	
	@IBOutlet var tableView: UITableView!
	fileprivate var paths = [LFPath]()

    override func viewDidLoad() {
        super.viewDidLoad()
		configure(tableView: tableView)
		loadPaths()
    }

	fileprivate func loadPaths() {
		LFDatabaseManager.shared.getAllPaths(completion: {
			self.paths = $0
			self.tableView.reloadData()
		})
	}
}

extension LFTrackViewController: UITableViewDataSource {
	
	fileprivate func configure(tableView: UITableView) {
		let topBarHeight: CGFloat = 84
		let bottomBarHeight: CGFloat = 64
		tableView.contentInset = UIEdgeInsets(top: topBarHeight, left: 0, bottom: bottomBarHeight, right: 0)
		tableView.scrollIndicatorInsets = UIEdgeInsets(top: topBarHeight, left: 0, bottom: 0, right: 0)
		tableView.backgroundColor = self.view.backgroundColor
		tableView.rowHeight = 80
		registerCells(for: tableView)
	}
	
	fileprivate func registerCells(for tableView: UITableView) {
		LFTrackTableViewCell.registerCell(tableView: tableView, reuseIdentifier: LFTrackTableViewCell.identifier)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return paths.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LFTrackTableViewCell.identifier, for: indexPath) as! LFTrackTableViewCell
		cell.indexPath = indexPath
		cell.path = paths[indexPath.row]
		return cell
	}
}

extension LFTrackViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let path = paths[indexPath.row]
		print(path.points)
	}
}
