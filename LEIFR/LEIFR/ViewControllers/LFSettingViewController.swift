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
		tableView.rowHeight = 60
		tableView.contentInset = UIEdgeInsetsMake(84, 0, 64, 0)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.backgroundColor = Color.limeCyan
		
		registerCells()
	}
	
	func registerCells() {
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default-cell")
	}
}

// MARK: IBActions

extension LFSettingViewController {
	@IBAction func reconstructDatabase(sender: Any?) {
		DispatchQueue(label: "DatabaseQueue").async {
			LFCachedDatabaseManager.shared.reconstructDatabase()
		}
	}
}

extension LFSettingViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFSettingViewController") as! LFViewController
		
		return controller
	}
}

extension LFSettingViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		switch indexPath.row {
		case Section.reconstructDatabase.rawValue:
			self.reconstructDatabase(sender: nil)
		default:
			print("No action")
		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.count.rawValue
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "default-cell", for: indexPath)
		cell.textLabel?.text = "Reconstruct Database"
		return cell
	}
}
