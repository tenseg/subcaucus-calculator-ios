# README #

SubCalc is the Minnesota Subcaucus Calculator. The iOS version (currently v2.0 is in development) of the [Javascript app](http://www.sd64dfl.org/sub). It is written in [Swift](https://developer.apple.com/swift/), though this version is really just a webview and the core code is the same as the web version. So really, this is mostly an HTML/JavaScript project at the moment.

### Repository TOC ###

* Any files at the root of the repo do not get included in builds, but are all in the Xcode project
* "SubCalcTests" includes our unit test source files
* "SubCalc" includes all the source and supporting files for the actual SubCalc binary app
* "[TODO](TODO.md)" contains our working list of issues and features to address; this is the real document in Xcode where we commiserate on things we need to do (though the wiki here on Bitbucket can be used for more complex and heirarchical discussions and planning), we also mark items DONE and record those accomplishments in the TODO file
* "SubCalc.xcodeproj" is the Xcode project for SubCalc
* Assorted other files, like the editable image versions of icons, are also at the root of the repo

### How to set up this repo on your local Mac for editing ###

1. Open Xcode
2. Under the Source Control menu select Check Out...
3. Paste the SSH version of the repo's URL (towards the top of the Overview screen of the repo) into the repostory location field of the window that you just opened in Xcode
4. Authenticate as needed and asked (if you've set up an SSH key pair between your Mac and Bitbucket you won't need this, otherwise Xcode may poke you for username/password)
5. Choose where to save the local copy of the repo
6. Have fun swiftly editing code :)

### When pushing changes to the repo ###

* Please be specific about what your chages are and why they were made
* Be sure the repo is set up to map your username to your real name
* Because this app uses storyboards (a single file for all graphical user interfaces) even though most code editing can be done cocurrently and merged in later, only one person should edit user interface and its code at a time
* Use branching to segregate massive refactoring and feature creation tasks

### For readme editing help ###

* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)