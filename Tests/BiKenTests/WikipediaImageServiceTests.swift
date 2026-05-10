import XCTest
import os
@testable import BiKen

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - WikipediaImageServiceTests

final class WikipediaImageServiceTests: XCTestCase {

    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        session = nil
        super.tearDown()
    }

    // MARK: - 成功ケース

    func testImageURL_found_returnURL() async {
        let expectedSource = "https://example.com/image.jpg"
        let json = successJSON(source: expectedSource)
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://en.wikipedia.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let sut = WikipediaImageService(session: session)
        let url = await sut.imageURL(wikiTitle: "Mona_Lisa", lang: "en")

        XCTAssertEqual(url?.absoluteString, expectedSource)
    }

    // MARK: - ネットワークエラー（一時的失敗）はキャッシュしない

    func testImageURL_networkError_notCached_allowsRetry() async {
        // 1回目: ネットワークエラー
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let sut = WikipediaImageService(session: session)
        let firstResult = await sut.imageURL(wikiTitle: "Mona_Lisa", lang: "en")
        XCTAssertNil(firstResult, "ネットワークエラー時は nil を返すべき")

        // 2回目: 成功（キャッシュされていなければ再試行される）
        let expectedSource = "https://example.com/image.jpg"
        let json = successJSON(source: expectedSource)
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://en.wikipedia.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let secondResult = await sut.imageURL(wikiTitle: "Mona_Lisa", lang: "en")
        XCTAssertEqual(secondResult?.absoluteString, expectedSource, "通信回復後は画像を取得できるべき")
    }

    // MARK: - コンテンツ不在（恒久的失敗）はキャッシュする

    func testImageURL_absent_isCached_noRetry() async {
        let callCount = OSAllocatedUnfairLock(initialState: 0)
        let absentJSON = missingPageJSON()
        MockURLProtocol.requestHandler = { _ in
            callCount.withLock { $0 += 1 }
            let response = HTTPURLResponse(url: URL(string: "https://en.wikipedia.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, absentJSON)
        }

        let sut = WikipediaImageService(session: session)
        let first = await sut.imageURL(wikiTitle: "NonExistentPage_XYZ", lang: "en")
        let second = await sut.imageURL(wikiTitle: "NonExistentPage_XYZ", lang: "en")

        XCTAssertNil(first)
        XCTAssertNil(second)
        XCTAssertEqual(callCount.withLock { $0 }, 1, "コンテンツ不在はキャッシュされ、2回目はAPIを叩かないべき")
    }

    // MARK: - 成功結果はキャッシュされる

    func testImageURL_found_isCached() async {
        let callCount = OSAllocatedUnfairLock(initialState: 0)
        let json = successJSON(source: "https://example.com/image.jpg")
        MockURLProtocol.requestHandler = { _ in
            callCount.withLock { $0 += 1 }
            let response = HTTPURLResponse(url: URL(string: "https://en.wikipedia.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let sut = WikipediaImageService(session: session)
        _ = await sut.imageURL(wikiTitle: "Mona_Lisa", lang: "en")
        _ = await sut.imageURL(wikiTitle: "Mona_Lisa", lang: "en")

        XCTAssertEqual(callCount.withLock { $0 }, 1, "成功結果はキャッシュされ、2回目はAPIを叩かないべき")
    }

    // MARK: - サムネイルなし（恒久的失敗）はキャッシュする

    func testImageURL_noThumbnail_isCached_noRetry() async {
        let callCount = OSAllocatedUnfairLock(initialState: 0)
        let noThumbJSON = noThumbnailJSON()
        MockURLProtocol.requestHandler = { _ in
            callCount.withLock { $0 += 1 }
            let response = HTTPURLResponse(url: URL(string: "https://en.wikipedia.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, noThumbJSON)
        }

        let sut = WikipediaImageService(session: session)
        let first = await sut.imageURL(wikiTitle: "SomeArtwork", lang: "en")
        let second = await sut.imageURL(wikiTitle: "SomeArtwork", lang: "en")

        XCTAssertNil(first)
        XCTAssertNil(second)
        XCTAssertEqual(callCount.withLock { $0 }, 1, "サムネイルなしはキャッシュされ、2回目はAPIを叩かないべき")
    }

    // MARK: - HTTP エラー（一時的失敗）はキャッシュしない

    func testImageURL_serverError_notCached_allowsRetry() async {
        // 1回目: サーバーエラー 503
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://en.wikipedia.org")!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let sut = WikipediaImageService(session: session)
        let firstResult = await sut.imageURL(wikiTitle: "Mona_Lisa", lang: "en")
        XCTAssertNil(firstResult, "503エラー時は nil を返すべき")

        // 2回目: 成功（キャッシュされていなければ再試行される）
        let expectedSource = "https://example.com/image.jpg"
        let json = successJSON(source: expectedSource)
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://en.wikipedia.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let secondResult = await sut.imageURL(wikiTitle: "Mona_Lisa", lang: "en")
        XCTAssertEqual(secondResult?.absoluteString, expectedSource, "サーバー回復後は画像を取得できるべき")
    }

    // MARK: - Helpers

    private func successJSON(source: String) -> Data {
        let json: [String: Any] = [
            "query": [
                "pages": [
                    "12345": [
                        "pageid": 12345,
                        "title": "Mona Lisa",
                        "thumbnail": [
                            "source": source,
                            "width": 800,
                            "height": 1200
                        ]
                    ]
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func missingPageJSON() -> Data {
        let json: [String: Any] = [
            "query": [
                "pages": [
                    "-1": [
                        "ns": 0,
                        "title": "NonExistentPage_XYZ",
                        "missing": ""
                    ]
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func noThumbnailJSON() -> Data {
        let json: [String: Any] = [
            "query": [
                "pages": [
                    "99999": [
                        "pageid": 99999,
                        "title": "SomeArtwork"
                    ]
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
