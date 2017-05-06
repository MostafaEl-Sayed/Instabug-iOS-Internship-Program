import UIKit
import XCTest


//The goal of the task is to be able to create some Bug objects, add them to an Application, then use findBugs(state:timeRange:) to filter those bugs


class Bug {
    enum State {
        case open
        case closed
    }
    
    let state: State
    let timestamp: Date
    let comment: String
    
    init(state: State, timestamp: Date, comment: String) {
        // To be implemented
        self.state = state
        self.timestamp = timestamp
        self.comment = comment
        //super.init()
    }
    
    init(jsonString: String) throws {
        // To be implemented
        guard let data = jsonString.data(using: .utf8) else {
            throw handelError.jsonError
        }
        
        guard let bugData = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
            throw handelError.jsonError
        }
            guard let comment = bugData["comment"] as? String,
                let statet = bugData["state"] as? String,
                let timestamp = bugData["timestamp"] as? Int
                else {
                    throw handelError.keyNotFound
            }
            if statet == "open"{
                self.state = .open
            }else{
                self.state = .closed
            }
            self.comment = comment
            self.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

enum handelError: Error {
    case jsonError
    case keyNotFound
}
enum TimeRange {
    case pastDay
    case pastWeek
    case pastMonth
}

class Application {
    var bugs: [Bug]
    
    init(bugs: [Bug]) {
        self.bugs = bugs
    }
    
    func findBugs(state: Bug.State?, timeRange: TimeRange) -> [Bug] {
        // To be implemented
        var feachedBugs = [Bug]()
    
        var currentTimeRange:TimeRange?
        
        for bug in bugs {
            let calendar = Calendar.current
            let currentDate = Date()
            let startDate = calendar.ordinality(of: .day, in: .era, for: bug.timestamp)
            let endDate = calendar.ordinality(of: .day, in: .era, for: currentDate)
            let days = endDate! - startDate!
            if days == 0 {
                currentTimeRange =  TimeRange.pastDay
            }
            else if days <= 7 {
                currentTimeRange =  TimeRange.pastWeek
            }else{
                currentTimeRange =  TimeRange.pastMonth
            }
    
            if timeRange != currentTimeRange  {
                continue
            }
            if bug.state != state {
                continue
            }
            feachedBugs.append(bug)
            }

      return feachedBugs
    }
}

class UnitTests : XCTestCase {
    lazy var bugs: [Bug] = { // [bug1, bug2, bug3] // With normal Initialization
        var date26HoursAgo = Date()
        date26HoursAgo.addTimeInterval(-1 * (26 * 60 * 60))
        
        var date2WeeksAgo = Date()
        date2WeeksAgo.addTimeInterval(-1 * (14 * 24 * 60 * 60))
        
        let bug1 = Bug(state: .open, timestamp: Date(), comment: "Bug 1")
        let bug2 = Bug(state: .open, timestamp: date26HoursAgo, comment: "Bug 2")
        let bug3 = Bug(state: .closed, timestamp: date2WeeksAgo, comment: "Bug 2")

        return [bug1, bug2, bug3]
    }()
    
    lazy var application: Application = { // application // With normal Initialization
        let application = Application(bugs: self.bugs)
        return application
    }()

    func testFindOpenBugsInThePastDay() {
        let bugs = application.findBugs(state: .open, timeRange: .pastDay)
        bugs.count
        bugs[0].comment
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
        XCTAssertEqual(bugs[0].comment, "Bug 1", "Invalid bug order")
    
    }

    func testFindClosedBugsInThePastMonth() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastMonth)
        bugs.count
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
    }
//
    func testFindClosedBugsInThePastWeek() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastWeek)
        bugs.count
        XCTAssertTrue(bugs.count == 0, "Invalid number of bugs")
    }
    
    func testInitializeBugWithJSON() {
        do {
            let json = "{\"state\": \"open\",\"timestamp\": 1493393946,\"comment\": \"Bug via JSON\"}"

            let bug = try Bug(jsonString: json)
            
            
            XCTAssertEqual(bug.comment, "Bug via JSON")
            XCTAssertEqual(bug.state, .open)
            XCTAssertEqual(bug.timestamp, Date(timeIntervalSince1970: 1493393946))
        } catch {
            print(error)
        }
    }
}

class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(String(describing: testCase.name)), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.shared()
center.addTestObserver(observer)

TestRunner().runTests(testClass: UnitTests.self)
