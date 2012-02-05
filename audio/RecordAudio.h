//
//  RecordAudio.h
//  JuuJuu
//
//  Created by xiaoguang huang on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "JDataType.h"

@interface RecordAudio : NSObject <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    //Variables setup for access in the class:
	NSURL * recordedTmpFile;
	AVAudioRecorder * recorder;
	NSError * error;
    AVAudioPlayer * avPlayer;
    JTarget target;
}

@property (nonatomic,assign)JTarget target;

- (NSURL *) stopRecord ;
- (void) startRecord;

-(void) play:(NSData*) data target:(JTarget)aTarget;
-(void) stopPlay;
+(NSTimeInterval) getAudioTime:(NSData *) data;
@end
