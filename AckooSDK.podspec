#
# Be sure to run `pod lib lint AckooSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AckooSDK'
  s.version          = '0.1.4'
  s.summary          = 'iOS SDK that keep track of the purchase with the help of iOS universal links.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'iOS SDK that keep track of the purchase from source app to target app with the help of iOS universal links.'

  s.homepage         = 'https://www.ackoo.app/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mihirpmehta' => 'mihirpmehta@gmail.com' }
  s.source           = { :git => 'https://github.com/ackoo-app/AckooSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_versions = '5.0'
  s.source_files = 'AckooSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AckooSDK' => ['AckooSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
