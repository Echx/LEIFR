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

    override func viewDidLoad() {
        super.viewDidLoad()
		self.configure(tableView: tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
		return 5
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LFTrackTableViewCell.identifier, for: indexPath) as! LFTrackTableViewCell
		cell.indexPath = indexPath
		return cell
	}
}
