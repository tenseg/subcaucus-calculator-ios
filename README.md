# subcaucus-calculator-ios

This is the iOS app for the [subcaucus-calculator](https://github.com/tenseg/subcaucus-calculator) web app. It is an app that hosts a built-in copy of the web app in a `WKWebView`. As such, this app also serves as a great example for how to use both `WKWebView` and `URLComponents` in a project. This app is developed and distributed by [Tenseg LLC](https://www.tenseg.net).

## Getting Started

To build this project the following must be installed on your Mac:

* [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)
* [Node.js](https://nodejs.org/) (or `brew install node` if you have [Homebrew](https://brew.sh) installed)

Before the first build you must set up the subcaucus-calculator React app submodule:  `git submodule update --init --recursive`. If you don't do this the build will fail and Xcode will ask you to run the command.

The first build sometimes fails anyway. The best we can tell this is a side-effect of the *Run Script* build phases used to write the Git commit number as the build number and build the React app with Xcode's new build system. The workaround we've found is simply to run *Product > Clean Build Folder* once and then subsequent builds should succeed. We aren't sure what is happening, but know that this tends to fix the problem and that it is usually just a getting started thing.

## Web app Considerations

**Do not develop the subcaucus-calculator web app using the copy in this project.** Instead, clone it separately somewhere else and develop and test it there. When you have a stable version update the submodule to that, which will put it in a detached head state:

1. `cd React`
2. `git checkout __hash__`
3. Commit the changes to the submodule in the repo of this project using `git commit -am __message__` since Xcode can't seem to recgnize there are changes that need committing with regard to submodules

We reccommend [Visual Studio Code](https://code.visualstudio.com) as the environment to use to develop and test the subcaucus-calculator web app.

## Deployment

You can build this app yourself in Xcode for the iOS Simulator or your own personal devices using Apple's Personal Provisioning. Tenseg LLC distributes the app on the [iOS App Store](https://itunes.apple.com/us/app/subcalc/id352454097?mt=8) for the general public.

## Versioning

We use [SemVer](http://semver.org/) for versioning. See the [version history](CHANGES.md) of this project for changes.

## Authors

* Alexander Celeste – [Tenseg LLC](https://www.tenseg.net)
* Eric Celeste – [Tenseg LLC](https://www.tenseg.net)

## Acknowledgments

We have relied on numerous helpful articles and threads online to learn things as we went about writing the code of this app. Those are referenced throughout the source code where appropriate.
