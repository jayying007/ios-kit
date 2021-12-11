//
//  AudioUnitPlayer.m
//  Audio
//
//  Created by janezhuang on 2021/12/6.
//

#import "AudioUnitPlayer.h"
#import <AudioToolbox/AUComponent.h>

const int kInputBus = 1;
const int kOutputBus = 0;

//回调函数
static OSStatus outputCallBackFun(void *                          inRefCon,
                                  AudioUnitRenderActionFlags *    ioActionFlags,
                                  const AudioTimeStamp *          inTimeStamp,
                                  UInt32                          inBusNumber,
                                  UInt32                          inNumberFrames,
                                  AudioBufferList * __nullable    ioData) {
    for (int i = 0; i < ioData->mNumberBuffers; i++) {
        //默认播放无声音频
        memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);

        AudioUnitPlayer *player = (__bridge AudioUnitPlayer *)(inRefCon);
        if (player.data.length > 0) {
            AudioBuffer buffer = ioData->mBuffers[i];
            int bufferSize = buffer.mDataByteSize;
            UInt32 dataByteSize = MIN((UInt32)player.data.length, bufferSize);
            buffer.mDataByteSize = dataByteSize;
            [player.data getBytes:buffer.mData length:dataByteSize];
            [player.data replaceBytesInRange:NSMakeRange(0, dataByteSize) withBytes:NULL length:0];
        } else {
            [player stop];
        }
    }

    return noErr;
}

@interface AudioUnitPlayer () {
    AudioUnit m_audioUnit;
}
@end

@implementation AudioUnitPlayer
- (id)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.data = [NSMutableData dataWithContentsOfFile:filePath];
        [self _prepareForPlay];
    }
    return self;
}

- (void)dealloc {
    AudioUnitUninitialize(m_audioUnit);
}

- (void)_prepareForPlay {
    AudioComponentDescription ioUnitDescription;
    ioUnitDescription.componentType          = kAudioUnitType_Output; //设置
    ioUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    ioUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags         = 0;
    ioUnitDescription.componentFlagsMask     = 0;
    //根据音频属性查找音频单元
    AudioComponent foundIoUnitReference = AudioComponentFindNext(NULL, &ioUnitDescription);
    //得到实例
    AudioUnit audioUnit;
    AudioComponentInstanceNew(foundIoUnitReference, &audioUnit);
    m_audioUnit = audioUnit;
    
    //设置speaker enbale
    int outputEnable = 1;
    AudioUnitSetProperty(audioUnit,
                        kAudioOutputUnitProperty_EnableIO,
                        kAudioUnitScope_Output,
                        kOutputBus,   // output bus
                        &outputEnable,
                        sizeof(outputEnable));
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
    //设置播放的格式
    AudioUnitSetProperty(audioUnit,
                        kAudioUnitProperty_StreamFormat,
                        kAudioUnitScope_Input,
                        kOutputBus,
                        &dataFormat,
                        sizeof(dataFormat));
    
    
    //设置播放回调 outputbus下的input scope
    AURenderCallbackStruct outputCallBackStruct;
    outputCallBackStruct.inputProc = outputCallBackFun;
    outputCallBackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Output,
                         kOutputBus,
                         &outputCallBackStruct,
                         sizeof(outputCallBackStruct));
    
    AudioUnitInitialize(audioUnit);
}

- (void)start {
    AudioOutputUnitStart(m_audioUnit); //开始
}

- (void)stop {
    AudioOutputUnitStop(m_audioUnit); //停止
}
@end
