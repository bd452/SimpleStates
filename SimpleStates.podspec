Pod::Spec.new do |s|
  s.name         = "SimpleStates"
  s.version      = "0.1.0"
  s.summary      = "Dead simple states for reactive programming in Swift"
  s.description  = """
  Allows you to attach a "State" to a given property in Swift, and have that property change whenever the state does.

  And it's a lot more lightweight and easy to understand when compared to ReactiveSwift and the like (though if you're going to be doing any heavy lifting you should probably use those)."""
  
  s.homepage     = "https://github.com/bd452/SimpleStates"
  
  s.license      = "MIT License"
  s.author       = { "Bryce Dougherty" => "bryce.dougherty@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/bd452/SimpleStates.git", :tag => "#{s.version}" }
  s.source_files =  "SimpleStates/SimpleStates/**/*.swift" # path to your classes. You can drag them into their own folder.
  
  s.requires_arc = true
  s.swift_version= '5.0'
  s.xcconfig     = { 'SWIFT_VERSION' => '5.0' }
end
