
#import <Foundation/Foundation.h>

@protocol AudioInputControllerDelegate <NSObject>
- (void) processSampleData:(NSData *) data;
@end

@interface AudioInputController : NSObject
  @property (nonatomic, weak) id<AudioInputControllerDelegate> delegate;
  @property double audioSampleRate;

  + (instancetype) sharedInstance;
  + (OSStatus) _checkError;
  + (OSStatus) _recordingCallback;

  - (OSStatus) _initializeAudioGraph;
  - (OSStatus) prepareWithSampleRate:(double)desiredSampleRate;
  - (OSStatus) start;
  - (OSStatus) stop;
@end
