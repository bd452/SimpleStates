# SimpleStates

[![Version](https://img.shields.io/cocoapods/v/SimpleStates.svg?style=flat)](https://cocoapods.org/pods/SimpleStates)
[![License](https://img.shields.io/cocoapods/l/SimpleStates.svg?style=flat)](https://cocoapods.org/pods/SimpleStates)
[![Platform](https://img.shields.io/cocoapods/p/SimpleStates.svg?style=flat)](https://cocoapods.org/pods/SimpleStates)

Dead simple states for reactive programming in Swift

Allows you to attach a "State" to a given property in Swift, and have that property change whenever the state does.

And it's a lot more lightweight and a hell of a lot easier to understand when compared to ReactiveSwift and the like (though if you're going to be doing any heavy lifting you should probably use those).

## Installation

SimpleStates is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SimpleStates'
```

## Usage

Basic usage:

```swift
import SimpleStates
let myState = State("hello")

let label = UILabel(CGRect(x: 0, y: 0, width: 100, height: 20))

var changingString = "initial"

myState.bind(label, .\text)
// label.text is now "hello"

myState.on({ newValue in 
	changingString = newValue
})
// changingString is now "hello"

myState.set("hello world")
// label.text and changingString are both now "hello world"

```

### Types of State

There are 3 types of state provided:

#### A regular State

 Holds a value and updates observers when it has been changed by the user. 

Constructed as such:

```swift
let myState = State(defaultValue) 
```

Or, you can also explicitly set the type of the state if you don't want to rely on the compiler's inference:

```swift
let myState = State<CGFloat>(1.0) // would normally be Float
```

#### A NotificationCenter State

Updates the observer when a notification is fired

These can be constructed in 2 ways.

The first takes 3 arguments: the notification to listen for, the initial value of the state, and a closure that translates the `Notification` parameter from the notification and returns the value you want to set the state to.

```swift
let isPortrait = NotificationState(
  UIDevice.orientationDidChangeNotification, 
  default: "",
	mutator: { notif in 
  	return notif.description
  }
)
```

If you don't need the value of the notification parameter, you can construct the state by passing only the notification to listen for and a property getter

```swift
let isPortrait = NotificationState(
  UIDevice.orientationDidChangeNotification, 
  getter: UIDevice.current.orientation
)
```

That will update the value of the state to UIDevice.current.orientation whenever a notification is received

#### A Key-Value Observing State

Observes a given KVO-conforming property and updates the state when it changes

This is initialized with an object and a KeyPath to a property on that object, like so:

```swift
let myState = KVOState(obj: myObject, keyPath: \.propertyName)
```

Normally the property value of the KVO state is immutable so that it remains consistent with the property it is tracking. If the tracked property itself is mutable and you want to change it, then you can use `MutableKVOState`, and then later set the value of the backing variable with .setValue.

```swift
let myState = MutableKVOState(obj: myObject, keyPath: \.propertyName)
```

Ordinarily you can just use myObject.propertyName = newValue and it will have the same effect, but this will allow you to update the state in case you don't have a reference to it laying around.

#### Note

A KVOState will not keep a reference to its bound object around in order to avoid memory leaks, so you'll have to make sure it doesn't get deallocated yourself.

### Binding the State

A state can be bound to a property of a given class, so that it will update that property whenever it is updated.

This can be done in a few ways:

```swift
let label = UILabel()

/// with a KeyPath
myState.bind(label, .\text)

// or with a BundledKeyPath (more on that later)
myState(label..\.text)

// or with some nice helper functions
label..\.text <-> myState

/// These all do the exact same thing
```

The first option is a function that takes 2 arguments, an object and a `KeyPath` that points to the property you want to bind to. Simple.

The second option is similar to the first one, but called on the State object itself. Here I'm using a BundleKeyPath, which contains both the object we're pointing to and the path itself, but both this and .bind take both kinds of arguments.

That last option is a combination of a couple of helper functions. 

`..` : This takes an object and a KeyPath and combines them into a single object called `BundledKeyPath` which can then be bound to a state. It will throw an error if your object doesn't have the specified KeyPath.

`<->` : This binds a given `BundledKeyPath` to a `State`.

When you set the binding, the property will immediately update to the value of the state, and will update whenever the state's value is updated.

### Updating the state

To update the value of a vanilla state, you use the `State.set` method

```swift
myState.set("New Text")
```

`label.text` has now been updated with our new value (and UIKit will automatically update as well)

#### Note: 

KVOState and NotificationState will update automatically and cannot be set manually

### Getting the current value of the state

To get the current value without attaching a listener, just call `State.get()`

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
For use with a table view, for example, you could tell the view to reload from within the closure, then call .get() in the actual rendering method. The tableView will re-render whenever you call dataSource.set.

```swift
let dataSource = State<[String]>([])

override func viewDidLoad() {
	super.viewDidLoad()
	dataSource.on({ _ in 
  	self.tableView.reloadData()
  })
}


override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
	cell.titleLabel.text = dataSource.get()[indexPath.row]
  // Configure the cell...

  return cell
}
```

Of course, you could use `didSet` on a normal property to do this specifically, but it's just an example :slightly_smiling_face:

#### Note

`State.on` closures are always called on the main queue, so you don't have to worry about doing UI updates from within them

### Unbinding a Property from a State

Whenever you create a binding, a `Binding` will be returned that allows you to later unbind with `State.unBind`

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

You can create a state inline with a default binding, but this will not allow you to unbind it in the future.

```swift
let myLabel = UILabel()

let myState = boundState(myLabel..\.text, "Text")

/// myLabel.text is now "Text"

myState.set("New Text")

/// myLabel.text is now "New Text"
```



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

You can also use these when constructing a `MutableKVOState`:

```swift
let state = MutableKVOState(myClass..\.myKVOConformingProperty)
```

#### Note

BundledKeyPaths are always mutable, as an immutable property can't be bound to a state (for obvious reasons). They cannot be created with a get-only property.

----

**That's it!**. Let me know if you have any questions!

## Author

Bryce Dougherty – bryce.dougherty@gmail.com

## License

This project is provided under the MIT License

