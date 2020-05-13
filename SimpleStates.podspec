
Pod::Spec.new do |spec|

  spec.name         = "SimpleStates"
  spec.version      = "0.1.0"
  spec.summary      = "Dead simple states for reactive programming in Swift."

  spec.description  = <<-DESC
Allows you to attach a State to a given property in Swift, and have that property change whenever the state does.

This is a lot more lightweight and easy to understand when compared to ReactiveSwift and the like (though if you're going to be doing any heavy lifting you should probably use those).
                   DESC

  spec.homepage     = "https://github.com/bd452/SimpleStates"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "Bryce Dougherty" => "bryce.dougherty@gmail.com" }

  spec.platform     = :ios, "8.0"

  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/bd452/SimpleStates.git", :tag => "#{spec.version}" }

  spec.source_files  = "SimpleStates"


end
