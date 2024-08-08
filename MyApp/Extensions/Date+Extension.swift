import Foundation

extension Date {
    func listDateStringFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    func dayAfter() -> Date? {
        Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    func dayBefore() -> Date? {
        Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func titleFormat() -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            return dayAndMonthListTitleFormat()
        }
    }
        
    func dayAndMonthListTitleFormat() -> String {
        let day = Calendar.current.component(.day, from: self)
        
        // Handle ordinal suffix
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let dayString = numberFormatter.string(from: NSNumber(value: day))!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let monthString = dateFormatter.string(from: self)
        
        return "\(monthString) \(dayString)"
    }

    // Not sure if i need this, might delete
    func dateStringDisplayFormat() -> String {
        let calendar = Calendar.current

        let currentYear = calendar.component(.year, from: Date())
        let dateYear = calendar.component(.year, from: self)

        let dateFormatter = DateFormatter()
        
        if currentYear == dateYear {
            dateFormatter.dateFormat = "dd MMM"
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy"
        }

        return dateFormatter.string(from: self)
    }

}
