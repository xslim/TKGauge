Pod::Spec.new do |s|
  s.name     = 'TKGauge'
  s.version  = '0.0.1'
  s.platform = :ios
  s.license = 'MIT'
  s.summary  = 'iOS UI component to display gauge'
  s.homepage = 'https://github.com/xslim/TKGauge'
  s.authors   = {
    'Taras Kalapun' => 'http://kalapun.com'
  }
  s.source   = { :git => 'git://github.com/xslim/TKGauge.git' }
  s.source_files = 'TK*.{h,m}'
  s.requires_arc = true
end
