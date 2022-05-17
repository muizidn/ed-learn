Pod::Spec.new do |s|
    s.name         = "EssentialDeveloper"
    s.version      = "0.1-dev-internal"
    s.summary      = "A short description of EssentialDeveloper."
    s.description  = "A long description of EssentialDeveloper"
    s.homepage     = "https://github.com/muizidn/ed-learn"
    s.license      = { :type => 'Proprietary' }
    s.author       = { 'muizidn' => 'muiz.idn@gmail.com' }
    s.source       = { :git => "", :tag => s.version }
    s.source_files = "Module/**/*.{swift}"
    
    s.osx.deployment_target  = '10.15'

    s.test_spec 'Tests' do |s|
      s.source_files = 'Tests/**/*.swift'
    end
end
