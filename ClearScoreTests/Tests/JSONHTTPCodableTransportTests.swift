import XCTest
@testable import ClearScore

final class JSONHTTPCodableTransportTests: XCTestCase {
    
    struct Sample: Equatable, Decodable {
        let id: String
    }
    
    private var dataTransport: MockHTTPDataTransport!
    private var jsonTransport: JSONHTTPCodableTransport!
    
    override func setUp() {
        dataTransport = MockHTTPDataTransport()
        jsonTransport = JSONHTTPCodableTransport(
            encoder: JSONEncoder(),
            decoder: JSONDecoder(),
            transport: dataTransport
        )
    }
    
    override func tearDown() {
        dataTransport = nil
        jsonTransport = nil
    }
    
    func testFetch_shouldReturnEntity_whenTransportReturnsValidData() async throws {
        let url = URL(string: "http://example.org/test")!
        let inputRequest = HTTPGetRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        var expectedRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        expectedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        let expectedResult = Sample(id: "foo")
        dataTransport.mockFetch = { request in
            XCTAssertEqual(request, expectedRequest)
            let json = """
                { "id": "foo" }
            """
            return json.data(using: .utf8)!
        }
        let actualResult = try await jsonTransport.get(request: inputRequest) as Sample
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testFetch_shouldReturnEntity_whenTransportReturnsIncompatibleData() async throws {
        let url = URL(string: "http://example.org/test")!
        let inputRequest = HTTPGetRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        var expectedRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        expectedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        dataTransport.mockFetch = { request in
            XCTAssertEqual(request, expectedRequest)
            let json = """
                { "invalid_field": 42 }
            """
            return json.data(using: .utf8)!
        }
        await XCTAssertThrowsError(try await jsonTransport.get(request: inputRequest) as Sample)
    }
    
    func testFetch_shouldThrowError_whenTransportThrowsError() async throws {
        let url = URL(string: "http://example.org/test")!
        let inputRequest = HTTPGetRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        var expectedRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        expectedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        dataTransport.mockFetch = { request in
            XCTAssertEqual(request, expectedRequest)
            throw URLError(.cancelled)
        }
        await XCTAssertThrowsError(try await jsonTransport.get(request: inputRequest) as Sample)
    }
}
