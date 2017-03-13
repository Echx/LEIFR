//
//  LFStatisticsCollectionViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 13/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFStatisticsCollectionViewController: UICollectionViewController {

	fileprivate let topBarHeight: CGFloat = 80
	fileprivate let bottomBarHeight: CGFloat = 60
	fileprivate let spacing: CGFloat = 20
	fileprivate let marginHorizontal: CGFloat = 20
	fileprivate var continents = [
		("wd", "World", UIImage(named: "world-map"), "#F2F3F4", "#ABB2B9", [LFCachedCountry](), 0, 0),
		("as", "Asia", UIImage(named: "as-map"), "#FADBD8", "#EC7063", [LFCachedCountry](), 0, 0),
		("eu", "Europe", UIImage(named: "eu-map"), "#D4E6F1", "#5499C7", [LFCachedCountry](), 0, 0),
		("na", "North America", UIImage(named: "na-map"), "#D5F5E3", "#58D68D", [LFCachedCountry](), 0, 0),
		("sa", "South America", UIImage(named: "sa-map"), "#EBDEF0", "#AF7AC5", [LFCachedCountry](), 0, 0),
		("oc", "Oceania", UIImage(named: "oc-map"), "#FCF3CF", "#F4D03F", [LFCachedCountry](), 0, 0),
		("af", "Africa", UIImage(named: "af-map"), "#F6DDCC", "#DC7633", [LFCachedCountry](), 0, 0)
	]
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		
		self.collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        self.registerCells()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.loadCountries()
	}
	
	private func loadCountries() {
		let manager = LFCachedDatabaseManager.shared
		for (index, continent) in continents.enumerated() {
			var countries: [LFCachedCountry]
			if index == 0 {
				countries = manager.getAllCountries()
			} else {
				countries = manager.getCountriesFromContinent(continentCode: continent.0)
			}
			
			continents[index].5 = countries
			continents[index].6 = countries.count
			continents[index].7 = countries.filter({ return $0.visited }).count
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	private func registerCells() {
		LFStatisticsCollectionViewCell.registerCell(collectionView: self.collectionView!, reuseIdentifier: LFStatisticsCollectionViewCell.identifier)
	}

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return continents.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LFStatisticsCollectionViewCell.identifier, for: indexPath) as! LFStatisticsCollectionViewCell
		
		let continent = continents[indexPath.row]
		
		cell.label.text = continent.1
		cell.imageView.image = continent.2
		cell.configureSecondaryColor(color: UIColor(hexString: continent.3))
		cell.configurePrimaryColor(color: UIColor(hexString: continent.4))
		cell.updateProgress(done: continent.7, all: continent.6)
		
        return cell
    }

    // MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let controller = LFFlagViewController.defaultControllerFromStoryboard() as! LFFlagViewController
		controller.countries = [continents[indexPath.row].5]
		self.present(controller, animated: true, completion: nil)
	}

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}

extension LFStatisticsCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	private func itemSize() -> CGSize {
		let height = UIScreen.main.bounds.height - topBarHeight - bottomBarHeight - 2 * spacing
		let width = UIScreen.main.bounds.width - 2 * spacing - 2 * marginHorizontal
		return CGSize(width: width, height: height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return self.itemSize()
	}
}
