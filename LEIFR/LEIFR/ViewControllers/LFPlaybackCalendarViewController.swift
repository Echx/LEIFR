//
//  LFPlaybackCalendarViewController.swift
//  LEIFR
//
//  Created by Lei Mingyu on 2/2/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import FSCalendar

class LFPlaybackCalendarViewController: LFViewController {
    @IBOutlet fileprivate weak var calendarView: FSCalendar!
    @IBOutlet fileprivate weak var showAnimationButton: UIButton!

    fileprivate var selectedDate: Date?
    var delegate: LFPlaybackCalendarDelagate?
    var availableDates = [(Date, Date)]()
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let cellIdentifier = "calendar-cell"
    
    override func viewDidLoad() {
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.register(FSCalendarCell.self, forCellReuseIdentifier: cellIdentifier)
        if selectedDate != nil {
            calendarView.select(selectedDate!)
        }
        
    }
    
    @IBAction func showAnimation() {
        if selectedDate != nil {
            delegate?.dateDidSelect(date: selectedDate!)
        }
        
        dismissWithAnimation()
    }
}

extension LFPlaybackCalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        showAnimationButton.isHidden = false
        selectedDate = date
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if gregorian.isDateInToday(date) {
            return UIColor.red
        }
        
        for dates in availableDates {
            if (dates.0...dates.1).contains(date) {
                return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            }
        }
        
        return UIColor.clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if gregorian.isDateInToday(date) {
            return UIColor.white
        }
        
        for dates in availableDates {
            if (dates.0...dates.1).contains(date) {
                return UIColor.white
            }
        }
        
        let currentMonth = gregorian.dateComponents([.month], from: calendar.currentPage)
        let dateMonth = gregorian.dateComponents([.month], from: date)
        if currentMonth == dateMonth {
            return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        } else {
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
}

protocol LFPlaybackCalendarDelagate {
    func dateDidSelect(date: Date)
}
