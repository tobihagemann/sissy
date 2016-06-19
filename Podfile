inhibit_all_warnings!

def import_common_pods
	pod 'AFNetworking', '~> 2.5.0'
	pod 'hpple', :git => 'https://github.com/MuscleRumble/hpple'
end

target "sissy-osx" do
	platform :osx, '10.10'
	import_common_pods
	pod 'GBCli', '~> 1.1.0'
end

target "sissy-ios" do
	platform :ios, '8.0'
	import_common_pods
	pod 'CSNotificationView', :git => 'https://github.com/MuscleRumble/CSNotificationView'
	pod 'FXKeychain', '~> 1.5.0'
	pod 'GVUserDefaults', '~> 1.0.0'
	pod 'SORelativeDateTransformer', '~> 1.1.0'
	pod 'SVProgressHUD', '~> 1.1.0'
	pod 'XLForm', '~> 3.2.0'
end
