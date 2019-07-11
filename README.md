
# react-native-webrtc-vad

## Getting started

`$ npm install react-native-webrtc-vad --save`

### Mostly automatic installation

`$ react-native link react-native-webrtc-vad`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-webrtc-vad` and add `RNWebrtcVad.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNWebrtcVad.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.guilded.gg.RNWebrtcVadPackage;` to the imports at the top of the file
  - Add `new RNWebrtcVadPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-webrtc-vad'
  	project(':react-native-webrtc-vad').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-webrtc-vad/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-webrtc-vad')
  	```


## Usage
```javascript

// SomeJSFile.js

import RNWebrtcVad from 'react-native-webrtc-vad';

// TO START:
// Starts voice activity detection using input audio source on device
RNWebrtcVad.start();
RNWebrtcVad.addEventListener('speakingUpdate', _handleSpeakingUpdate);

// other code..

_handleSpeakingUpdate = ({isVoice} = {}) => {
    this.isSpeaking = !!isVoice;
};

// TO STOP:
// Stops voice activity detection
RNWebrtcVad.stop();
WebRtcVad.removeEventListener('speakingUpdate', _handleSpeakingUpdate);


```
