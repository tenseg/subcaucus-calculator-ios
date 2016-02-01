# TODO #

* Better about screen
* Add app version, build number, iOS version, and device type to the support email
* Transition all email functionality to iOS mail compose view controller
* Sharing of caucuses should use the iOS share sheet, by us sharing a block of text that is description and json; this would support not just email, but messages, copy, and many others as well
* Implement universal links with associated domains, which requires HTTPS be standard for sd64dfl.org
* Caucus deletion option
* Automatically import Caucus.plist into a saved caucus

# NOT YET #

* Auto-updating web code (concern about the security of this and App Store rules)

# DONE #

2.0.1 to be released to app store 20160201:
* 20151217 (atc) began work on utilizing the iOS share sheet instead of emailing a caucus directly
* 20160201 (efc) clarified use of coin flips for tied remainders

2.0 released 17 December 2015:
* 20151209 (efc) Add a way to communicate with the webview, maybe as outlined [on StackOverflow](http://stackoverflow.com/questions/15983797/can-a-uiwebview-interact-communicate-with-the-app)
* 20151208 (efc) Icon and splash screen (no splash screen, actually)
* 20151204 (efc+alex) Accomodate the status bar at the top of the screen. What do we do when the status bar grows (like during a phone call)?
* 20151101 (efc) created first version of SubCalc to use the webview approach
