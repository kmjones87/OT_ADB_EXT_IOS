#
# Be sure to run `pod lib lint otsdk_adobe.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'otsdk_adobe'
  s.version          = '1.0.0'
  s.summary          = 'An Adobe Launch extension that will collect consent records for mobile users.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An Adobe Launch extension that will collect consent records for mobile users. The extension monitors the Adobe Launch Privacy Status flag and submits consent to OneTrust whenever this value changes.
                       DESC

  s.homepage         = 'https://github.com/kmjones87/OT_ADB_EXT_IOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'OneTrust, LLC.'
  s.source           = { :git => 'https://github.com/kmjones87/OT_ADB_EXT_IOS.git', :tag => s.version.to_s }


  s.ios.deployment_target = '10.0'
  s.source_files = 'otsdk_adobe/Classes/**/*'
  s.public_header_files = 'otsdk_adobe/Classes/**/*.h'
  s.static_framework = true
  s.dependency 'ACPCore', '~> 2.0'

end
