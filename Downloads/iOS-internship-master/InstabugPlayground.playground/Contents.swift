import UIKit
import XCTest


//The goal of the task is to be able to create some Bug objects, add them to an Application, then use findBugs(state:timeRange:) to filter those bugs

enum jsonStringError: Error {
    case invalidJsonFormat
    case invalidTimeInterval
    case invalidStringType
    case invalidState
}
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
            throw jsonStringError.invalidJsonFormat
        }
        guard let dataJson =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    throw jsonStringError.invalidJsonFormat
            }
        
        guard let comment =  dataJson["comment"] as? String else {
            throw jsonStringError.invalidStringType
        }
        
        
        guard let timeStamp =  dataJson["timestamp"] as? Double else {
            throw jsonStringError.invalidTimeInterval
        }
        guard let state =  dataJson["state"] as? String else {
            throw jsonStringError.invalidStringType
        }
        
        if state == "open" {
            self.state = State.open
        }else if state == "closed" {
            self.state = State.closed
        }else {
           throw jsonStringError.invalidState
        }
        
        self.timestamp = Date(timeIntervalSince1970: timeStamp)
        self.comment = comment

    }
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
        var foundedBugs = [Bug]()
    
        let pastDayMax:Double  = -1 * 60 * 60 * 24
        let pastWeekMax:Double = -1 * 60 * 60 * 24 * 7
        let pastMonthMax:Double = -1 * 60 * 60 * 24 * 7 * 4
        
        var currentTimeRange:TimeRange?
        
        for bug in bugs {
            
             let timeRangeDouble = bug.timestamp.timeIntervalSinceNow
                switch timeRangeDouble {
                    
                case let r where r > pastDayMax && r < 0:
                    currentTimeRange = .pastDay
                    break
                case let r where r > pastWeekMax && r < 0:
                    currentTimeRange = .pastWeek
                    break
                case let r where r > pastMonthMax && r < 0:
                    currentTimeRange = .pastMonth
                    break
                default:
                    continue
                }
            
            if timeRange != currentTimeRange  {
                continue
            }
            if bug.state != state {
                continue
            }
            foundedBugs.append(bug)
            }

      return foundedBugs
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
