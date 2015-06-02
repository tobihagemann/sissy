inhibit_all_warnings!

def import_common_pods
	pod 'AFNetworking', '~> 2.5.4'
	pod 'hpple', :git => 'https://github.com/MuscleRumble/hpple'
end

target "sissy-osx" do
	platform :osx, '10.10'
	import_common_pods
	pod 'GBCli', :head
end

target "sissy-ios" do
	platform :ios, '8.0'
	import_common_pods
	pod 'CSNotificationView', :git => 'https://github.com/MuscleRumble/CSNotificationView'
	pod 'FXKeychain', '~> 1.5.3'
	pod 'GVUserDefaults', '~> 1.0.1'
	pod 'SIAlertView', '~> 1.3'
	pod 'SORelativeDateTransformer', '~> 1.1.10'
	pod 'SVProgressHUD', '~> 1.1.3'
	pod 'XLForm', :head
end
