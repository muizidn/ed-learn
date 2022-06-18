Pod::Spec.new do |s|
  s.name          = "DevTools"
  s.version       = "0.1-dev-internal"
  s.summary       = "DevTools module for Fullback"
  s.homepage      = "https://github.com/muizidn/ed-learn/"
  s.license      = { :type => 'Proprietary' }
  s.author       = { 'muizidn' => 'muiz.idn@gmail.com' }
  s.source       = { :git => "", :tag => s.version }
  s.source_files  = [
    'DevTools/Sources/**/*.{swift}',
    'DevTools/Generated/**/*.{swift}',
  ]
  s.resources    = [
      'DevTools/**/*.{storyboard,xib,xcassets,strings}',
      'DevTools/**/*.ttf'
    ]
  s.platform = :ios
  s.swift_version = "5.0"
  s.ios.deployment_target  = '12.0'
  
  s.test_spec 'Tests' do |s|
    s.source_files = 'Tests/**/*.swift'
  end

  s.test_spec 'UITests' do |s|
    s.requires_app_host = true
    s.source_files = 'UITests/**/*.swift'
  end
  
end
