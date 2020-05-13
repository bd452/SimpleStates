# SimpleStates

Dead simple states for reactive programming in Swift

[![Version](https://img.shields.io/cocoapods/v/SimpleStates.svg?style=flat)](https://cocoapods.org/pods/SimpleStates)
[![License](https://img.shields.io/cocoapods/l/SimpleStates.svg?style=flat)](https://cocoapods.org/pods/SimpleStates)
[![Platform](https://img.shields.io/cocoapods/p/SimpleStates.svg?style=flat)](https://cocoapods.org/pods/SimpleStates)

Allows you to attach a "State" to a given property in Swift, and have that property change whenever the state does.

And it's a lot more lightweight and easy to understand when compared to ReactiveSwift and the like (though if you're going to be doing any heavy lifting you should probably use those).

## Installation

SimpleStates is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SimpleStates'
```

## Usage

import it

```swift
import SimpleStates
```

### Creating and Binding the State

First, you have to create a `State` object, and assign it a default value. 

It doesn't matter where you actually declare or store the value, but I prefer to keep it as a class `let` property. If you feel so inclined, you can even keep it on some Singleton somewhere so you can access it from anywhere in your application (though I wouldn't recommend it).

There are a few ways to actually create the object. The first (and easiest) is to just instantiate it with a default value (this default value can be any Swift type) , like so:

```swift
let myState = State("Text")
```

Then, to use it, you bind it to a property.

```swift
let label = UILabel()

/// with a KeyPath
myState.bind(label, .\text)

// or with a BundledKeyPath (more on that later)
myState(label..\.text)

// or with some nice sugar
label..\.text <-> myState
```

The first option is a function that takes 2 arguments, an object and a `KeyPath` that points to the property you want to bind to. Simple.

The second option is similar to the first one, but called on the State object itself. Here I'm using a BundleKeyPath, which contains both the object we're pointing to and the path itself, but both this and .bind take both kinds of arguments.

That last option is a combination of a couple of helper functions. 

`..` : This takes an object and a KeyPath and combines them into a single object called `BundledKeyPath` which can then be bound to a state. It will throw an error if your object doesn't have the specified KeyPath.

`<->` : This binds a given `BundledKeyPath` to a `State`.

When you set the binding, the property will immediately update to the value of the state, and will update whenever the state is updated.

### Updating the state

To actually set the state, you use the `State.set` method

```swift
myState.set("New Text")
```

`label.text` has now been updated with our new value (and UIKit will automatically update as well)

That's it!

### Getting the current value of the state

To get the current value, just call `State.get()`

```swift
let myState = State("Text")

myState.get()
/// returns "Text"
```

### Advanced State Bindings

Sometimes, a simple property binding just won't cut it. For example, if you need to modify the value first, or if you need to call a separate update function, such as with a `UITableView`.

In this case, instead of using `State.bind(BundledKeyPath)` or `State.bind(Any, KeyPath)`, you use `State.on((newValue)->Void)`, which allows you to pass in a custom closure that is called whenever the value is updated.

This example will append a smiley face to the label's text before it is updated:

```swift
let myState = State("Text")
let label = UILabel()

myState.on({newValue in 
     label.text = val + " 😀"
})
myState.set("hello world")

/// label.text is now "hello world 😀"
```
For use with a table view, you would just tell the view to reload from within the closure. 

Also, `State.on` closures are always called on the main queue, so you don't have to worry about doing that yourself.

### Unbinding

Whenever you create a binding, a unique ID will be returned that allows you to later unbind with `State.unBind`

```swift
let myState = State("Text")
let label = UILabel()

let labelBinding = myState.bind(label, \.text)
/// OR 
let labelBinding = label..\.text <-> myState

myState.set("Hello World")
/// label.text is now "Hello World"
myState.unBind(labelBinding)
myState.set("Goodbye World")
/// label.text is still "Hello World"

```



### Alternate methods

You can also create a state object with syntax similar to React's state hook

```swift
let (myState, getMyState, setMyState) = useState("Text")
```

This returns a tuple of the state object, a getter function (that doesn't attach a listener), and a setter function.

It can be used like so:

```swift
let (myState, getMyState, setMyState) = useState("Text")

let myLabel = UILabel()

myLabel..\.text <-> myState

setMyState("New Text")
/// myLabel.text is now "New Text"

getMyState()
/// returns "New Text"
```



You can also create a state inline with a default binding, but this will not allow you to unbind it in the future.

```swift
let myLabel = UILabel()

let myState = boundState(myLabel..\.text, "Text")

/// myLabel.text is now "Text"

myState.set("New Text")

/// myLabel.text is now "New Text"
```

### Bundled Key Paths

To make life easier when making the bindings, there's a struct `BundledKeyPath` that exists just to hold a reference to a KeyPath and an object on which it resides.

To make one, you can either call the constructor directly, or use the `..` function.

```swift
let myLabel = UILabel()

let bkp = BundledKeyPath(myLabel, \.text)
// OR
let bkp = myLabel..\.text
```

This just makes it easier to construct a binding with the given infix functions, since we need both a reference to the object and the KeyPath to actually set the given property, and Swift doesn't let us make our own Ternary operators.

 It's totally not necessary to use them if you don't want to.


**That's it!**. Let me know if you have any questions!

## Author

Bryce Dougherty – bryce.dougherty@gmail.com

## License

This project is provided under the MIT License

