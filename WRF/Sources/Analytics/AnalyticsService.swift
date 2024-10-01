
import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    static func setupAnalytics() {
        if let configuration = YMMYandexMetricaConfiguration(
            apiKey: PGCMain.shared.config.appMetricaKey
        ) {
            DispatchQueue.global(qos: .background).async {
                configuration.crashReporting = false
                YMMYandexMetrica.activate(with: configuration)
                YMMYandexMetrica.sendEventsBuffer()
            }
        }
    }
}
