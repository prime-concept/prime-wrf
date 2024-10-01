import Alamofire
import Foundation
import PromiseKit

typealias CancellationToken = () -> Void
typealias EndpointResponse<T> = (result: Promise<T>, cancellation: CancellationToken)

class APIEndpoint {
    private lazy var manager = SessionManager(configuration: self.sessionConfiguration)
    private let basePath: String

    private lazy var sessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15

        return configuration
    }()

    init(basePath: String, requestAdapter: RequestAdapter? = nil) {
        self.basePath = basePath
        self.manager.adapter = requestAdapter
    }

    // MARK: - Common

    func request(
        endpoint: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding
    ) -> EndpointResponse<Data> {
        var isCancelled = false
        var dataRequest: DataRequest?

        let promise = Promise<Data> { seal in
            let path = self.makeFullPath(endpoint: endpoint)
            print("request created: path = \(path)\n\tmethod = \(method)\n\tparams = \(String(describing: parameters))")

            dataRequest = self.manager.request(
                self.makeFullPath(endpoint: endpoint),
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            ).responseData { response in
                if isCancelled {
                    seal.reject(Error.requestRejected)
                    return
                }

                if [401, 403].contains(response.response?.statusCode) {
                    NotificationCenter.default.post(name: .logout, object: nil)
                    seal.reject(Error.unauthorized)
                    return
                }

				switch response.result {
					case .failure(let error):
						print("create request failed: \(error)")
						seal.reject(error)
					case .success(let data):
						if data.count < 50 * 1024 {
							let requestString = dataRequest?.request?.debugDescription ?? "NULL"
							let responseString = String(data: data, encoding: .utf8) ?? "NULL"
							print("Response for:\n\(requestString)\nis:\n\(responseString)")
						}
						seal.fulfill(data)
				}
            }

            if let curl = dataRequest?.request?.cURL {
                print("\(curl)")
            }
        }

        let cancellation = {
            isCancelled = true
            dataRequest?.cancel()
        }

        return (promise, cancellation)
    }

    // MARK: - Create (POST)

    func create<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .post,
            parameters: parameters,
            headers: headers,
            encoding: encoding
        )

        let newPromise: Promise<V> = self.decodeData(from: promise, source: endpoint)
        return (newPromise, cancellation)
    }

    // MARK: - Retrieve (GET)

    func retrieve<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .get,
            parameters: parameters,
            headers: headers,
            encoding: URLEncoding.default
        )

        let newPromise: Promise<V> = self.decodeData(from: promise, source: endpoint)
        return (newPromise, cancellation)
    }

    // MARK: - Update (PUT)

    func update<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .put,
            parameters: parameters,
            headers: headers,
            encoding: encoding
        )

        let newPromise: Promise<V> = self.decodeData(from: promise, source: endpoint)
        return (newPromise, cancellation)
    }

    // MARK: - Remove (DELETE)

    func remove<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .delete,
            parameters: parameters,
            headers: headers,
            encoding: encoding
        )

        let newPromise: Promise<V> = self.decodeData(from: promise, source: endpoint)
        return (newPromise, cancellation)
    }

    // MARK: - GET (MULTIPART)

    func retrieveMultipart(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) -> EndpointResponse<Data> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .get,
            parameters: parameters,
            headers: headers,
            encoding: URLEncoding.default
        )

        return (promise, cancellation)
    }

    // MARK: - Private API

    private func makeFullPath(endpoint: String) -> String {
        return "\(self.basePath)\(endpoint)"
    }

    private func decodeData<T: Decodable>(from promise: Promise<Data>, source: String? = nil) -> Promise<T> {
        return Promise<T> { seal in
            promise.done { data in
                let decoder = JSONDecoder()

                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .iso8601)
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                decoder.dateDecodingStrategy = .custom { decoder -> Date in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)

                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ss.SSSZ"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }

                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }

                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }

                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }

                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }

                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }

                    throw Error.invalidDateDecoding
                }

                do {
                    let object = try decoder.decode(T.self, from: data)
                    seal.fulfill(object)
                } catch {
                    print("decoding data error: \(error), source = \(source ?? "unknown")")
                    print("dump data: \(String(describing: String(data: data, encoding: .utf8)))")
                    seal.reject(Error.decodeFailed)
                    return
                }
            }.catch { error in
				print("APIEndpoint ERROR ON URL \(source ?? "NULL")\n\(error)")
                seal.reject(error)
            }
        }
    }

    // MARK: - Enums

    enum Error: Swift.Error {
        case requestRejected
        case decodeFailed
        case invalidDateDecoding
        case unauthorized
    }
}

private extension URLRequest {
    var cURL: String {
        guard let url = self.url else {
            return ""
        }

        var baseCommand = #"curl "\#(url.absoluteString)""#

        if self.httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = self.httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = self.allHTTPHeaderFields {
            for (key, value) in headers {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = self.httpBody, let body = String(data: data, encoding: .utf8) {
            let cleanBody = body.replacingOccurrences(of: #"\n"#, with: "")
            command.append("-d '\(cleanBody)'")
        }

        return command.joined(separator: " \\\n\t")
    }
}
