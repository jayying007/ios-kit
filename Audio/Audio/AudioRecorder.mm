//
//  AudioRecorder.m
//  Audio
//
//  Created by janezhuang on 2021/12/3.
//

#import "AudioRecorder.h"

static void HandleInputBuffer (
    void                                *aqData,             // 1
    AudioQueueRef                       inAQ,                // 2
    AudioQueueBufferRef                 inBuffer,            // 3
    const AudioTimeStamp                *inStartTime,        // 4
    UInt32                              inNumPackets,        // 5
    const AudioStreamPacketDescription  *inPacketDesc        // 6
) {
    AudioRecorder *recorder = (__bridge AudioRecorder *)aqData;
    AQRecorderState state = recorder->m_state;
    
    if (inNumPackets == 0 && state.dataFormat.mBytesPerPacket != 0) {
        inNumPackets = inBuffer->mAudioDataByteSize / state.dataFormat.mBytesPerPacket;
    }
    
    if (inBuffer->mAudioDataByteSize > 0) {
        NSData *data = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        [recorder.delegate audioRecorder:recorder didReceiveData:data];
    }
    
    AudioQueueEnqueueBuffer (                        // 6
        state.audioQueue,                          // 7
        inBuffer,                          // 8
        0,                                           // 9
        NULL                                         // 10
    );
}

void DeriveBufferSize (
    AudioQueueRef                audioQueue,                  // 1
    AudioStreamBasicDescription  &ASBDescription,             // 2
    Float64                      seconds,                     // 3
    UInt32                       *outBufferSize               // 4
) {
    static const int maxBufferSize = 0x50000;                 // 5
 
    int maxPacketSize = ASBDescription.mBytesPerPacket;       // 6
    if (maxPacketSize == 0) {                                 // 7
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty (
                audioQueue,
                kAudioQueueProperty_MaximumOutputPacketSize,
                &maxPacketSize,
                &maxVBRPacketSize
        );
    }
 
    Float64 numBytesForTime =
        ASBDescription.mSampleRate * maxPacketSize * seconds; // 8
    *outBufferSize =
    UInt32 (numBytesForTime < maxBufferSize ?
        numBytesForTime : maxBufferSize);                     // 9
}

@implementation AudioRecorder
- (instancetype)init {
    self = [super init];
    if (self) {
        [self _prepareForRecord];
    }
    return self;
}

- (void)dealloc {
    AudioQueueDispose (                                 // 1
        m_state.audioQueue,                             // 2
        true                                            // 3
    );
}

- (void)_prepareForRecord {
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
    
    AudioQueueNewInput (                       // 1
        &m_state.dataFormat,                   // 2
        HandleInputBuffer,                     // 3
        (__bridge void *)self,                 // 4
        NULL,                                  // 5
        kCFRunLoopCommonModes,                 // 6
        0,                                     // 7
        &m_state.audioQueue                    // 8
    );
    
    DeriveBufferSize (                               // 1
        m_state.audioQueue,                          // 2
        m_state.dataFormat,                          // 3
        0.5,                                         // 4
        &m_state.bufferByteSize                      // 5
    );
    for (int i = 0; i < kAudioRecorderNumberBuffers; ++i) {           // 1
        AudioQueueAllocateBuffer (                       // 2
            m_state.audioQueue,                          // 3
            m_state.bufferByteSize,                      // 4
            &m_state.buffers[i]                          // 5
        );
        //Buffer回到Buffer Queue中
        AudioQueueEnqueueBuffer (                        // 6
            m_state.audioQueue,                          // 7
            m_state.buffers[i],                          // 8
            0,                                           // 9
            NULL                                         // 10
        );
    }
}

- (void)start {
    m_state.isRunning = YES;
    AudioQueueStart (                                    // 3
        m_state.audioQueue,                              // 4
        NULL                                             // 5
    );
}

- (void)stop {
    AudioQueueStop (                                     // 6
        m_state.audioQueue,                              // 7
        true                                             // 8
    );
    m_state.isRunning = NO;
}
@end
