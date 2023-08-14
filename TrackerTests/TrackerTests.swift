import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testTrackersViewControllerLight() {
        guard let vc = TabBarController().viewControllers?.first as? TrackersViewController else { return }
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDark() {
        guard let vc = TabBarController().viewControllers?.first as? TrackersViewController else { return }
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
