import XCTest
@testable import PrivateHomeAI

final class AppTests: XCTestCase {
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