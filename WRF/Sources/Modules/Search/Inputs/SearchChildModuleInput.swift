import Foundation

protocol SearchChildModuleInput {
    func load(query: String?)
}

protocol SearchEventChildModuleInput: SearchChildModuleInput {
    func load(events date: Date)
}

protocol SearchRestaurantChildModuleInput: SearchChildModuleInput {
}

protocol SearchDeliveryChildModuleInput: SearchChildModuleInput {
}
