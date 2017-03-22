//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

struct Duration {
    var years: Double = 0
    var weeks: Double = 0
    var months: Double = 0
    var days: Double = 0
    var hours: Double = 0
    var minutes: Double = 0
    var seconds: Double = 0
    
    /// Returns `m:ss` if less than one hour, else returns `h:mm:ss`.
    var humanReadableString: String {
        let hours = Int(largerDenominationsToHours + self.hours)
        return hours == 0 ? String(format: "\(Int(minutes)):%02d", Int(seconds)) :
            String(format: "\(hours):%02d:%02d", Int(minutes), Int(seconds))
    }
    
    // Assume 365 days/year, 30 days/month
    private var largerDenominationsToHours: Double {
        return years * 8760 + weeks * 168 + months * 720 + days * 24
    }
}
