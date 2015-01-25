//
//  FMODController.m
//  BaiduAPI
//
//  Created by 赵立波 on 15/1/25.
//  Copyright (c) 2015年 赵立波. All rights reserved.
//

#import "FMODController.h"

#import <AudioToolbox/AudioSession.h>
#import "fmod.hpp"
#import "fmod_errors.h"

#import <AVFoundation/AVFoundation.h>

void ERRCHECK(FMOD_RESULT result) {
    if (result != FMOD_OK) {
        fprintf(stderr, "FMOD error! (%d) %s ", result, FMOD_ErrorString(result));
        exit(-1);
    }
}

@interface FMODController () {
    FMOD::System *system;
    FMOD::Sound *sound;
    FMOD::Channel *channel;
    FMOD_RESULT result;
    FMOD_CREATESOUNDEXINFO soundExInfo;
}

@end

@implementation FMODController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    result=FMOD_OK;
    system=NULL;
    sound=NULL;
    channel=NULL;
    
    unsigned int version=0;
    
    //初始化System
    result=FMOD::System_Create(&system);
    ERRCHECK(result);
    
    result=system->getVersion(&version);
    ERRCHECK(result);
    
    if (version<FMOD_VERSION) {
        fprintf(stderr, "You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
        exit(-1);
    }
    
    result=system->init(32, FMOD_INIT_NORMAL, NULL);
    ERRCHECK(result);
    
    //设置dls文件
    memset(&soundExInfo, 0, sizeof(FMOD_CREATESOUNDEXINFO));
    soundExInfo.cbsize=sizeof(FMOD_CREATESOUNDEXINFO);
    soundExInfo.dlsname=[[[NSBundle mainBundle] pathForResource:@"gm" ofType:@"dls"] UTF8String];
    
    //添加第一个MIDI文件
    result=system->createSound([[[NSBundle mainBundle] pathForResource:@"fpc_DrumAndBass_01" ofType:@"mid"] UTF8String], FMOD_DEFAULT, &soundExInfo, &sound);
    ERRCHECK(result);
    result=sound->setMode(FMOD_LOOP_OFF);
    ERRCHECK(result);

    //播放
    result=system->playSound(sound, 0, false, &channel);
    ERRCHECK(result);
}

- (IBAction)doPlayMIDI:(id)sender {
    
    NSLog(@"%@",[[NSBundle mainBundle] pathForResource:@"gm" ofType:@"dls"]);
    
    NSData *midiData=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fpc_DrumAndBass_01" ofType:@"mid"]];
    NSURL *url=[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"gm" ofType:@"dls"]];
    
    NSError *error;
    AVMIDIPlayer *avMIDIPlayer=[[AVMIDIPlayer alloc] initWithData:midiData soundBankURL:url error:&error];
    
    if (error) {
        NSLog(@"error %@",error);
    }
    
    [avMIDIPlayer prepareToPlay];
    [avMIDIPlayer play:^{
        NSLog(@"done");
    }];
}

@end
