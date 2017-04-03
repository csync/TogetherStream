//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation

extension String {
    /// Parses string into a Duration struct based off the ISO 8601 duration standard.
    ///
    /// Durations are represented as "P[n]Y[n]M[n]DT[n]H[n]M[n]S" or "P[n]W"
    var duration: Duration? {
        // Construct regex
        let numbersPattern = "[0-9]+"
        let weekPattern = "(\(numbersPattern)W)"
        let datePattern = "(\(numbersPattern)Y)?(\(numbersPattern)M)?(\(numbersPattern)D)?"
        let timePattern = "T(\(numbersPattern)H)?(\(numbersPattern)M)?(\(numbersPattern)S)?"
        
        let isoDurationPattern = "P(?:\(weekPattern)|\(datePattern)(?:\(timePattern))?)"
        guard let expression = try? NSRegularExpression(pattern: isoDurationPattern, options: .caseInsensitive) else {return nil}
        
        // Attempt to match regex
        guard let match = expression.matches(in: self, options: .withoutAnchoringBounds, range: NSMakeRange(0, self.utf16.count)).first else {
            return nil
        }
        
        // Parse result into duration struct
        var duration = Duration()
        // Ranges will be: whole string, weeks, years, months, days, hours, minutes, seconds
        for index in 1..<match.numberOfRanges {
            // If part is not found, length is zero
            guard match.rangeAt(index).length != 0 else {continue}
            var timeSlice = (self as NSString).substring(with: match.rangeAt(index))
            // Remove trailing letter designator
            let _ = timeSlice.remove(at: timeSlice.index(before: timeSlice.endIndex))
            guard let time = Double(timeSlice) else {continue}
            // Modify struct based off current index
            switch index {
            case 1:
                duration.weeks = time
            case 2:
                duration.years = time
            case 3:
                duration.months = time
            case 4:
                duration.days = time
            case 5:
                duration.hours = time
            case 6:
                duration.minutes = time
            case 7:
                duration.seconds = time
            default:
                break
            }
        }
        return duration
    }
}
