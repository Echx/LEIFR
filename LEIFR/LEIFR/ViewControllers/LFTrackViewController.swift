//
//  LFTrackViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 17/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFTrackViewController: LFViewController {
	
	fileprivate let amountToLoad = 10
	
	@IBOutlet var tableView: UITableView!
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
		loadPaths()
    }

	fileprivate func loadPaths() {
		guard !isLoading else {
			return
		}
		
		isLoading = true
		
		let from = paths.isEmpty ? nil : paths.last!.identifier! - 1
		LFDatabaseManager.shared.getPaths(from: from, amount: amountToLoad, completion: {
			paths in
			if !paths.isEmpty{
				let originalCount = self.paths.count
				var indexPaths = [IndexPath]()
				for row in originalCount..<originalCount + paths.count {
					indexPaths.append(IndexPath(row: row, section: 0))
				}
				self.paths.append(contentsOf: paths)
				self.tableView.insertRows(at: indexPaths, with: .automatic)
			}
			
			if paths.count < self.amountToLoad {
				self.shouldHideLoadMoreButton = true
				let indexSet = IndexSet(integer: 1)
				self.tableView.deleteSections(indexSet, with: .automatic)
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
		return section == Section.tracks.rawValue ? paths.count : 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == Section.tracks.rawValue {
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
		if indexPath.section == Section.tracks.rawValue {
			let path = paths[indexPath.row]
			print(path.points)
		} else {
			self.loadPaths()
		}
	}
}
