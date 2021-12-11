//
//  AudioPlayer.h
//  Audio
//
//  Created by janezhuang on 2021/12/3.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>

SInt16 const kAudioPlayerNumberBuffers = 3;

NS_ASSUME_NONNULL_BEGIN

typedef struct AQPlayerState {
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef _Nonnull buffers[kAudioPlayerNumberBuffers];
    UInt32 bufferByteSize;
    BOOL isRunning;
} AQPlayerState;

@interface AudioPlayer : NSObject {
    @public
    AQPlayerState m_state;
}
@property (nonatomic) NSMutableData *data;

- (id)initWithFilePath:(NSString *)filePath;
- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
