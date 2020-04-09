
Pod::Spec.new do |s|
  s.name         = "RNWebrtcVad"
  s.version      = "1.0.0"
  s.summary      = "RNWebrtcVad"
  s.description  = <<-DESC
                  RNWebrtcVad
                   DESC
  s.homepage     = "https://www.github.com/TeamGuilded/react-native-webrtc-vad"
  s.license      = "MIT"
  s.author       = "https://github.com/TeamGuilded/react-native-webrtc-vad/graphs/contributors"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/TeamGuilded/react-native-webrtc-vad.git", :tag => "master" }
  s.preserve_paths = "ios/**/*"
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
