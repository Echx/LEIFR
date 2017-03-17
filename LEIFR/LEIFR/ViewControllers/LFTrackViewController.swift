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
	fileprivate var shouldHideLoadMoreButton = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		configure(tableView: tableView)
		loadPaths()
    }

	fileprivate var isLoading = false;
	fileprivate func loadPaths() {
		guard !isLoading else {
			return
		}
		
		isLoading = true
		
		let from = paths.isEmpty ? nil : paths.last!.identifier! - 1
		LFDatabaseManager.shared.getPaths(from: from, amount: 10, completion: {
			paths in
			if paths.isEmpty {
				self.shouldHideLoadMoreButton = true
				self.tableView.reloadData()
			} else {
				self.paths.append(contentsOf: paths)
				self.tableView.reloadData()
			}
			self.isLoading = false
		})
	}
}

extension LFTrackViewController: UITableViewDataSource {
	
	fileprivate func configure(tableView: UITableView) {
		let topBarHeight: CGFloat = 84
		tableView.contentInset = UIEdgeInsets(top: topBarHeight, left: 0, bottom: 0, right: 0)
		tableView.scrollIndicatorInsets = UIEdgeInsets(top: topBarHeight, left: 0, bottom: 0, right: 0)
		tableView.backgroundColor = self.view.backgroundColor
		tableView.rowHeight = 80
		registerCells(for: tableView)
	}
	
	fileprivate func registerCells(for tableView: UITableView) {
		LFTrackTableViewCell.registerCell(tableView: tableView, reuseIdentifier: LFTrackTableViewCell.identifier)
		LFButtonCell.registerCell(tableView: tableView, reuseIdentifier: LFButtonCell.identifier)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return shouldHideLoadMoreButton ? 1 : 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? paths.count : 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: LFTrackTableViewCell.identifier, for: indexPath) as! LFTrackTableViewCell
			cell.indexPath = indexPath
			cell.path = paths[indexPath.row]
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: LFButtonCell.identifier, for: indexPath) as! LFButtonCell
			cell.buttonTitleLabel.text = "Load More"
			return cell
		}
	}
}

extension LFTrackViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			let path = paths[indexPath.row]
			print(path.points)
		} else {
			self.loadPaths()
		}
	}
}
