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
    
    override func viewDidLoad() {
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        
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

extension LFPlaybackCalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        showAnimationButton.isHidden = false
        selectedDate = date
    }
}

protocol LFPlaybackCalendarDelagate {
    func dateDidSelect(date: Date)
}
