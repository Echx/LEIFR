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
    
    override func viewDidLoad() {
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
    }
}

extension LFPlaybackCalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        showAnimationButton.isHidden = false
        selectedDate = date
    }
}
