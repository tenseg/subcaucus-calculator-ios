# subcalc-ios

This is the iOS app for the SubCalc web app. It is an app that hosts a built-in copy of the web app in a `WKWebView`. As such, this app also serves as a great example for how to use both `WKWebView` and `URLComponents` in a project. This app is developed and distributed by [Tenseg LLC](https://www.tenseg.net).

## Getting Started

To build this project the following must be installed on your Mac:

* [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)
* [Node](https://nodejs.org/en/) (or `brew install node` if you have [Homebrew](https://brew.sh) installed)

Before the first build you must set up the SubCalc React app submodule:

1. `git submodule update --init --recursive`
2. `cd React`
3. `npm install`

## Web app Considerations

**Do not develop the SubCalc web app using the copy in this project.** Instead, clone it separately somewhere else and develop and test it there. When you have a stable version update the submodule to that, which will put it in a detached head state:

1. `cd React`
2. `git checkout __hash__`
3. Commit the changes to the submodule in the repo of this project using `git commit -am __message__` since Xcode can't seem to recgnize there are changes that need committing if all that is changed is the updated submodule

We reccommend [Visual Studio Code](https://code.visualstudio.com) as the environment to develop and test the SubCalc web app.

## Deployment

You can build this app yourself in Xcode for the iOS Simulator or your own personal devices using Apple's Personal Provisioning. Tenseg LLC distributes the app on the [iOS App Store](https://itunes.apple.com/us/app/subcalc/id352454097?mt=8) for the general public.

## Versioning

We use [SemVer](http://semver.org/) for versioning. See the [version history](CHANGES.md) of this project for changes.

## Authors

* Alexander Celeste – [Tenseg LLC](https://www.tenseg.net)
* Eric Celeste – [Tenseg LLC](https://www.tenseg.net)

## Acknowledgments

We have relied on numerous helpful articles and threads online to learn things as we went about writing the code of this app. Those are referenced throughout the source code where appropriate.
