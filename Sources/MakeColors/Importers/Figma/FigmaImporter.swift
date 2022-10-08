import Foundation

enum FigmaErrors: Error {
    case invalidUrl
    case missingToken
    case invalidResponse
    case missingColor(String)
}

class FigmaImporter: Importer {
    let key: String
    let token: String
    let outputName: String

    required init(source: String) throws {
        // https://www.figma.com/file/:key/:title
        guard
            let url = URL(string: source),
            url.host == "www.figma.com",
            url.pathComponents.count >= 4,
            url.pathComponents[1] == "file"
        else {
            throw FigmaErrors.invalidUrl
        }

        key = url.pathComponents[2]
        outputName = url.pathComponents[3]

        guard let token = ProcessInfo.processInfo.environment["FIGMA_TOKEN"] else {
            throw FigmaErrors.missingToken
        }

        self.token = token
    }

    func read() async throws -> [String: ColorDef] {
        let styles = try await request(StylesResponse.self, path: "/v1/files/\(key)/styles").meta.styles
            .filter { $0.styleType == "FILL" }

        let ids = styles.map(\.nodeId).joined(separator: ",")

        let nodes = try await request(
            NodesResponse.self,
            path: "/v1/files/\(key)/nodes",
            query: [URLQueryItem(name: "ids", value: ids)]
        )
        .nodes

        var result: [String: ColorDef] = [:]
        result.reserveCapacity(styles.count)

        for style in styles {
            guard
                let node = nodes[style.nodeId],
                let fill = node.document.fills.first(where: { $0.type == "SOLID" })
            else {
                throw FigmaErrors.missingColor(style.name)
            }

            if node.document.fills.count > 1 {
                print("Warning: Multiple fills defined for \(style.name)")
            }

            if fill.blendMode != "NORMAL" {
                print("Warning: Blend mode \(fill.blendMode) used for \(style.name)")
            }

            guard !result.keys.contains(style.name) else {
                throw Errors.duplicateColor(style.name)
            }

            result[style.name] = .color(Color(fill.color))
        }

        return result
    }

    func request<T: Decodable>(_: T.Type = T.self, path: String, query: [URLQueryItem]? = nil) async throws -> T {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.figma.com"
        components.path = path
        components.queryItems = query

        guard let url = components.url else {
            fatalError("Cannot create url. Components: \(components)")
        }

        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Figma-Token")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            fatalError("Non-HTTP-Response received: \(response)")
        }

        guard response.statusCode == 200 else {
            throw FigmaErrors.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}

struct StylesResponse: Decodable {
    var meta: Meta
    struct Meta: Decodable {
        var styles: [Style]
    }

    struct Style: Decodable {
        var nodeId: String
        var styleType: String
        var name: String
        var description: String
    }
}

struct NodesResponse: Decodable {
    var nodes: [String: Node]

    struct Node: Decodable {
        var document: Document
    }

    struct Document: Decodable {
        var fills: [Fill]
    }

    struct Fill: Decodable {
        var blendMode: String
        var type: String
        var color: Color
    }

    struct Color: Decodable {
        var r, g, b, a: Float
    }
}

extension Color {
    init(_ color: NodesResponse.Color) {
        red = UInt8(truncatingIfNeeded: Int(color.r * 0xFF))
        green = UInt8(truncatingIfNeeded: Int(color.g * 0xFF))
        blue = UInt8(truncatingIfNeeded: Int(color.b * 0xFF))
        alpha = UInt8(truncatingIfNeeded: Int(color.a * 0xFF))
    }
}
