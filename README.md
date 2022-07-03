# GithubSearch

Example: Pagination with RxSwift and RxFeeback

The example contains multi-flow solution(UITabBar, UISplitViewController and solution with UINavigationController as main component) which can switched by AppDefaults:AppType parameter.
The solutions itself are based on MVVM-R architecture, where router is responsible for initialisation and navigation of views.
The routers work with self-disposing mechanisms which allow the router exist within the ecosystem just for the period of the time is needed without maintaining a strong reference with a parent object.
