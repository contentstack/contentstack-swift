#
# Be sure to run `pod lib lint ContentstackSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
#!/usr/bin/ruby


Pod::Spec.new do |s|
  s.name             = 'ContentstackSwift'
  s.version          = '2.0.1'
  s.summary          = 'Contentstack is a headless CMS with an API-first approach that puts content at the centre.'

  s.description      = <<-DESC
  Contentstack is a headless CMS with an API-first approach that puts content at the centre. It is designed to simplify the process of publication by separating code from content.
  In a world where content is consumed via countless channels and form factors across mobile, web and IoT. Contentstack reimagines content management by decoupling code from content. Business users manage content – no training or development required. Developers can create cross-platform apps and take advantage of a headless CMS that delivers content through APIs. With an architecture that’s extensible – but without the bloat of legacy CMS – Contentstack cuts down on infrastructure, maintenance, cost and complexity.
  DESC

  s.homepage         = 'https://github.com/contentstack/contentstack-swift'
  s.license          = {
      :type => 'MIT',
      :file => 'LICENSE'
  }
  
  s.authors           = {
    'uttamukkoji' => 'uttamukkoji@gmail.com',
    'Contentstack' => 'support@contentstack.io'
  }
  s.source           = { :git => 'https://github.com/contentstack/contentstack-swift.git', :tag => s.version }
  s.social_media_url = 'https://x.com/Contentstack'
  s.swift_version             = '5.6'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target     = '10.15'
  s.watchos.deployment_target = '6.0'
  s.tvos.deployment_target    = '13.0'


  s.source_files = 'Sources/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
  s.dependency 'ContentstackUtils', '~> 1.3.0'
end

