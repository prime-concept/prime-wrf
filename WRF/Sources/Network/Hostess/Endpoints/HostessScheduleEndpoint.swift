import Alamofire
import Foundation
import PromiseKit

protocol HostessScheduleEndpointProtocol: AnyObject {

    /// Get list of shedules by list of hostessScheduleKeys
    ///
    /// - Parameters:
    ///  - hostessShedulesKeys: List of hostess schedules keys
    ///  - date: Date for fetching restaurant schedules
    /// - Returns: List of HostessListSchedule data models
    func schedules(
        for hostessShedulesKeys: [String],
        date: Date
    ) -> EndpointResponse<HostessResponse<[HostessListSchedule]>>

    /// Get  shedules by exact hostessScheduleKey
    ///
    /// - Parameters:
    ///  - hostessShedulesKey: The  restaurant hostess schedule key
    ///  - restaurantID: The restaurant identificator
    ///  - guests: Count of guests to take restaurant schedule
    ///  - date: Date for fetching restaurant schedules
    /// - Returns: List of HostessSchedule data models
    func schedule(
        for hostessShedulesKey: String,
        restaurantID: String,
        guests: Int,
        date: Date
    ) -> EndpointResponse<HostessResponse<HostessSchedule>>
}

final class HostessScheduleEndpoint: HostessEndpoint, HostessScheduleEndpointProtocol {

    /// Get list of shedules by list of hostessScheduleKeys
    static let schedulesEndpoint = "/online/schedules"

    /// Get list of shedules by exact hostessScheduleKey
    static let scheduleEndpoint =  "/schedules"

    func schedules(
        for hostessShedulesKeys: [String],
        date: Date
    ) -> EndpointResponse<HostessResponse<[HostessListSchedule]>> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return self.create(
            endpoint: HostessScheduleEndpoint.schedulesEndpoint,
            parameters: [
                "keys": hostessShedulesKeys,
                "date": formatter.string(from: date)
            ]
        )
    }

    func schedule(
        for hostessShedulesKey: String,
        restaurantID: String,
        guests: Int,
        date: Date
    ) -> EndpointResponse<HostessResponse<HostessSchedule>> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return self.retrieve(
            endpoint: HostessScheduleEndpoint.scheduleEndpoint,
            parameters: [
                "restaurant_id": restaurantID,
                "guest": guests,
                "date": formatter.string(from: date)
            ],
            headers:  [
                "x-widget-key": hostessShedulesKey
            ]
        )
    }
}
