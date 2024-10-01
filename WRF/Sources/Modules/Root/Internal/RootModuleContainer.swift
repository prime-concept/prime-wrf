/// The object hosting the app’s root module.
protocol RootModuleContainer: AnyObject {
    func handleDeepLink(_ context: DeeplinkContext) async
}
