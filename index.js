
import { NativeModules, Platform, NativeEventEmitter} from 'react-native';
import Promise from 'bluebird';

const { RNWebrtcVad } = NativeModules;
const RNWebrtcVadEmitter = new NativeEventEmitter(RNWebrtcVad);

const EventTypeToNativeEventName = {
  'speakingUpdate': 'RNWebrtcVad_SpeakingUpdate'
}

const EventHandlerListeners = new Map();

export default class index {
  static start(options){
    RNWebrtcVad.start(options);
  }

  static stop(){
    RNWebrtcVad.stop();
  }

 static addEventListener(type, handler) {
    const listener = RNWebrtcVadEmitter.addListener(EventTypeToNativeEventName[type], handler);
    EventHandlerListeners.set(handler, listener);
  }

  static removeEventListener(type, handler) {
    const listener = EventHandlerListeners.get(handler);
    if (!listener) {
        return;
    }

    listener.remove();
    EventHandlerListeners.delete(handler);
  }
}
