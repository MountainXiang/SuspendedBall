Pod::Spec.new do |s|
  s.name          = "SuspendedBall"
  s.version       = "0.0.1"
  s.summary       = "SuspendedBall,just like assistive touch in iPhone"
  s.homepage      = "http://www.blog.sina.com.cn/xiangdashan"
  s.license       = "MIT"
  s.author        = { "dashan.xiang" => "783600983@qq.com" }
  s.source        = { :git => "https://github.com/MountainXiang/SuspendedBall.git", :tag => "#{s.version}" }
  s.source_files  = "SuspendedBall/*.{h,m}"
  s.requires_arc  =  true
  s.ios.deployment_target = '7.0'
  s.dependency "SDWebImage"
end
