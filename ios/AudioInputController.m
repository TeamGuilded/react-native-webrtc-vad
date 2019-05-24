

#import <AVFoundation/AVAudioSession.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "AudioInputController.h"

@implementation AudioInputController {
    AudioComponentInstance remoteIOUnit;
    BOOL isInitialized;
}

- (void)dealloc {
    NSLog(@"[AudioInputController][dealloc]");
    AudioComponentInstanceDispose(remoteIOUnit);
}

+ (instancetype) sharedInstance {
    static AudioInputController *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (OSStatus) start {
    return AudioOutputUnitStart(self->remoteIOUnit);
}

- (OSStatus) stop {
    return AudioOutputUnitStart(self->remoteIOUnit);
}

- (OSStatus) prepareWithSampleRate:(double)desiredSampleRate {
    NSLog(@"[WebRTCVad] sampleRate = %f", desiredSampleRate);

    AVAudioSession *session = [AVAudioSession sharedInstance];
    double sampleRate = session.sampleRate;

    NSLog(@"hardware sample rate = %f, using specified rate = %f", sampleRate, desiredSampleRate);

    if (desiredSampleRate){
        sampleRate = desiredSampleRate;
    }

    // Store audio sample rate for later use
    self.audioSampleRate = sampleRate;

    NSError *error;
    BOOL ok = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];

    NSLog(@"set category %d", ok);

    // 5 second audio buffer hint
    [session setPreferredIOBufferDuration:5 error:&error];

    return [self _initializeAudioGraph];
}

- (OSStatus) _initializeAudioGraph {
    OSStatus status = noErr;

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
        status = AudioComponentInstanceNew(remoteIOComponent, &(self->remoteIOUnit));
        if (_checkError(status, "Couldn't get RemoteIO unit instance")) {
            return status;
        }
    }

    double sampleRate = self.audioSampleRate;

    UInt32 enabledFlag = 1;
    AudioUnitElement bus0 = 0;
    AudioUnitElement bus1 = 1;

    // Configure the RemoteIO unit for input
    status = AudioUnitSetProperty(self->remoteIOUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  bus1,
                                  &enabledFlag,
                                  sizeof(enabledFlag));
    if (_checkError(status, "Couldn't enable RemoteIO input")) {
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
    if (_checkError(status, "Couldn't set the ASBD for RemoteIO on input scope/bus 0")) {
        return status;
    }

    // Set format for mic input (bus 1) on RemoteIO's output scope
    status = AudioUnitSetProperty(self->remoteIOUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  bus1,
                                  &asbd,
                                  sizeof(asbd));
    if (_checkError(status, "Couldn't set the ASBD for RemoteIO on output scope/bus 1")) {
        return status;
    }

    // Set the recording callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = _recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *) self;
    status = AudioUnitSetProperty(self->remoteIOUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  bus1,
                                  &callbackStruct,
                                  sizeof (callbackStruct));
    if (_checkError(status, "Couldn't set RemoteIO's render callback on bus 0")) {
        return status;
    }

    // Initialize the RemoteIO unit
    status = AudioUnitInitialize(self->remoteIOUnit);
    if (_checkError(status, "Couldn't initialize the RemoteIO unit")) {
        return status;
    }

    return status;
}


static OSStatus _recordingCallback(void *inRefCon,
                                   AudioUnitRenderActionFlags *ioActionFlags,
                                   const AudioTimeStamp *inTimeStamp,
                                   UInt32 inBusNumber,
                                   UInt32 inNumberFrames,
                                   AudioBufferList *ioData) {
    OSStatus status;

    AudioInputController *audioInputController = (__bridge AudioInputController *) inRefCon;

    int channelCount = 1;

    // build the AudioBufferList structure
    AudioBufferList *bufferList = (AudioBufferList *) malloc (sizeof (AudioBufferList));
    bufferList->mNumberBuffers = channelCount;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[0].mDataByteSize = inNumberFrames * 2;
    bufferList->mBuffers[0].mData = NULL;

    // get the recorded samples
    status = AudioUnitRender(audioInputController->remoteIOUnit,
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
        [audioInputController.delegate processSampleData:data];
    });

    return noErr;
}

static OSStatus _checkError(OSStatus error, const char *operation)
{
    // TODO: Use resolver to throw errors
    if (error == noErr) {
        return error;
    }

    NSLog(@"Error: %d (%s)\n", operation);
    return error;
}

@end

