def import_common_pods
	pod 'AFNetworking', '~> 2.5.4'
	pod 'hpple', :git => 'https://github.com/MuscleRumble/hpple'
end

target "sissy-osx" do
	platform :osx, '10.10'
	import_common_pods
	pod 'GBCli', '~> 1.1'
end

target "sissy-ios" do
	platform :ios, '8.0'
	import_common_pods
	pod 'CSNotificationView', :git => 'https://github.com/MuscleRumble/CSNotificationView'
	pod 'FXKeychain', '~> 1.5.2'
	pod 'GVUserDefaults', '~> 1.0.1'
	pod 'SORelativeDateTransformer', '~> 1.1.10'
	pod 'XLForm', :head
end
