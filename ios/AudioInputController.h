
#import <Foundation/Foundation.h>

@protocol AudioInputControllerDelegate <NSObject>
- (void) processSampleData:(NSData *) data;
@end

@interface AudioInputController : NSObject
@property (nonatomic) id<AudioInputControllerDelegate> delegate;
@property double audioSampleRate;
@property (nonatomic) dispatch_queue_t audioDataQueue;

+ (instancetype) sharedInstance;

- (OSStatus) _initializeAudioGraph;
- (OSStatus) prepareWithSampleRate:(double)desiredSampleRate;
- (OSStatus) start;
- (OSStatus) stop;
@end
