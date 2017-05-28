#
# Be sure to run `pod lib lint TNKeyboardControlWindow.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
	s.name				= 'TNKeyboardControlWindow'
	s.version			= '1.0.6'
	s.summary			= 'Keyboard pan-to-dismiss functionality for iOS!'

	s.description		= "The tiny utility helps you implement an app-wide keyboard pan-to-dismiss functionality in just a few lines of code."

	s.homepage			= 'https://github.com/Tawa/TNKeyboardControlWindow'
	s.license			= { :type => 'MIT', :file => 'LICENSE' }
	s.author			= { 'TawaNicolas' => 'tawanicolas@gmail.com' }
	s.source			= { :git => 'https://github.com/Tawa/TNKeyboardControlWindow', :tag => s.version.to_s }
	s.social_media_url	= 'https://twitter.com/TawaNicolas'

	s.ios.deployment_target = '8.0'

	s.subspec 'TNKeyboardControlWindow' do |ss|
		ss.source_files = 'TNKeyboardControlWindow'
	end
end
