Pod::Spec.new do |s|
    s.name         = "DomainModule"
    s.version      = "0.1-dev-internal"
    s.summary      = "A short description of DomainModule."
    s.description  = "A long description of DomainModule"
    s.homepage     = "https://github.com/muizidn/ed-learn"
    s.license      = { :type => 'Proprietary' }
    s.author       = { 'muizidn' => 'muiz.idn@gmail.com' }
    s.source       = { :git => "", :tag => s.version }
    s.source_files = "DomainModule/**/*.{swift}"

    s.ios.deployment_target  = '9.0'
    s.osx.deployment_target  = '10.15'
      
    s.test_spec 'Tests' do |s|
      s.source_files = 'Tests/**/*.swift'
    end

    s.test_spec 'UITests' do |s|
      s.requires_app_host = true
      s.source_files = 'UITests/**/*.swift'
    end
end
