Pod::Spec.new do |spec|
  spec.name                  = 'YouTubePlayerKit'
  spec.version               = '1.1.12'
  spec.summary               = 'YouTubePlayerKit 1.1.12 packaged for CocoaPods'
  spec.homepage              = 'https://github.com/quipper-dev/YouTubePlayerKit'
  spec.license               = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors               = 'Sven Tiigi'
  spec.source                = { :git => 'https://github.com/quipper-dev/YouTubePlayerKit.git', :tag => "#{spec.version}-quipper" }
  spec.swift_versions        = ['5.0']
  spec.weak_frameworks       = 'SwiftUI'
  spec.ios.deployment_target = '15.0'
  spec.source_files          = 'Sources/**/*.{swift}'
  spec.resource_bundles      = {
    'YouTubePlayerKit' => ['Sources/Resources/**/*.{html}']
  }
  spec.static_framework      = true
end
