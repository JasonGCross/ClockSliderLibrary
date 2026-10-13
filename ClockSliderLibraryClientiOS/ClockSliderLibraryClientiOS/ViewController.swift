//
//  ViewController.swift
//  ClockSliderLibraryClientiOS
//
//  Created by Jason Cross on 2024-10-27.
//

import UIKit
import ClockSliderLibrary

class ViewController: UIViewController {

    @IBOutlet var customViewContainer: UIView!
    var timeRangeSliderControl: TimeRangeSliderControl!
    let ringWidth: CGFloat = 44.0
    
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change these 2 values to change the UI
        let sliderStartAngle = 0 * Double.pi
        let sliderEndAngle = (1.0) * Double.pi
        let clockType = ClockType.twelveHourClock

        // all these are calculated based on above
        let startMinutes = Int(clockType.minutesFromAngle(sliderStartAngle))
        let endMinutes = Int(clockType.minutesFromAngle(sliderEndAngle))
        let sliderStartTime =  TimeOfDayModel.timeModelFromMinutes(startMinutes)
        let sliderEndTime = TimeOfDayModel.timeModelFromMinutes(endMinutes)
        
        timeRangeSliderControl = TimeRangeSliderControl(
            _frame: customViewContainer.bounds,
            _ringWidth: ringWidth,
            _clockType: clockType,
            _timeOfDay: TimeOfDayModel.now,
            _sliderStartTime: sliderStartTime,
            _sliderEndTime: sliderEndTime)
        self.customViewContainer.addSubview(timeRangeSliderControl)
        
        timeRangeSliderControl.clockContainerBackgroundColor = .systemGray
        timeRangeSliderControl.clockFaceBackgroundColor = .white
        timeRangeSliderControl.clockFaceHandsColor = .black
        timeRangeSliderControl.clockFaceTickMarkColor = .black
        timeRangeSliderControl.clockFaceTextColor = .black
        
        let startColor = UIColor(red: 0.2, green: 0.2, blue: 1.0, alpha: 1.0)
        timeRangeSliderControl.firstDayGradientStartColor = startColor
        timeRangeSliderControl.startThumbColor = startColor
        
        let finishColor = UIColor.systemPink
        timeRangeSliderControl.firstDayGradientFinishColor = finishColor
        timeRangeSliderControl.finishThumbColor = finishColor
        
        timeRangeSliderControl.isUserInteractionEnabled = true
        
        timeRangeSliderControl.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: UIControl.Event.allTouchEvents)
    }

    //MARK:- Actions
    @objc func sliderValueChanged(sender: TimeRangeSliderControl) {
        guard let control = sender.underlyingTimeRangeSliderControl else {
            return
        }
        
        let startTime = control.getStartTime()
        let finishTime = control.getFinishTime()
        let durationInMinutes = finishTime.totalMinutes - startTime.totalMinutes
        let durationModel = TimeOfDayModel.timeModelFromMinutes(durationInMinutes)
        
        let startTimeDate = startTime.getFoundationDateWithOnlyHoursAndMinutes()
        let finishTimeDate = finishTime.getFoundationDateWithOnlyHoursAndMinutes()
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        
        self.startTimeLabel.text = dateFormatter.string(from: startTimeDate)
        self.endTimeLabel.text = dateFormatter.string(from: finishTimeDate)
        self.durationLabel.text = durationModel.debugDescription
    }
}

