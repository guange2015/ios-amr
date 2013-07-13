//
//  DemoViewController.m
//  ios-arm
//
//  Created by huang xiaoguang on 13-7-13.
//  Copyright (c) 2013年 huang xiaoguang. All rights reserved.
//

#import "DemoViewController.h"
#import "RecordAudio.h"

@interface DemoViewController ()<RecordAudioDelegate>{
    RecordAudio *recordAudio;
    NSData *curAudio;
    BOOL isRecording;
}
@end

@implementation DemoViewController

static double startRecordTime=0;
static double endRecordTime=0;

-(void)showMsg:(NSString *)msg {
    self.msgLabel.text = msg;
}

-(void) startRecord {
    [recordAudio stopPlay];
    [recordAudio startRecord];
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    
    [curAudio release],curAudio=nil;
    [self showMsg:@"开始录音。。。"];
}


-(void)stopRecord {
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSURL *url = [recordAudio stopRecord];
    
    endRecordTime -= startRecordTime;
    if (endRecordTime<2.00f) {
        NSLog(@"录音时间过短");
        [self showMsg:@"录音时间过短,应大于2秒"];
        return;
    } else if (endRecordTime>30.00f){
        [self showMsg:@"录音时间过长,应小于30秒"];
        return;
    }
    
    
    if (url != nil) {
        curAudio = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url],1,16);
        if (curAudio) {
            [curAudio retain];
        }
    }
    
    if (curAudio.length >0) {
        
    } else {
        
    }
}


- (IBAction)RecordVoice:(id)sender {
    if (!isRecording) {
        [self.recordbtn setTitle:@"录音中，点击停止" forState:UIControlStateNormal];
        [self startRecord];
    } else {
        [self.recordbtn setTitle:@"录制arm" forState:UIControlStateNormal];
        [self stopRecord];
    }
    
    isRecording = !isRecording;
}

- (IBAction)PlayVoice:(id)sender {
    if(curAudio.length>0)[recordAudio play:curAudio];
}

-(void)RecordStatus:(int)status {
    if (status==0){
        //播放中
    } else if(status==1){
        //完成
        NSLog(@"播放完成");
    }else if(status==2){
        //出错
        NSLog(@"播放出错");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	recordAudio = [[RecordAudio alloc]init];
    recordAudio.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_msgLabel release];
    [_recordbtn release];
    [super dealloc];
}
@end
