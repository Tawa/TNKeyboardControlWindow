#
# Be sure to run `pod lib lint TNKeyboardControlWindow.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
	s.name				= 'TNKeyboardControlWindow'
	s.version			= '1.0'
	s.summary			= 'Private Pod for Pride Star Inc'

	# This description is used to generate tags and improve search results.
	#   * Think: What does it do? Why did you write it? What is the focus?
	#   * Try to keep it short, snappy and to the point.
	#   * Write the description between the DESC delimiters below.
	#   * Finally, don't worry about the indent, CocoaPods strips it!

	s.description		= "The purpose of this pod is to create a framework that contains all the reusable code that we need for all our projects."

	s.homepage			= 'https://github.com/Tawa/TNKeyboardControlWindow'
	s.license			= { :type => 'MIT', :file => 'LICENSE' }
	s.author			= { 'TawaNicolas' => 'tawanicolas@gmail.com' }
	s.source			= { :git => 'https://github.com/Tawa/TNKeyboardControlWindow', :tag => s.version.to_s }
	s.social_media_url	= 'https://twitter.com/TawaNicolas'

	s.ios.deployment_target = '8.0'

	# s.public_header_files = 'Pod/Classes/**/*.h'
	# s.frameworks = 'UIKit', 'MapKit'

	s.subspec 'TNKeyboardControlWindow' do |ss|
		ss.source_files = 'Pod'
	end
end
