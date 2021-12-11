//
//  AudioRecorder.h
//  Audio
//
//  Created by janezhuang on 2021/12/3.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>

SInt16 const kAudioRecorderNumberBuffers = 3;

@class AudioRecorder;

NS_ASSUME_NONNULL_BEGIN

typedef struct AQRecorderState {
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef _Nonnull buffers[kAudioRecorderNumberBuffers];
    UInt32 bufferByteSize;
    BOOL isRunning;
} AQRecorderState;

@protocol AudioRecorderDelegate <NSObject>
@required
- (void)audioRecorder:(AudioRecorder *)recorder didReceiveData:(NSData *)data;
@end

@interface AudioRecorder : NSObject {
    @public
    AQRecorderState m_state;
}
@property (nonatomic) id<AudioRecorderDelegate> delegate;

- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
