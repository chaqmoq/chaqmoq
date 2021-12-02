@testable import Chaqmoq
import XCTest

final class ChaqmoqTests: XCTestCase {
    func test1() {
        let app = Chaqmoq()
        app.middleware = [
            HTTPMethodOverrideMiddleware(),
            CORSMiddleware(),
            RoutingMiddleware()
        ]

        app.post("/hello/{name}", middleware: [CORSMiddleware()]) { request in
            let route: Route = request.getAttribute("_route")!
            let parameter = route.parameters?.first(where: { $0.name == "name" })
            return "Hello \(parameter?.value ?? "")"
        }

        try! app.run()
    }
}
