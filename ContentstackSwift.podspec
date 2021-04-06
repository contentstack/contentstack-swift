#
# Be sure to run `pod lib lint ContentstackSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
#!/usr/bin/ruby

require 'dotenv/load'

Pod::Spec.new do |s|
  s.name             = 'ContentstackSwift'
  s.version          = ENV['CONTENTSTACK_SDK_VERSION']
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
  s.source           = { :git => 'https://github.com/contentstack/contentstack-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Contentstack'
  s.swift_version             = '5'

  s.ios.deployment_target = '10.10'
  s.osx.deployment_target     = '10.12'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target    = '10.0'


  s.source_files = 'Sources/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
  # s.dependency 'ContentstackUtils', '~> 1.1.0'
end

