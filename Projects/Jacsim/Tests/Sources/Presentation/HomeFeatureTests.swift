import Foundation
import Testing
import ComposableArchitecture

@testable import Jacsim

@Test("miniCardImageLoaded는 index가 아닌 id 기준으로 카드 이미지를 갱신한다")
@MainActor
func miniCardImageLoadedUpdatesById() async {
    let firstID = UUID()
    let secondID = UUID()
    let loadedImage = Data("second-image".utf8)

    var initialState = HomeFeature.State()
    initialState.miniCardDisplayData = [
        .init(id: secondID, title: "B", progress: 0.3, totalDays: 10, completedDays: 3, imageData: nil, isTodayCertified: false),
        .init(id: firstID, title: "A", progress: 0.7, totalDays: 10, completedDays: 7, imageData: nil, isTodayCertified: true)
    ]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(.miniCardImageLoaded(id: firstID, imageData: loadedImage)) {
        $0.miniCardDisplayData[1] = HomeFeature.State.MiniCardDisplayData(
            id: firstID,
            title: "A",
            progress: 0.7,
            totalDays: 10,
            completedDays: 7,
            imageData: loadedImage,
            isTodayCertified: true
        )
    }
}

@Test("miniCardImageLoaded는 존재하지 않는 id 응답을 무시한다")
@MainActor
func miniCardImageLoadedIgnoresUnknownId() async {
    let knownID = UUID()
    let unknownID = UUID()
    let originalImage = Data("original-image".utf8)

    var initialState = HomeFeature.State()
    initialState.miniCardDisplayData = [
        .init(
            id: knownID,
            title: "Known",
            progress: 0.5,
            totalDays: 20,
            completedDays: 10,
            imageData: originalImage,
            isTodayCertified: false
        )
    ]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(.miniCardImageLoaded(id: unknownID, imageData: Data("new".utf8)))
    #expect(store.state.miniCardDisplayData[0].imageData == originalImage)
}
