

#import <AVFoundation/AVAudioSession.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#include "../webrtcvad/WVVad.h"
#import "RNWebrtcVad.h"

@implementation RNWebrtcVad {
    AudioComponentInstance remoteIOUnit;
    BOOL isInitialized;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

- (instancetype)init {
    if (self = [super init]) {
        AVAudioSession *_audioSession = [AVAudioSession sharedInstance];
        if(_audioSession == nil){
            NSLog(@"Nill booy");
        }else{
            NSLog(@"Not nill");
        }
    }
    return self;
}

- (void)dealloc {

#ifdef DEBUG
    NSLog(@"[RNWebrtcVad][dealloc]");
#endif
    AudioComponentInstanceDispose(remoteIOUnit);
}

RCT_EXPORT_METHOD(start:(NSDictionary *)options) {
    NSLog(@"[WebRTCVad] starting = %@", options);
    [self _prepareWithSampleRate:0];
    [self _start];
}

RCT_EXPORT_METHOD(stop) {
    NSLog(@"[WebRTCVad] stopping");
    [self _stop];
}

RCT_EXPORT_METHOD(testMethod:(NSDictionary *)options) {
    NSLog(@"[WebRTCVad] options = %@", options);
}


- (OSStatus) _start {
    return AudioOutputUnitStart(self->remoteIOUnit);
}

- (OSStatus) _stop {
    return AudioOutputUnitStart(self->remoteIOUnit);
}

- (OSStatus) _prepareWithSampleRate:(double)desiredSampleRate {


    //   // Checks for valid combinations of |rate| and |frame_length|. We support 10,
    // // 20 and 30 ms frames and the rates 8000, 16000 and 32000 Hz.
    // //
    // // - rate         [i] : Sampling frequency (Hz).
    // // - frame_length [i] : Speech frame buffer length in number of samples.
    // //
    // // returns            : 0 - (valid combination), -1 - (invalid combination)
    // int WebRtcVad_ValidRateAndFrameLength(int rate, int frame_length);

    OSStatus status = noErr;
    NSLog(@"[WebRTCVad] sampleRate = %f", desiredSampleRate);

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];

    double sampleRate = session.sampleRate;
    NSLog(@"hardware sample rate = \(sampleRate), using specified rate = \(desiredSampleRate)");
    if(desiredSampleRate){
        sampleRate = desiredSampleRate;
    }

    NSError *error;
    BOOL ok = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    NSLog(@"set category %d", ok);

    [session setPreferredIOBufferDuration:10 error:&error];

    if (!isInitialized) {
        isInitialized = YES;
        // Describe the RemoteIO unit
        AudioComponentDescription audioComponentDescription;
        audioComponentDescription.componentType = kAudioUnitType_Output;
        audioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
        audioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        audioComponentDescription.componentFlags = 0;
        audioComponentDescription.componentFlagsMask = 0;

        // Get the RemoteIO unit
        AudioComponent remoteIOComponent = AudioComponentFindNext(NULL,&audioComponentDescription);
        status = AudioComponentInstanceNew(remoteIOComponent,&(self->remoteIOUnit));
        if (CheckError(status, "Couldn't get RemoteIO unit instance")) {
            return status;
        }
    }


    UInt32 enabledFlag = 1;
    AudioUnitElement bus0 = 0;
    AudioUnitElement bus1 = 1;

    if (YES) {
        // Configure the RemoteIO unit for playback
        status = AudioUnitSetProperty (self->remoteIOUnit,
                                       kAudioOutputUnitProperty_EnableIO,
                                       kAudioUnitScope_Output,
                                       bus0,
                                       &enabledFlag,
                                       sizeof(enabledFlag));
        if (CheckError(status, "Couldn't enable RemoteIO output")) {
            return status;
        }
    }


    // Configure the RemoteIO unit for input
    status = AudioUnitSetProperty(self->remoteIOUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  bus1,
                                  &enabledFlag,
                                  sizeof(enabledFlag));
    if (CheckError(status, "Couldn't enable RemoteIO input")) {
        return status;
    }

    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mSampleRate = sampleRate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mBytesPerPacket = 2;
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerFrame = 2;
    asbd.mChannelsPerFrame = 1;
    asbd.mBitsPerChannel = 16;

    // Set format for output (bus 0) on the RemoteIO's input scope
    status = AudioUnitSetProperty(self->remoteIOUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  bus0,
                                  &asbd,
                                  sizeof(asbd));
    if (CheckError(status, "Couldn't set the ASBD for RemoteIO on input scope/bus 0")) {
        return status;
    }

    // Set format for mic input (bus 1) on RemoteIO's output scope
    status = AudioUnitSetProperty(self->remoteIOUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  bus1,
                                  &asbd,
                                  sizeof(asbd));
    if (CheckError(status, "Couldn't set the ASBD for RemoteIO on output scope/bus 1")) {
        return status;
    }

    // Set the recording callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = RecordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *) self;
    status = AudioUnitSetProperty(self->remoteIOUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  bus1,
                                  &callbackStruct,
                                  sizeof (callbackStruct));
    if (CheckError(status, "Couldn't set RemoteIO's render callback on bus 0")) {
        return status;
    }

    // Initialize the RemoteIO unit
    status = AudioUnitInitialize(self->remoteIOUnit);
    if (CheckError(status, "Couldn't initialize the RemoteIO unit")) {
        return status;
    }

    return status;
}


static OSStatus RecordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    OSStatus status;

    RNWebrtcVad *instance = (__bridge RNWebrtcVad *) inRefCon;

    int channelCount = 1;

    // build the AudioBufferList structure
    AudioBufferList *bufferList = (AudioBufferList *) malloc (sizeof (AudioBufferList));
    bufferList->mNumberBuffers = channelCount;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[0].mDataByteSize = inNumberFrames * 2;
    bufferList->mBuffers[0].mData = NULL;

    // get the recorded samples
    status = AudioUnitRender(instance->remoteIOUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             bufferList);
    if (status != noErr) {
        return status;
    }

    NSData *data = [[NSData alloc] initWithBytes:bufferList->mBuffers[0].mData
                                          length:bufferList->mBuffers[0].mDataByteSize];
    dispatch_async(dispatch_get_main_queue(), ^{
        [instance.delegate processSampleData:data];
    });

    return noErr;
}

static OSStatus CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) {
        return error;
    }
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else {
        // No, format it as an integer
        //        NSLog(errorString, "%d", (int)error);
    }
    // revisit loggin
    NSLog(@"Error: %s (%s)\n", operation, errorString);
    return error;
}

@end

