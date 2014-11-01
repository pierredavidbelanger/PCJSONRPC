Pod::Spec.new do |s|
  s.name = "PCJSONRPC"
  s.version = "0.1.0"
  s.summary = "Simple yet extensible synchronous JSON-RPC client"
  s.homepage = "https://github.com/pierredavidbelanger/PCJSONRPC"
  s.license = 'MIT'
  s.author = { "Pierre-David Bélanger" => "pierredavidbelanger@gmail.com" }
  s.source = { :git => "https://github.com/pierredavidbelanger/PCJSONRPC.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = 'Pod/Classes/*.{h,m}'
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
end
