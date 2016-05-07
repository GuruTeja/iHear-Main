//
//  DemoViewController.m
//  VoiceChangerDemo
//
//  Created by DLL on 14-5-6.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import "VoiceChangeController.h"

@interface VoiceChangeController () <RecordingDelegate, PlayingDelegate>


@property (nonatomic, weak) IBOutlet UIProgressView *levelMeter;
@property (nonatomic, weak) IBOutlet UILabel *consoleLabel;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UISlider *sliderPitch;
@property (nonatomic, weak) IBOutlet UISlider *sliderRate;
@property (nonatomic, weak) IBOutlet UISlider *sliderTempo;
@property (nonatomic, weak) IBOutlet UILabel *labelPitch;
@property (nonatomic, weak) IBOutlet UILabel *labelRate;
@property (nonatomic, weak) IBOutlet UILabel *labelTempo;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, copy) NSString *filename;

- (IBAction)recordButtonClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;

@end

@implementation VoiceChangeController {
    VoiceChanger *_voiceChanger;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _voiceChanger = [[VoiceChanger alloc] init];
	
    self.title = @"Speex";
    
    self.levelMeter.progress = 0;
    
    self.consoleLabel.numberOfLines = 0;
    self.consoleLabel.text = @"A demo for recording and playing speex audio.";
    
    [self.recordButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (IBAction)recordButtonClicked:(id)sender {
    if (self.isPlaying) {
        return;
    }
    if ( ! self.isRecording) {
        self.isRecording = YES;
        self.consoleLabel.text = @"RECORDING";
        [RecorderManager sharedManager].delegate = self;
        [[RecorderManager sharedManager] startRecordingWithFilePath:[NSString stringWithString:[RecorderManager defaultFileName]] andVoiceChanger:_voiceChanger];
    }
    else {
        self.isRecording = NO;
        [[RecorderManager sharedManager] stopRecording];
    }
    [self.recordButton setTitle:(self.isRecording ? @"Stop recording" : @"recording") forState:UIControlStateNormal];
}

- (IBAction)playButtonClicked:(id)sender {
    if (self.isRecording) {
        return;
    }
    if ( ! self.isPlaying) {
        [PlayerManager sharedManager].delegate = nil;
        
        self.isPlaying = YES;
        self.consoleLabel.text = [NSString stringWithFormat:@"Now Playing: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]];
        [[PlayerManager sharedManager] playAudioWithFileName:self.filename delegate:self];
    }
    else {
        self.isPlaying = NO;
        [[PlayerManager sharedManager] stopPlaying];
    }
    [self.playButton setTitle:(self.isPlaying ? @"Stop" : @"braodcast") forState:UIControlStateNormal];
}

#pragma mark - Recording & Playing Delegate

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval {
    self.isRecording = NO;
    self.levelMeter.progress = 0;
    self.filename = filePath;
    [self.consoleLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"The recording is finished: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]] waitUntilDone:NO];
    NSLog(@"The recording is finished");
}

- (void)recordingTimeout {
    self.isRecording = NO;
    self.consoleLabel.text = @"recorded time out";
}

- (void)recordingStopped {
    self.isRecording = NO;
}

- (void)recordingFailed:(NSString *)failureInfoString {
    self.isRecording = NO;
    self.consoleLabel.text = @"recording fail";
}

- (void)levelMeterChanged:(float)levelMeter {
    self.levelMeter.progress = levelMeter;
}

- (void)playingStoped {
    self.isPlaying = NO;
    self.consoleLabel.text = [NSString stringWithFormat:@"Play completion: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]];
    [self.playButton setTitle:@"Broadcast" forState:UIControlStateNormal];
}

- (IBAction)pitchValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _labelPitch.text = [NSString stringWithFormat:@"%f", slider.value];
    _voiceChanger.pitch = slider.value;
}

- (IBAction)rateValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _labelRate.text = [NSString stringWithFormat:@"%f", slider.value];
    _voiceChanger.rate = slider.value;
}

- (IBAction)tempoValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _labelTempo.text = [NSString stringWithFormat:@"%f", slider.value];
    _voiceChanger.tempo = slider.value;
}

- (IBAction)reset:(id)sender
{
    _sliderPitch.value = 0;
    _sliderRate.value = 1;
    _sliderTempo.value = 1;
    _labelPitch.text = @"0";
    _labelRate.text = @"1";
    _labelTempo.text = @"1";
}

@end
