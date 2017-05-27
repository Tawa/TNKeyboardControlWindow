
# TNKeyboardControlWindow

## Summary
TNKeyboardControlWindow is a small utility that helps you integrate keyboard pan-to-dismiss functionality.

![](https://thumbs.gfycat.com/ImpossibleTestyIndianpalmsquirrel-size_restricted.gif)
![](https://thumbs.gfycat.com/EvilMiserableGrayreefshark-size_restricted.gif)

## Installation

#### Manual install
Download the folder 'TNKeyboardControlWindow' and add the files to your project.

#### Cocoapods
Add the following line to your Podfile
```ruby
pod 'TNKeyboardControlWindow'
```

## Integration
In order to handle the keyboard panning accross the whole app, you need to handle it on the UIWindow level.
TNKeyboardControlWindow does that for you.
You need to `#import <TNKeyboardControlWindow.h>` in your AppDelegate, and add the following function to the AppDelegate:
#### Objective-C
```objective-c
-(UIWindow *)window
{
	return [TNKeyboardControlWindow window];
}
```
#### Swift
```swift
var window: UIWindow? {
	get {
		return TNKeyboardControlWindow.window as UIWindow?
	} set {}
}
```
> This will automatically handle dismissing the keyboard across the whole app by dragging!

> In case you have your own custom UIWindow class and you still need to implement this, you can simply subclass TNKeyboardControlWindow instead of UIWindow.

### Handling UI
In most of the View Contorllers in your app, you need to update the UI Layout to accomodate to the keyboard displaying on the screen.
In order to do that, implement `<TNKeyboardListenerProtocol>` in your View Controller and add the method 
#### Objective-C
```objective-c
-(void)keyboardDidChangeFrame:(CGRect)frame {
}
```
#### Swift
```swift
func keyboardDidChangeFrame(_ frame: CGRect) {
	bottomConstraint.constant = 8 + UIScreen.main.bounds.size.height - frame.origin.y
}
```

You would also need to add your View Controller as a listener to the window by calling 
#### Objective-C
```objective-c
[[TNKeyboardControlWindow window] addKeyboardFrameListener:self];
```
#### Swift
```swift
TNKeyboardControlWindow().addKeyboardFrameListener(self)
```
> Ideally inside your `viewDidAppear`. 

You also need to remove your View Controller when it's no longer displayed by calling 
#### Objective-C
```objective-c
[[TNKeyboardControlWindow window] removeKeyboardFrameListener:self];
```
#### Swift
```swift
TNKeyboardControlWindow().removeKeyboardFrameListener(self)
```

And that's it!

A sample project is included with different ViewControllers and different UI components that update with the keyboard.

## Notes

Feel free to use 'TNKeyboardControlWindow' in any way you like. An attribution is not required, but is highly appreciated.
