//
//  VoiceChangerController.m
//  NVDSPExample
//
//  Created by Mayanka  on 12/6/15.
//  Copyright © 2015 Bart Olsthoorn. All rights reserved.
//

#import "VoiceChangerController.h"

@interface VoiceChangerController () <RecordingDelegate, PlayingDelegate>


@property (nonatomic, assign) IBOutlet UIProgressView *levelMeter;
@property (nonatomic, assign) IBOutlet UILabel *consoleLabel;
@property (nonatomic, assign) IBOutlet UIButton *recordButton;
@property (nonatomic, assign) IBOutlet UIButton *playButton;
@property (nonatomic, assign) IBOutlet UISlider *sliderPitch;
@property (nonatomic, assign) IBOutlet UISlider *sliderRate;
@property (nonatomic, assign) IBOutlet UISlider *sliderTempo;
@property (nonatomic, assign) IBOutlet UILabel *labelPitch;
@property (nonatomic, assign) IBOutlet UILabel *labelRate;
@property (nonatomic, assign) IBOutlet UILabel *labelTempo;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, copy) NSString *filename;

- (IBAction)recordButtonClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;

@end

@implementation VoiceChangerController {
     VoiceChanger *_voiceChanger;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _voiceChanger = [[VoiceChanger alloc] init];
    
    self.title = @"Speex";
    
    self.levelMeter.progress = 0;
    
    self.consoleLabel.numberOfLines = 0;
    self.consoleLabel.text = @"A demo for recording and playing speex audio.";
    
    [self.recordButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
