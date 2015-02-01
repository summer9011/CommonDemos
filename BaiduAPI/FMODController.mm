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

#define NUM_COLUMNS 50
#define NUM_ROWS 25

NSMutableString *gOutputBuffer;
bool gSuspendState;

void interruptionListenerCallback(void *inUserData, UInt32 interruptionState) {
    if (interruptionState == kAudioSessionBeginInterruption)
    {
        gSuspendState = true;
    }
    else if (interruptionState == kAudioSessionEndInterruption)
    {
        UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        AudioSessionSetActive(true);
        
        gSuspendState = false;
    }
}

void Common_Init(void **extraDriverData) {
    gSuspendState = false;
    gOutputBuffer = [NSMutableString stringWithCapacity:(NUM_COLUMNS * NUM_ROWS)];
    
    AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, NULL);
    
    // Default to 'play and record' so we have recording available for examples that use it
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    AudioSessionSetActive(true);
}

const char *Common_MediaPath(NSString *fileName,NSString *ext) {
    return [[[NSBundle mainBundle] pathForResource:fileName ofType:ext] UTF8String];
}

void Common_LoadFileMemory(const char *name, void **buff, int *length) {
    FILE *file = fopen(name, "rb");
    
    fseek(file, 0, SEEK_END);
    long len = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    void *mem = malloc(len);
    fread(mem, 1, len, file);
    
    fclose(file);
    
    *buff = mem;
    *length = (int)len;
}

void Common_UnloadFileMemory(void *buff) {
    free(buff);
}

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
    void *extradriverdata=0;
    
    Common_Init(&extradriverdata);
    
    //初始化System
    result=FMOD::System_Create(&system);
    ERRCHECK(result);
    
    result=system->getVersion(&version);
    ERRCHECK(result);
    
    if (version<FMOD_VERSION) {
        fprintf(stderr, "You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
        exit(-1);
    }
    
    result=system->init(32, FMOD_INIT_NORMAL, extradriverdata);
    ERRCHECK(result);
}

- (IBAction)playWithFMOD:(id)sender {
    int length=0;
    void *buff=0;
    
    Common_LoadFileMemory(Common_MediaPath(@"snare", @"wav"), &buff, &length);
    
    //设置dls文件
    FMOD_CREATESOUNDEXINFO soundExInfo;
    memset(&soundExInfo, 0, sizeof(FMOD_CREATESOUNDEXINFO));
    soundExInfo.cbsize=sizeof(FMOD_CREATESOUNDEXINFO);
    soundExInfo.dlsname=[[[NSBundle mainBundle] pathForResource:@"gm" ofType:@"dls"] UTF8String];
    soundExInfo.length=length;
    
    
    result=system->createSound((const char *)buff, FMOD_OPENMEMORY | FMOD_LOOP_OFF, &soundExInfo, &sound);
    ERRCHECK(result);
    Common_UnloadFileMemory(buff);
    
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
