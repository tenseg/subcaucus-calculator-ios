#  React App

This app is a shell for the [subcalc-pr](https://grand.clst.org:3000/tenseg/subcalc-pr) React app. We develop that in Visual Studio Code. In order to update the version of the React app that is in this app, do the following:

1. In the `subcalc-pr` project run `npm run build`
2. In Finder delete everything from the  `react` folder in this Xcode project
3. Copy everything from the `build` folder in the `subcalc-pr` project to the `react` folder in this Xcode project
4. In Terminal in this Xcode project run `git add *`
5. Run this Xcode project to make sure the app has the new React app included
6. Commit and push with Git (do whenever ready)
