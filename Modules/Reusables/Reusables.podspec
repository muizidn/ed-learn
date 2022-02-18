Pod::Spec.new do |s|
  s.name          = "Reusables"
  s.version       = "0.1-dev-internal"
  s.summary       = "Reusables module for PrivyLearn"
  s.homepage      = "https://github.com/muizidn/ed-learn/"
  s.license      = { :type => 'Proprietary' }
  s.author       = { 'muizidn' => 'muiz.idn@gmail.com' }
  s.source       = { :git => "", :tag => s.version }
  s.source_files  = [
    'Reusables/Sources/**/*.{swift}',
    'Reusables/Generated/**/*.{swift}',
  ]
  s.resources    = [
      'Reusables/**/*.{storyboard,xib,xcassets,strings}',
      'Reusables/**/*.ttf'
    ]
  s.platform = :ios
  s.swift_version = "5.0"
  s.ios.deployment_target  = '13.0'
  
  s.dependency "LivePreviewer"
  s.dependency "ThirdPartyLibraries"
  
  s.test_spec 'Tests' do |s|
    s.source_files = 'Tests/**/*.swift'
  end

  s.test_spec 'UITests' do |s|
    s.requires_app_host = true
    s.source_files = 'UITests/**/*.swift'
  end
  
end
