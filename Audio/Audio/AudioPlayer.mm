//
//  AudioPlayer.m
//  Audio
//
//  Created by janezhuang on 2021/12/3.
//

#import "AudioPlayer.h"

static void HandleOutputBuffer (
    void                 *aqData,                 // 1
    AudioQueueRef        inAQ,                    // 2
    AudioQueueBufferRef  inBuffer                 // 3
) {
    AudioPlayer *player = (__bridge AudioPlayer *)aqData;
    AQPlayerState state = player->m_state;        // 1

    if (player.data.length > 0) {                                     // 5
        UInt32 dataByteSize = MIN((UInt32)player.data.length, state.bufferByteSize);
        inBuffer->mAudioDataByteSize = dataByteSize;  // 6
        [player.data getBytes:inBuffer->mAudioData length:dataByteSize];
        [player.data replaceBytesInRange:NSMakeRange(0, dataByteSize) withBytes:NULL length:0];
        
        AudioQueueEnqueueBuffer (
            state.audioQueue,
            inBuffer,
            0,
            0
        );
    } else {
        AudioQueueStop (
            state.audioQueue,
            false
        );
        state.isRunning = NO;
    }
}

void DeriveBufferSize (
    AudioStreamBasicDescription &ASBDesc,                            // 1
    UInt32                      maxPacketSize,                       // 2
    Float64                     seconds,                             // 3
    UInt32                      *outBufferSize,                      // 4
    UInt32                      *outNumPacketsToRead                 // 5
) {
    static const int maxBufferSize = 0x50000;                        // 6
    static const int minBufferSize = 0x4000;                         // 7
 
    if (ASBDesc.mFramesPerPacket != 0) {                             // 8
        Float64 numPacketsForTime =
            ASBDesc.mSampleRate / ASBDesc.mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    } else {                                                         // 9
        *outBufferSize =
            maxBufferSize > maxPacketSize ?
                maxBufferSize : maxPacketSize;
    }
 
    if (                                                             // 10
        *outBufferSize > maxBufferSize &&
        *outBufferSize > maxPacketSize
    )
        *outBufferSize = maxBufferSize;
    else {                                                           // 11
        if (*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
 
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;           // 12
}

@interface AudioPlayer ()

@end

@implementation AudioPlayer
- (id)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.data = [NSMutableData dataWithContentsOfFile:filePath];
        [self _prepareForPlay];
    }
    return self;
}

- (void)dealloc {
    AudioQueueDispose (                                 // 1
        m_state.audioQueue,                             // 2
        true                                            // 3
    );
}

- (void)_prepareForPlay {
    AudioStreamBasicDescription dataFormat;
    dataFormat.mFormatID         = kAudioFormatLinearPCM; // 2
    dataFormat.mSampleRate       = 44100.0;               // 3
    dataFormat.mChannelsPerFrame = 2;                     // 4
    dataFormat.mBitsPerChannel   = 16;                    // 5
    dataFormat.mBytesPerPacket   =                        // 6
       dataFormat.mBytesPerFrame =
          dataFormat.mChannelsPerFrame * sizeof (SInt16);
    dataFormat.mFramesPerPacket  = 1;                     // 7
    dataFormat.mFormatFlags =                             // 8
        kLinearPCMFormatFlagIsBigEndian
        | kLinearPCMFormatFlagIsSignedInteger
        | kLinearPCMFormatFlagIsPacked;
    m_state.dataFormat = dataFormat;
    
    AudioQueueNewOutput (                                // 1
        &m_state.dataFormat,                             // 2
        HandleOutputBuffer,                              // 3
        (__bridge void *)self,                                         // 4
        CFRunLoopGetCurrent(),                          // 5
        kCFRunLoopCommonModes,                           // 6
        0,                                               // 7
        &m_state.audioQueue                                   // 8
    );
    
    UInt32 numPacketsToRead = 0;
    DeriveBufferSize (                                   // 6
        m_state.dataFormat,                              // 7
        m_state.dataFormat.mBytesPerPacket,                                   // 8
        0.5,                                             // 9
        &m_state.bufferByteSize,                          // 10
        &numPacketsToRead                        // 11
    );
    for (int i = 0; i < kAudioPlayerNumberBuffers; ++i) {                // 2
        AudioQueueAllocateBuffer (                            // 3
            m_state.audioQueue,                                    // 4
            m_state.bufferByteSize,                            // 5
            &m_state.buffers[i]                               // 6
        );
     
        HandleOutputBuffer (                                  // 7
            (__bridge void *)self,                                          // 8
            m_state.audioQueue,                                    // 9
            m_state.buffers[i]                                // 10
        );
    }
    
    Float32 gain = 1.0;                                       // 1
        // Optionally, allow user to override gain setting here
    AudioQueueSetParameter (                                  // 2
        m_state.audioQueue,                                        // 3
        kAudioQueueParam_Volume,                              // 4
        gain                                                  // 5
    );
}

- (void)start {
    m_state.isRunning = YES;
    AudioQueueStart (                                  // 2
        m_state.audioQueue,                            // 3
        NULL                                           // 4
    );
}

- (void)stop {
    AudioQueueStop (
        m_state.audioQueue,
        false
    );
    m_state.isRunning = NO;
}
@end
