
import Foundation
import YandexMobileMetrica

enum AnalyticsReporterProvider {
    case yandexMetrica
}

protocol AnalyticsReportable {
    func send(_ provider: AnalyticsReporterProvider) -> Self
}

class AnalyticsReporter {
    static func reportEvent(
        _ event: String,
        parameters: [String: Any] = [:],
        provider: AnalyticsReporterProvider
    ) {
        switch provider {
        case .yandexMetrica:
            YMMYandexMetrica.reportEvent(event, parameters: parameters)
        }
    }
}

