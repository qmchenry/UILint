# UILint

[![Build Status](https://app.bitrise.io/app/5571d1f22e8bc4dd/status.svg?token=iDAtzso4K447H1xEf55VoA&branch=master)](https://app.bitrise.io/app/5571d1f22e8bc4dd)
[![Swift package manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The goal of this project is to ease the burden of making high quality user interfaces _just so_ both for developers and designers. Similar to a linter that monitors code for issues, UILint examines a UI at runtime to find potential issues.

The MVP of UILInt will examine a UIKIt, SwiftUI, or hybrid scene, check for several high-yield potential UI issues, and be able to report these findings to the user through a PDF shared from the device.

🚨 Early Alpha 🚨 _you've been warned_

Please don't use this for real yet, but if you're interested in using it, consider [contributing](https://github.com/qmchenry/UILint/projects/1).

## Installation

UILint is a Swift Package that can be added directly to a project in XCode by clicking

`File -> Swift Packages -> Add Package Dependency`

and pasting this repository's url in the resulting search text field and clicking Next. On the next screen, select the version desired. Until there is a release, selecting the master branch is the simplest choice. Click Next and check that the default Add to Target setting makes sense. Click Finish and you're on your way to a lint-free UI!

## Usage

UILint usage is likely to change dramatically, but to get a feel right now, just `import UILint` in a UIViewController subclass of interest, and in the `viewDidLoad` function, add the line:

```swift
let lint = UILintSession(view: view)
```

When the view loads, text representing the views in the scene will appear unceremoniously in the console. A PDF report can be generated and written to a file with

```swift
let pdfData = lint.makePDF()
try? pdfData.write(to: URL(fileURLWithPath: "/tmp/test.pdf"))
```

**Experimental behavior**: Register UILint with your application to enable a gesture to create a UILint PDF report of the current scene and share with a share sheet. 
Add `import UILint` to the SceneDelegate.swift, then add the following to the function `scene(_:willConnectTo:options:)`, then a two-touch double-tap will perform the linting. To perform 
this in the simulator, press Option while mousing over the simulator and click twice.

```swift
UILint.register(window: window)
```
And deregester UILint with this line in `sceneDidDisconnect(_:)`

```swift
UILint.deregister()
```
For apps supporting iOS 12 and earlier, add these lines to the project's AppDelegate functions `application(_:didFinishLaunchingWithOptions:)` and `applicationWillTerminate()`.

A demo UIKit app is available in the TestApps/ directory. It has been integrated with UILint and has these calls in place.
