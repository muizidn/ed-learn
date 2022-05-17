Pod::Spec.new do |s|
    s.name         = "EssentialDeveloperUI"
    s.version      = "0.1-dev-internal"
    s.summary      = "A short description of EssentialDeveloperUI."
    s.description  = "A long description of EssentialDeveloperUI"
    s.homepage     = "https://github.com/muizidn/ed-learn"
    s.license      = { :type => 'Proprietary' }
    s.author       = { 'muizidn' => 'muiz.idn@gmail.com' }
    s.source       = { :git => "", :tag => s.version }
    s.source_files = "UIModule/**/*.{swift}"
    s.resources    = [
      'UIModule/**/*.{storyboard,xib,xcassets,strings}',
      'UIModule/**/*.ttf'
    ]

    s.osx.deployment_target  = '10.15'

    s.test_spec 'UITests' do |s|
      s.requires_app_host = true
      s.source_files = 'UITests/**/*.swift'
    end
end
