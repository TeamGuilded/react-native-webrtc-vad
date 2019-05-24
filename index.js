
import { NativeModules } from 'react-native';
import Promise from 'bluebird';

const { RNWebrtcVad } = NativeModules;

export default class index {
  static start(options){
    RNWebrtcVad.start(options);
  }

  static stop(){
    RNWebrtcVad.stop();
  }
}
