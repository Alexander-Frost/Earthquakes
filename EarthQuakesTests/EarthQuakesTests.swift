@testable import EarthQuakes
import XCTest

final class EarthQuakesTests: XCTestCase {
    /**
     Due to time constraints I opted to make an async call to backend instead of mocking out responses
     In a production enviornment we'd want a plethora of unit tests, as well as UI tests
     */

    let networkService = NetworkController()
    
    override class func setUp() {
        super.setUp()
    }
    
    /// Check that we have at least one earthquake
    func test_async_earthquake_fetch() {
        let promise = expectation(description: "success")
        
        var earthquakes: [Quake] = []
        networkService.fetchQuakes(daysBackToShow: 5) { result in
            switch result {
            case .success(let quakes):
                earthquakes = quakes
                promise.fulfill()
                
            case .failure(let error):
                XCTFail("Failed to fetch earthquakes from network request. Verify backend is not down. Error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [promise], timeout: 5)
        XCTAssertTrue(earthquakes.count > 1)
    }
}
