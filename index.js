
import { NativeModules } from 'react-native';
import Promise from 'bluebird';

const { RNWebrtcVad } = NativeModules;


export default class index {
  static testMethod(options){
    RNWebrtcVad.testMethod(options)
  }
}
