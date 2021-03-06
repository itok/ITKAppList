Pod::Spec.new do |s|
  s.name         = "ITKAppList"
  s.version      = "0.0.3"
  s.summary      = "get application list from AppStore by artist id."
  s.homepage     = "https://github.com/itok/ITKAppList"
  s.license      = 'MIT'
  s.author       = { "itok" => "i@itok.jp" }
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/itok/ITKAppList.git", :tag => "v0.0.3" }
  s.source_files  = 'ITKAppList/*.{m,h}'
end