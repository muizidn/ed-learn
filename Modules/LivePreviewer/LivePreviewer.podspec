Pod::Spec.new do |s|
    s.name         = "LivePreviewer"
    s.version      = "0.1-dev-internal"
    s.summary      = "A short description of LivePreviewer."
    s.description  = "A long description of LivePreviewer"
    s.homepage     = "https://github.com/muizidn/ed-learn"
    s.license      = { :type => 'Proprietary' }
    s.author       = { 'muizidn' => 'muiz.idn@gmail.com' }
    s.source       = { :git => "", :tag => s.version }
    s.source_files = "**/*.swift"
end
