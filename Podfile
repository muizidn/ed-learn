source 'https://github.com/CocoaPods/Specs'

platform :osx, '10.15'

use_frameworks!
inhibit_all_warnings!

workspace 'SuperEDLearn'

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

target 'EDLearn' do 
    project 'EDLearn.project'
    pod 'EssentialFeed', :path => 'Modules/EssentialFeed', :testspecs => ['Tests']
    pod 'EssentialFeedUI', :path => 'Modules/EssentialFeed', :testspecs => ['UITests']
    # devtools
    # pod 'DomainModule', :path => 'Modules/DomainModule', :testspecs => ['Tests', 'UITests'] 
    # pod 'Reusables', :path => 'Modules/Reusables', :testspecs => ['Tests', 'UITests']
    # pod 'LivePreviewer', :path => 'Modules/LivePreviewer'
    # pod 'ThirdPartyLibraries', :path => 'Modules/ThirdPartyLibraries', :testspecs => ['Tests', 'UITests']
end