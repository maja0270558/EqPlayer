//
//  EQDateFormatter.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/31.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
struct EQDateFormatter {
  
  let dateFormatter: DateFormatter
  
  init(dateFormat: String = "yyyy-MM-dd HH:mm") {
    
    self.dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    self.dateFormatter.dateFormat = dateFormat
  }
  
  func dateWithUnitTime(time: Double) -> String {
    
    let date = Date(timeIntervalSince1970: time/1000)
    //Specify your format that you want
    
    
    return dateFormatter.string(from: date)
  }
}
