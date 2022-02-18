source 'https://github.com/CocoaPods/Specs'

inhibit_all_warnings!

workspace 'SuperFullback'

install! 'cocoapods', :share_schemes_for_development_pods => true

def devconfigs
  [
      'Debug',
      'Debug-IDE',
      'Release (QA)',
  ]
end

def devtools
  pod 'DevTools', 
    :path => 'Modules/DevTools',
    :configurations => devconfigs, 
    :testspecs => ['Tests', 'UITests']
  pod 'FLEX',
    :configurations => devconfigs
end

target 'FullbackiOS' do 
    platform :ios, '13.0'
    project 'Fullback.project'
    use_frameworks!
    devtools
    pod 'DomainModule', :path => 'Modules/DomainModule', :testspecs => ['Tests', 'UITests'] 
    pod 'Reusables', :path => 'Modules/Reusables', :testspecs => ['Tests', 'UITests']
    pod 'LivePreviewer', :path => 'Modules/LivePreviewer'
    pod 'ThirdPartyLibraries', :path => 'Modules/ThirdPartyLibraries', :testspecs => ['Tests', 'UITests']
end

target 'FullbackmacOS' do
  platform :osx, '10.15' 
  project 'Fullback.project'
  pod 'DomainModule', :path => 'Modules/DomainModule', :testspecs => ['Tests', 'UITests'] 
end