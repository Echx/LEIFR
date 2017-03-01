//
//  LFStatisticsViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFStatisticsViewController: LFViewController {

	@IBOutlet weak var tableView: UITableView!
	
	enum Section: Int {
		case continents = 0
		case settings
		case count
	}
	
	enum Continent: Int {
		case all = 0
		case asia
		case europe
		case northAmerica
		case southAmerica
		case oceania
		case africa
		case antarctica
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

extension LFStatisticsViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFStatisticsViewController") as! LFViewController
		
		return controller
	}
}

extension LFStatisticsViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case Section.continents.rawValue:
			let controller = LFFlagViewController.defaultControllerFromStoryboard() as! LFFlagViewController
			let countries = [
				LFCachedDatabaseManager.shared.getCountriesFromContinent(continentCode: "AS"),
				LFCachedDatabaseManager.shared.getCountriesFromContinent(continentCode: "EU"),
				LFCachedDatabaseManager.shared.getCountriesFromContinent(continentCode: "NA"),
				LFCachedDatabaseManager.shared.getCountriesFromContinent(continentCode: "SA"),
				LFCachedDatabaseManager.shared.getCountriesFromContinent(continentCode: "OC"),
				LFCachedDatabaseManager.shared.getCountriesFromContinent(continentCode: "AF")
			];
			
			
			controller.countries = countries
			self.present(controller, animated: true, completion: nil)
			
		default:
			let settingViewController = LFSettingViewController.controllerFromStoryboard()
			self.present(settingViewController, animated: true, completion: nil)
		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.count.rawValue
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case Section.continents.rawValue:
			return 3//Continent.count.rawValue
		default:
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LFButtonCell.identifier, for: indexPath) as! LFButtonCell
		
		switch indexPath.section {
		case Section.continents.rawValue:
			switch indexPath.row {
			case Continent.all.rawValue:
				cell.buttonTitleLabel.text = "All Countries"
			case Continent.asia.rawValue:
				cell.buttonTitleLabel.text = "Asia"
			case Continent.europe.rawValue:
				cell.buttonTitleLabel.text = "Europe"
			case Continent.northAmerica.rawValue:
				cell.buttonTitleLabel.text = "North America"
			case Continent.southAmerica.rawValue:
				cell.buttonTitleLabel.text = "South America"
			case Continent.oceania.rawValue:
				cell.buttonTitleLabel.text = "Oceania"
			case Continent.africa.rawValue:
				cell.buttonTitleLabel.text = "Africa"
			case Continent.antarctica.rawValue:
				cell.buttonTitleLabel.text = "Antarctica"
			default:
				print("Not suppose to be here")
			}
			
		default:
			cell.buttonTitleLabel.text = "Settings"
		}
		
		return cell
	}
}
