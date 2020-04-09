
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
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/TeamGuilded/react-native-webrtc-vad.git", :tag => "master" }

  s.source_files  = "ios/**/*.{h,m}"
  s.framework    = "AVFoundation", "AudioToolbox"
  s.requires_arc = true

  s.subspec "webrtc" do |ss|
    ss.header_mappings_dir = "."
    ss.source_files = "webrtc/**/*.{h,m,c}"
    ss.preserve_paths = "webrtc/**/*"
  end

  s.dependency "React"

end


