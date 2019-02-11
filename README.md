# subcalc-ios

This is the iOS app for the SubCalc web app. It is an app that hosts the web app in a `WKWebView`. As such, this app also serves as a great example for how to use both `WKWebView` and `URLComponents` in a project.

## React App

The SubCaalc React app is included as a Git submodule in this project. The files are in the `React/` folder at the root of this project's folder, but not included in the Xcode project itself. There is a *Run Script* build phase that runs  `npm run build`  and moves the resulting web app into the built iOS app bundle.

In order to get the submodule when first cloning this project use: 

1. `git submodule update --init --recursive`
2. `cd React`
3. `npm install`

Do not develop the web app using the copy in this project. Instead, clone it separately somewhere else and develop and test it there. When you have a stable version update the submodule to that, which will put it in a detached head state:

1. `cd React`
2. `git checkout __hash__`
