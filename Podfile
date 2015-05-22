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
end
