import XCTest
@testable import Nooku

final class NookuAppTests: XCTestCase {
    func testAppInitialization() throws {
        // This is a basic test to ensure the app can initialize
        let app = NookuApp()
        XCTAssertNotNil(app)
    }
    
    func testAppStateInitialization() {
        let appState = AppState()
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertFalse(appState.isConnectedToMac)
        XCTAssertEqual(appState.connectionStatus, .disconnected)
    }
    
    func testAuthenticationViewModel() {
        let viewModel = AuthenticationViewModel()
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.username, "")
        XCTAssertEqual(viewModel.password, "")
    }
} 