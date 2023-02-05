Pod::Spec.new do |s|
  s.name             = 'ListDiffUI'
  s.version          = '0.1.1'
  s.summary          = 'A descriptive, diffable data source for UICollectionView.'
  s.homepage         = 'https://github.com/siyuyue/ListDiffUI'
  s.author           = 'Siyu Yue'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/siyuyue/ListDiffUI.git', :tag => "#{s.version}" }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*.swift'
  s.dependency 'ListDiff', '~> 0.2.0'
  s.xcconfig = {
    'IPHONEOS_DEPLOYMENT_TARGET' => '11.0',
    'SWIFT_VERSION' => '5.0'
  }
end
