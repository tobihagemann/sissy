# sissy

Get notified when your grades for Hochschule Bonn-Rhein-Sieg (H-BRS) have updated. It's both an iOS and OS X app that run 100% locally.

### sissy-ios

The iOS app is making use of the background mode _Background fetch_ and you'll receive a local push notification, when your grades have updated.

### sissy-osx

The OS X app is a command-line tool with the following options:

```
-u --username <value> Username
-p --password <value> Password
-i --interval <value> Interval in seconds (default: 900 [15 minutes])
-? --help             Display this help and exit
```

## Requirements

You have to install the Pods before you can run/build the source code, see [CocoaPods](https://cocoapods.org/).

```sh
pod install
```

## License

Distributed under the MIT license. See the LICENSE file for more info.
