//
//  AudioUnitPlayer.h
//  Audio
//
//  Created by janezhuang on 2021/12/6.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioUnitPlayer : NSObject
@property (nonatomic) NSMutableData *data;

- (id)initWithFilePath:(NSString *)filePath;
- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
