//
//  LFSettingViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFSettingViewController: LFViewController {

	@IBOutlet weak var tableView: UITableView!
	
	enum Section: Int {
		case reconstructDatabase = 0
		case count
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
	
	func configureTableView() {
		tableView.estimatedRowHeight = 100
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.contentInset = UIEdgeInsetsMake(84, 0, 64, 0)
		tableView.dataSource = self
		tableView.delegate = self
		
		registerCells()
	}
	
	func registerCells() {
		LFButtonCell.registerCell(tableView: self.tableView, reuseIdentifier: LFButtonCell.identifier)
	}
}

// MARK: IBActions

extension LFSettingViewController {
	@IBAction func reconstructDatabase(sender: Any?) {
		let loadingController = LFLoadingViewController.controllerFromStoryboard() as! LFLoadingViewController
		loadingController.completionNotificationName = LFNotification.databaseReconstructionComplete
		loadingController.progressNotificationName = LFNotification.databaseReconstructionProgress
		
		self.present(loadingController, animated: true, completion: {
			DispatchQueue(label: "DatabaseQueue").async {
				LFCachedDatabaseManager.shared.reconstructDatabase()
			}
		})
	}
	
	@IBAction func flushPoints(sender: Any?) {
		DispatchQueue(label: "DatabaseQueue").async {
			LFGeoRecordManager.shared.flushPoints()
		}
	}
}

extension LFSettingViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFSettingViewController") as! LFViewController
		controller.modalTransitionStyle = .flipHorizontal
		return controller
	}
}

extension LFSettingViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case Section.reconstructDatabase.rawValue:
			indexPath.row == 0 ? self.reconstructDatabase(sender: nil) : self.flushPoints(sender: nil)
		default:
			self.dismissWithAnimation()
		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.count.rawValue
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == Section.reconstructDatabase.rawValue ? 2 : 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LFButtonCell.identifier, for: indexPath) as! LFButtonCell
		
		if indexPath.section == Section.reconstructDatabase.rawValue {
			if indexPath.row == 0 {
				cell.buttonTitleLabel.text = "Reconstruct Database"
			} else {
				cell.buttonTitleLabel.text = "Flush"
			}
		}
		
		return cell
	}
}
