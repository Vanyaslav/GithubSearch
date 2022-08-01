# GithubSearch

Example: Pagination with RxSwift and RxFeeback

The example contains multi-flow solution(UITabBar, UISplitViewController and solution with UINavigationController as main component).
The solutions itself are based on MVVM-R architecture, where router is responsible for initialisation and navigation of views.
The routers work with self-disposing mechanism which allows the router exist within the runtime just for the period of the time that is needed without maintaining a strong reference with parent object.
