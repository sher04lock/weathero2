import Foundation

let INCOMING_DATE_FORMAT = "yyyy-MM-dd"
let DISPLAY_DATE_FORMAT = "EEEE MMM d, YYYY"
let CELCIUS_DEGREE = "°C"



class Utils {
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DISPLAY_DATE_FORMAT
        return formatter.string(from: date)
    }
    
    static func formatNumber(_ number: Double?) -> String {
        if (number == nil) {
            return "-"
        }
        
        return NSString(format: "%.1f", number!) as String
    }
    
    static func parseDate(dateString: String, dateFormat: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: dateString)
    }
}


