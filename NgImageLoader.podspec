Pod::Spec.new do |spec|
  spec.name         = 'NgImageLoader'
  spec.version      = '1.0.1'
  spec.summary      = 'Objective-c image loader library.'
  spec.homepage     = 'https://github.com/meiwin/NgImageLoader'
  spec.author       = { 'Meiwin Fu' => 'meiwin@blockthirty.com' }
  spec.source       = { :git => 'https://github.com/meiwin/ngimageloader.git', :tag => "v#{spec.version}" }
  spec.source_files = 'NgImageLoader/**/*.{h,m}'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.frameworks   = 'MobileCoreServices', 'ImageIO'
  spec.ios.deployment_target = "7.0"
  spec.dependency 'NgImageFileIO', '~> 1.1'
end