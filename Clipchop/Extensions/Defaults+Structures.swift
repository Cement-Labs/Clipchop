//
//  Defaults+Structures.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

enum HistoryPreservationTime: Defaults.Serializable {
    case forever
    
    case minute(UInt)
    case hour(UInt)
    case day(UInt)
    case month(UInt)
    case year(UInt)
    
    enum Period: String, Defaults.Serializable {
        case forever = "forever"
        
        case minute = "minute"
        case hour = "hour"
        case day = "day"
        case month = "month"
        case year = "year"
        
        func withTime(_ time: UInt) -> HistoryPreservationTime {
            switch self {
            case .forever:  .forever
            case .minute:   .minute(time)
            case .hour:     .hour(time)
            case .day:      .day(time)
            case .month:    .month(time)
            case .year:     .year(time)
            }
        }
    }
    
    var period: Period {
        switch self {
        case .forever:      .forever
        case .minute(_):    .minute
        case .hour(_):      .hour
        case .day(_):       .day
        case .month(_):     .month
        case .year(_):      .year
        }
    }
    
    struct Bridge: Defaults.Bridge {
        typealias Value = HistoryPreservationTime
        typealias Serializable = (Period, UInt)
        
        func serialize(_ value: HistoryPreservationTime?) -> (HistoryPreservationTime.Period, UInt)? {
            switch value ?? .forever {
            case .forever:
                (.forever, 0)
            case .minute(let time):
                (.minute, time)
            case .hour(let time):
                (.hour, time)
            case .day(let time):
                (.day, time)
            case .month(let time):
                (.month, time)
            case .year(let time):
                (.year, time)
            }
        }
        
        func deserialize(_ object: (HistoryPreservationTime.Period, UInt)?) -> HistoryPreservationTime? {
            if let object {
                return switch object.0 {
                case .forever:  .forever
                case .minute:   .minute(object.1)
                case .hour:     .hour(object.1)
                case .day:      .day(object.1)
                case .month:    .month(object.1)
                case .year:     .year(object.1)
                }
            } else {
                return .forever
            }
        }
    }
    
    static let bridge = Bridge()
}
