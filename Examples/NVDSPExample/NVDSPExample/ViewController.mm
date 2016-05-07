//
//  ViewController.m
//  NVDSPExample
//
//  Created by Bart Olsthoorn on 25/04/2013.
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
//

#import "ViewController.h"
#define BLOCKSIZE 32//512 //ArrazSize
#define MAVG_COUNT 10
#define HALF_BLOCKSIZE (BLOCKSIZE >> 1)
#define SAMPLERATE 44100
#define PERIOD 102
#define MFCC_FREQ_BANDS 13
#define MFCC_FREQ_MIN 20
#define MFCC_FREQ_MAX 20000

//audio for Libxtract
NSMutableArray *test = [NSMutableArray array];
NSMutableArray *test1 = [NSMutableArray array];
int ARRAYSIZE = 128; //audio block for Libxtract // for collecting 3 secounds of real data
int Half_BlockSize = ARRAYSIZE/2;
NSUInteger count;
//feature outputs:
double libxtract_Loudness = 0.0;
double libxtract_Flatness = 0.0;
double libxtract_Flatness_Db = 0.0;
double libxtract_Tonality = 0.0;
double libxtract_crest = 0.0;
double libxtract_Varience = 0.0;
double libxtract_StandardDeviation = 0.0;
double libxtract_Averagedeviation = 0.0;
double libxtact_skewness = 0.0;
double libxtract_kurtosis = 0.0;
double libxtract_spectral_mean = 0.0;
double libxtract_spectral_standardDeviation = 0.0;
double libxtract_spectral_varience = 0.0;
double libxtract_spectral_skewness = 0.0;
double libxtract_spectral_kurtosis = 0.0;
double libxtract_spectral_centroid = 0.0;
double libxtract_irregularity_k = 0.0;
double libxtract_irregularity_j = 0.0;
double libxtract_tristimulus_1 = 0.0;
double libxtract_tristimulus_2 = 0.0;
double libxtract_tristimulus_3 = 0.0;
double libxtract_smoothness = 0.0;
double libxtract_spread = 0.0;
double libxtract_zcr = 0.0;
double libxtract_rolloff = 0.0;
double libxtract_lowest_value = 0.0;
double libxtract_highest_value = 0.0;
NSString *featureData;
NSString *featureData1;
double readypauseData = 0;

@interface ViewController ()

@end

@implementation ViewController
int segmentnumber;



- (void)viewDidLoad
{

    [super viewDidLoad];    
    
	// Do any additional setup after loading the view, typically from a nib.
    //For Droplist
    self.data = [[NSArray alloc]initWithObjects:@"High Voice",@"Low Voice",@"High Bass",@"Low Bass", nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

- (void)viewWillAppear:(BOOL)animated
{
    ringBuffer = new RingBuffer(32768, 2);
    audioManager = [Novocaine audioManager];
    
    float samplingRate = audioManager.samplingRate;
    //__block NSUInteger count;
    /* For getting audio from Microphone and playing it back */
    [audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        
        //Pushing input data to AudioBlock for Libxtract
        NSNumber *num = [NSNumber numberWithDouble:*data];
        [test addObject:num];
        NSUInteger count = [test count];
        //if count in test reaches 32 go to feature extraction method
        if(count >= ARRAYSIZE){
           [self featureExtractionbutton];
        }
        //done pushing
        float volume = 0.5;
        vDSP_vsmul(data, 1, &volume, data, 1, numFrames*numChannels);
        ringBuffer->AddNewInterleavedFloatData(data, numFrames, numChannels);
    }];
    
    
    //Puting audio from inputBlock to OutputBlock
    [audioManager setOutputBlock:^(float *outData, UInt32 numFrames, UInt32 numChannels) {
        //NSLog(@"no of frames are: %u", (unsigned int)numFrames);
        //NSLog(@"no of channels are: %u", (unsigned int)numChannels);
        ringBuffer->FetchInterleavedData(outData, numFrames, numChannels);
        
    }];
    
    
    // Audio File Reading
   // NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"TLC" withExtension:@"mp3"];

    HPF = [[NVHighpassFilter alloc] initWithSamplingRate:samplingRate];
    HPF.Q = 0.5f;
    _HPF_cornerFrequency = 2000.0f;
    LPF = [[NVLowpassFilter alloc] initWithSamplingRate:samplingRate];
    _LPF_cornerFrequency = 800.0f;
    LPF.Q = 0.8f;
    BPF = [[NVBandpassFilter alloc] initWithSamplingRate:samplingRate];
    _BPF_centerFrequency = 2500.0f;;
    BPF.Q = 0.9f;

    CDT = [[NVClippingDetection alloc] init];
    
//    fileReader = [[AudioFileReader alloc]
//                  initWithAudioFileURL:inputFileURL 
//                  samplingRate:audioManager.samplingRate
//                  numChannels:audioManager.numOutputChannels];
    
    //playing the output block
    [audioManager play];
    //[fileReader play];  //plays the audio file ,if any changes applied it will apply it and play back from bufferNewAudio method (ringbuffer)
    //fileReader.currentTime = 30.0;
    NSLog(@"in here1");
    [self SegmentControlAction:nil];
}

#pragma mark
#pragma Segmentcontrol

- (IBAction)SegmentControlAction:(id)sender {
    NSLog(@"in here");
    
    switch (_SegmentControl.selectedSegmentIndex) {
        case 0:
            NSLog(@"in High");
            segmentnumber = 1;
            [self segmentControlChanged];
            break;
        case 1:
            NSLog(@"in Low");
            segmentnumber = 2;
            [self segmentControlChanged];
            break;
        case 2:
            NSLog(@"in Band");
            segmentnumber = 3;
            [self segmentControlChanged];
            break;
        default:
            break;
    }
}

#pragma mark
#pragma Slider

- (void)HPFSliderChanged:(UISlider *)sender
{
    _HPF_cornerFrequency = sender.value;
    NSLog(@"\n HPF slider value %f",_HPF_cornerFrequency);
    [self segmentControlChanged];
}

- (void)LPFSliderChanged:(UISlider *)sender {
    _LPF_cornerFrequency = sender.value;
    NSLog(@"\n LPF slider value %f",_LPF_cornerFrequency);
    [self segmentControlChanged];
}

- (IBAction)BPFSliderChanged:(UISlider *)sender {
    _BPF_centerFrequency = sender.value;
    NSLog(@"\n BPF slider value %f",_BPF_centerFrequency);
    [self segmentControlChanged];
}

#pragma mark
#pragma Buttons

- (IBAction)btnAction:(id)sender {
    
    NSLog(@"in here");
    if (![sender isKindOfClass:[UIButton class]])
        return;
    
    NSString *title = [(UIButton *)sender currentTitle];
    
    if([title  isEqual: @"High Voice"]) {
        NSLog(@"in High Voice");
        _HPF_cornerFrequency = 4422.535156f;
        segmentnumber = 1;
        [self segmentControlChanged];
        
    }
    if([title  isEqual: @"Low Voice"]) {
        NSLog(@"in High Voice");
        _BPF_centerFrequency  = 8042.253418f;
        segmentnumber = 3;
        [self segmentControlChanged];
        
    }
    if([title  isEqual: @"High Bass"]) {
        NSLog(@"in High Bass");
        _LPF_cornerFrequency = 01.197174f;
        segmentnumber = 2;
        [self segmentControlChanged];
        
    }
    if([title  isEqual: @"Low Bass"]) {
        NSLog(@"in Low Bass");
        _HPF_cornerFrequency = 01.197174f;
        segmentnumber = 2;
        [self segmentControlChanged];
        
        
    }
    if (self.tableView.hidden == YES) {
        self.tableView.hidden = NO;
    }
    self.tableView.hidden = NO;
}

#pragma Dropbox

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self.btnOutlet setTitle:cell.textLabel.text forState:UIControlStateNormal];
    
    
    //self.tableView.hidden = YES;
    
    
}

#pragma SegmentControl Changed

- (void)segmentControlChanged {
    NSLog(@"segment number is %d",segmentnumber);
    switch (segmentnumber) {
            NSLog(@"in switch case");
        case 1:
        {
            NSLog(@"in High Pass");
            
            //Puting audio from inputBlock to OutputBlock
            [audioManager setOutputBlock:^(float *outData, UInt32 numFrames, UInt32 numChannels) {
                //NSLog(@"data in High Pass outputblock before filter: %f", *outData);
                ringBuffer->FetchInterleavedData(outData, numFrames, numChannels);
                HPF.cornerFrequency = _HPF_cornerFrequency;
                [HPF filterData:outData numFrames:numFrames numChannels:numChannels];
                [CDT counterClipping:outData numFrames:numFrames numChannels:numChannels];
                //NSLog(@"data in High Pass outputblock after filter: %f", *outData);
            }];
//            [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
//             {
//                 //NSLog(@"SetOutputBlock audio data %f",*data);
//                 [fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
//                 HPF.cornerFrequency = _HPF_cornerFrequency;
//                 [HPF filterData:data numFrames:numFrames numChannels:numChannels];
//                 [CDT counterClipping:data numFrames:numFrames numChannels:numChannels];
//             }];
            break;
        }
        case 2:
        {
            NSLog(@"in Low Pass");
            //Puting audio from inputBlock to OutputBlock
            [audioManager setOutputBlock:^(float *outData, UInt32 numFrames, UInt32 numChannels) {
                ringBuffer->FetchInterleavedData(outData, numFrames, numChannels);
                LPF.cornerFrequency = _LPF_cornerFrequency;
                [LPF filterData:outData numFrames:numFrames numChannels:numChannels];
                [CDT counterClipping:outData numFrames:numFrames numChannels:numChannels];
                NSLog(@"data in Low Passoutputblock is after filter: %f", *outData);
            }];
//            [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
//             {
//                 [fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
//                 LPF.cornerFrequency = _LPF_cornerFrequency;
//                 [LPF filterData:data numFrames:numFrames numChannels:numChannels];
//                 [CDT counterClipping:data numFrames:numFrames numChannels:numChannels];
//             }];
            break;
        }
        case 3:
        {
            NSLog(@"in Band Pass");
            //Puting audio from inputBlock to OutputBlock
            [audioManager setOutputBlock:^(float *outData, UInt32 numFrames, UInt32 numChannels) {
                ringBuffer->FetchInterleavedData(outData, numFrames, numChannels);
                BPF.centerFrequency = _BPF_centerFrequency;
                [BPF filterData:outData numFrames:numFrames numChannels:numChannels];
                [CDT counterClipping:outData numFrames:numFrames numChannels:numChannels];
                NSLog(@"data in Band Passoutputblock is after filter: %f", *outData);
            }];
//            [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
//             {
//                 [fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
//                 BPF.centerFrequency = _BPF_centerFrequency;
//                 [BPF filterData:data numFrames:numFrames numChannels:numChannels];
//                 [CDT counterClipping:data numFrames:numFrames numChannels:numChannels];
//             }];
            break;
        }
        default:
        {
            break;
        }
    }
}


#pragma Audio Feature Test

-(void) featureExtractionbutton{
    
    NSLog(@"going to FeatureExtraction :");
    //printing data from Nsmutable array
    NSUInteger count = [test count];
    //NSLog(@"Count in Test mutablearray: %lu", (unsigned long)count);
    for(int i=0;i<count;i++)
    {
        id item;
        item = [test objectAtIndex:i];
        if(i < ARRAYSIZE){
            test1[i] = item;
        }
        
    }
    
    NSUInteger count1 = [test1 count];
    //NSLog(@"Count in Test1 mutablearray: %lu", (unsigned long)count1);
    for(int j=0;j<count1;j++){
        id item1;
        item1 = [test1 objectAtIndex:j];
        //NSLog(@"obj in test1 mutable array is:%@",item1);
        
    }
    featureExtraction();
    //freeing Mutable Arrays
    [test removeAllObjects];
    [test1 removeAllObjects];
    
}

- (IBAction)featureExtraction_button:(id)sender {
    
    NSLog(@"going to FeatureExtraction :");
    //printing data from Nsmutable array
    NSUInteger count = [test count];
    //NSLog(@"Count in Test mutablearray: %lu", (unsigned long)count);
    for(int i=0;i<count;i++)
    {
        id item;
        item = [test objectAtIndex:i];
        if(i < ARRAYSIZE){
            test1[i] = item;
        }
        
    }
    
    NSUInteger count1 = [test1 count];
    //NSLog(@"Count in Test1 mutablearray: %lu", (unsigned long)count1);
    for(int j=0;j<count1;j++){
        id item1;
        item1 = [test1 objectAtIndex:j];
        //NSLog(@"obj in test1 mutable array is:%@",item1);

    }
    featureExtraction();
    //freeing Mutable Arrays
    [test removeAllObjects];
    [test1 removeAllObjects];
    
}

- (NSURL *)applicationDocumentsDirectory1 {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

#pragma For Libxtract audioData
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        audioData4Libxtract = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma LibXtract Example for Audio Feature Extraction

using namespace std;

typedef enum waveform_type_
{
    SINE,
    SAWTOOTH,
    SQUARE,
    NOISE
}
waveform_type;

double wavetable[BLOCKSIZE];

void fill_wavetable(const float frequency, waveform_type type)
{
    
    int samples_per_period = SAMPLERATE / frequency;
    
    for (int i = 0; i < BLOCKSIZE; ++i)
    {
        int phase = i % samples_per_period;
        
        switch (type)
        {
            case SINE:
                wavetable[i] = sin((phase / (double)PERIOD) * 2 * M_PI);
                break;
            case SQUARE:
                if (phase < (samples_per_period / 2.f))
                {
                    wavetable[i] = -1.0;
                }
                else
                {
                    wavetable[i] = 1.0;
                }
                break;
            case SAWTOOTH:
                wavetable[i] = ((phase / (double)PERIOD) * 2) - 1.;
                break;
            case NOISE:
                wavetable[i] = ((random() % 1000) / 500.0) - 1;
                break;
        }
    }
}

void print_wavetable(void)
{
    for (int i = 0; i < BLOCKSIZE; ++i)
    {
        printf("%f\n", wavetable[i]);
    }
}

int featureExtraction()
{
    printf("in feature Extraction function");
    double mean = 0.0;
    double f0 = 0.0;
    double midicents = 0.0;
    double flux = 0.0;
    double centroid = 0.0;
    double lowest = 0.0;
    double spectrum[BLOCKSIZE] = {0};
    double windowed[BLOCKSIZE] = {0};
    double peaks[BLOCKSIZE] = {0};
    double harmonics[BLOCKSIZE] = {0};
    double subframes_windowed[BLOCKSIZE] = {0};
    double subframes_spectrum[BLOCKSIZE] = {0};
    double difference[HALF_BLOCKSIZE] = {0};
    double lastn[MAVG_COUNT] = {0};
    double *window = NULL;
    double *window_subframe = NULL;
    double mfccs[MFCC_FREQ_BANDS] = {0};
    double argd[4] = {0};
    double samplerate = 44100.0;
    double prev_note = 0.0;
    int n;
    int rv = XTRACT_SUCCESS;
    double last_found_peak_time = 0.0;
    string file = "test.wav";
    
//    //see data in wav file
//    NSData *testdata = [NSData dataWithContentsOfFile:@"dumb3_converted"];
//    NSUInteger length = [testdata length];
//    NSLog(@"test data is length is %lu",(unsigned long)length);
//    int *cdata = (int*)malloc(length);
//    [testdata getBytes:(void*)cdata length:length];
    
    
    WaveFile wavFile(file);
    xtract_mel_filter mel_filters;
    xtract_last_n_state *last_n_state = xtract_last_n_state_new(MAVG_COUNT);
    
//    if (!wavFile.IsLoaded())
//    {
//        return EXIT_FAILURE;
//    }
    //printf("after wav file loaded");

    
    float *wavData = (float *)wavFile.GetData(); // assume 32-bit float
    std::size_t wavBytes = wavFile.GetDataSize();
    
    
    /*Added for Feature Extraction*/
    
    //uint64_t wavSamples = wavBytes / sizeof(float);
    //double data[wavSamples];
    int wavSamples = ARRAYSIZE;
    double data[ARRAYSIZE];
    NSUInteger count2 = [test1 count];
    double item2;
    for(int n=0;n<count2;n++){
        //id item2;
        //item2 = [test1 objectAtIndex:j];
        item2 = [[test1 objectAtIndex:n] doubleValue];
        //NSLog(@"feature extraction block: obj in test1 mutable array in is:%f",item2);
        data[n] = item2;
        //std::cout << data[n] << ' ';

    }
    
    /* Allocate Mel filters */
    mel_filters.n_filters = MFCC_FREQ_BANDS;
    mel_filters.filters   = (double **)malloc(MFCC_FREQ_BANDS * sizeof(double *));
    for(uint8_t k = 0; k < MFCC_FREQ_BANDS; ++k)
    {
        mel_filters.filters[k] = (double *)malloc(BLOCKSIZE * sizeof(double));
    }
    
    xtract_init_mfcc(BLOCKSIZE >> 1, SAMPLERATE >> 1, XTRACT_EQUAL_GAIN, MFCC_FREQ_MIN, MFCC_FREQ_MAX, mel_filters.n_filters, mel_filters.filters);
    
    /* create the window functions */
    window = xtract_init_window(BLOCKSIZE, XTRACT_HANN);
    window_subframe = xtract_init_window(HALF_BLOCKSIZE, XTRACT_HANN);
    xtract_init_wavelet_f0_state();
    

    //std::cout << "\n File has " << wavSamples << " samples" << std::endl;
    int peak_found = XTRACT_NO_RESULT;
    
    
    //xtract_mean,  --changes done
    xtract[XTRACT_MEAN](data, wavSamples, &samplerate, &mean);
    //NSLog(@"XTRACT_MEAN :%f",mean);
    
    //    xtract_variance,  --changes done
    xtract[XTRACT_VARIANCE](data, wavSamples, &mean, &libxtract_Varience);
    //NSLog(@"XTRACT_VARIANCE :%f",libxtract_Varience);
    
    //    xtract_standard_deviation,  --changes done
    xtract[XTRACT_STANDARD_DEVIATION](data, wavSamples, &libxtract_Varience, &libxtract_StandardDeviation);
    //NSLog(@"XTRACT_STANDARD_DEVIATION :%f",libxtract_StandardDeviation);
    
    //    xtract_average_deviation, --changes done
    xtract[XTRACT_AVERAGE_DEVIATION](data, wavSamples, &mean, &libxtract_Averagedeviation);
    //NSLog(@"XTRACT_AVERAGE_DEVIATION :%f",libxtract_Averagedeviation);
    
    //xtract_skewness,  -- argv[0] : Mean ,arg[1] - Standard Deviation --changes done
    double argv[2] = {mean,libxtract_StandardDeviation};
    xtract[XTRACT_SKEWNESS](data, wavSamples, &argv, &libxtact_skewness);
    //NSLog(@"XTRACT_SKEWNESS :%f",libxtact_skewness);
    
    //    xtract_kurtosis,  --argv[0] : Mean ,arg[1] - Standard Deviation --changes done
    xtract[XTRACT_KURTOSIS](data, wavSamples, &argv, &libxtract_kurtosis);
    //NSLog(@"XTRACT_KURTOSIS :%f",libxtract_kurtosis);
    
    //    xtract_spectral_mean, --changes done  N/2
    xtract[XTRACT_SPECTRAL_MEAN](data, wavSamples, &samplerate, &libxtract_spectral_mean);
    //NSLog(@"XTRACT_SPECTRAL_MEAN :%f",libxtract_spectral_mean);
    
    //    xtract_spectral_variance, --changes done N/2  
    xtract[XTRACT_SPECTRAL_VARIANCE](data, wavSamples, &samplerate, &libxtract_spectral_varience);
    //NSLog(@"XTRACT_SPECTRAL_VARIANCE :%f",libxtract_spectral_varience);
    
    //    xtract_spectral_standard_deviation, --changes done
    xtract[XTRACT_SPECTRAL_STANDARD_DEVIATION](data, wavSamples, &libxtract_spectral_varience, &libxtract_spectral_standardDeviation);
    //NSLog(@"XTRACT_SPECTRAL_STANDARD_DEVIATION :%f",libxtract_spectral_standardDeviation);
    
    //    xtract_spectral_skewness, -- argv[0] : SpectralMean ,arg[1] - spectral Standard Deviation --changes done
    double argv1[2] = {libxtract_spectral_mean,libxtract_spectral_standardDeviation};
    xtract[XTRACT_SPECTRAL_SKEWNESS](data, wavSamples, &argv1, &libxtract_spectral_skewness);
    //NSLog(@"XTRACT_SPECTRAL_SKEWNESS :%f",libxtract_spectral_skewness);
    
    //    xtract_spectral_kurtosis,   -- argv[0] : SpectralMean ,arg[1] - spectral Standard Deviation --changes done
    xtract[XTRACT_SPECTRAL_KURTOSIS](data, wavSamples, &argv1, &libxtract_spectral_kurtosis);
    //NSLog(@"XTRACT_SPECTRAL_KURTOSIS :%f",libxtract_spectral_kurtosis);
    
    //    xtract_spectral_centroid,  --changes done
    xtract[XTRACT_SPECTRAL_CENTROID](data, wavSamples, &samplerate, &libxtract_spectral_centroid);
    //NSLog(@"XTRACT_SPECTRAL_CENTROID :%f",libxtract_spectral_centroid);
    
    //    xtract_irregularity_k,   --done
    xtract[XTRACT_IRREGULARITY_K](data, wavSamples, &samplerate, &libxtract_irregularity_k);
    //NSLog(@"XTRACT_IRREGULARITY_K :%f",libxtract_irregularity_k);
    
    //    xtract_irregularity_j,    --done
    xtract[XTRACT_IRREGULARITY_J](data, wavSamples, &samplerate, &libxtract_irregularity_j);
    //NSLog(@"XTRACT_IRREGULARITY_K :%f",libxtract_irregularity_j);
    
    //    xtract_tristimulus_1,
    xtract[XTRACT_TRISTIMULUS_1](data, wavSamples, &samplerate, &libxtract_tristimulus_1);
    //NSLog(@"XTRACT_TRISTIMULUS_1 :%f",libxtract_tristimulus_1);
    
    //    xtract_tristimulus_2,
    xtract[XTRACT_TRISTIMULUS_2](data, wavSamples, &samplerate, &libxtract_tristimulus_2);
    //NSLog(@"XTRACT_TRISTIMULUS_2 :%f", libxtract_tristimulus_2);
    
    //    xtract_tristimulus_3,
    xtract[XTRACT_TRISTIMULUS_3](data, wavSamples, &samplerate, &libxtract_tristimulus_3);
    //NSLog(@"XTRACT_TRISTIMULUS_3 :%f",libxtract_tristimulus_3);
    
    //    xtract_smoothness, --done
    xtract[XTRACT_SMOOTHNESS](data, wavSamples, &samplerate, &libxtract_smoothness);
    //NSLog(@"XTRACT_SMOOTHNESS :%f",libxtract_smoothness);
    
    //    xtract_spread, --done
    xtract[XTRACT_SPREAD](data, wavSamples, &samplerate, &libxtract_spread);
    //NSLog(@"XTRACT_SPREAD :%f",libxtract_spread);
    
    //    xtract_zcr, -- done
    xtract[XTRACT_ZCR](data, wavSamples, &samplerate, &libxtract_zcr);
    //NSLog(@"XTRACT_ZCR :%f",libxtract_zcr);
    
    //    xtract_rolloff, -- done
    xtract[XTRACT_ROLLOFF](data, wavSamples, &samplerate, &libxtract_rolloff);
   // NSLog(@"xtract_rolloff :%f",libxtract_rolloff);
    
    //XTRACT_LOUDNESS --changes done
    xtract[XTRACT_LOUDNESS](data, wavSamples, &samplerate, &libxtract_Loudness);
    //NSLog(@"XTRACT_LOUDNESS :%f",libxtract_Loudness);
    
    //xtract_flatness --changes done
    xtract[XTRACT_FLATNESS](data, wavSamples, &samplerate, &libxtract_Flatness);
   // NSLog(@"XTRACT_FLATNESS :%f",libxtract_Flatness);
    
    //xtract_flatness_db --changes done
    xtract[XTRACT_FLATNESS_DB](data, wavSamples, &libxtract_Flatness, &libxtract_Flatness_Db);
    //NSLog(@"XTRACT_FLATNESS_DB :%f",libxtract_Flatness_Db);
   
    //xtract_tonality --changes done
    xtract[XTRACT_TONALITY](data, wavSamples, &libxtract_Flatness_Db, &libxtract_Tonality);
    //NSLog(@"XTRACT_TONALITY :%f",libxtract_Tonality);
    
    //xtract_crest --changes done
    xtract[XTRACT_CREST](data, wavSamples, &libxtract_Tonality, &libxtract_crest);
    //NSLog(@"XTRACT_CREST :%f",libxtract_crest);
    
    xtract[XTRACT_LOWEST_VALUE](data, wavSamples, &samplerate, &libxtract_lowest_value);
    
    xtract[XTRACT_HIGHEST_VALUE](data, wavSamples, &samplerate, &libxtract_highest_value);
    
        
    //from simpletest.cpp
    for (int n = 0; n < wavSamples; n += Half_BlockSize) // Overlap by HALF_BLOCKSIZE
    {
        
        /* get the F0 */
        xtract[XTRACT_WAVELET_F0](&data[n], BLOCKSIZE, &samplerate, &f0);
        //NSLog(@"XTRACT_WAVELET_F0 :%f",f0);
        
        /* get the F0 as a MIDI note */
        if (f0 != 0.0)
        {
            xtract[XTRACT_MIDICENT](NULL, 0, &f0, &midicents);
            //NSLog(@"XTRACT_MIDICENT :%f",midicents);
            int note = (int)round(midicents / 100);
            if (note != prev_note)
            {
                //printf("Pitch: %d at %f\n", note, n / (float)SAMPLERATE);
            }
            prev_note = note;
        }
        
        xtract_windowed(&data[n], BLOCKSIZE, window, windowed);
        for(int i =0 ; i < ARRAYSIZE ; i++){
            //NSLog(@"xtract_windowed :%f",windowed[i]);
        }
        
         /* get the spectrum */
        argd[0] = SAMPLERATE / (double)BLOCKSIZE;  //doubt
        argd[1] = XTRACT_MAGNITUDE_SPECTRUM;
        argd[2] = 0.f; /* DC component - we expect this to zero for square wave */
        argd[3] = 0.f; /* No Normalisation */
        
        xtract_init_fft(BLOCKSIZE, XTRACT_SPECTRUM);
        xtract[XTRACT_SPECTRUM](windowed, BLOCKSIZE, &argd[0], spectrum);
        for(int i =0 ; i < ARRAYSIZE ; i++){
            //NSLog(@"Spectrum :%f",spectrum[i]);
        }
        xtract_free_fft();
        
        xtract[XTRACT_SPECTRAL_CENTROID](spectrum, BLOCKSIZE, NULL, &centroid);
        //NSLog(@"XTRACT_SPECTRAL_CENTROID :%f",centroid);
        
        argd[1] = 10.0; /* peak threshold as %  of maximum peak */
        
        xtract[XTRACT_PEAK_SPECTRUM](spectrum, BLOCKSIZE / 2, argd, peaks);
        for(int i =0 ; i < ARRAYSIZE ; i++){
            //NSLog(@"XTRACT_PEAK_SPECTRUM :%f",peaks[i]);
        }
        
        argd[0] = f0;
        argd[1] = .3; /* harmonic threshold */
        xtract[XTRACT_HARMONIC_SPECTRUM](peaks, BLOCKSIZE, argd, harmonics);
        for(int i =0 ; i < ARRAYSIZE ; i++){
            //NSLog(@"XTRACT_HARMONIC_SPECTRUM :%f",harmonics[i]);
        }
        
        
        /* compute the MFCCs */
        xtract_mfcc(spectrum, BLOCKSIZE/2, &mel_filters, mfccs);
        for(int i =0 ; i < MFCC_FREQ_BANDS ; i++){
            //NSLog(@"xtract_mfcc :%f",mfccs[i]);
        }
        
        
        double gated[BLOCKSIZE] = {0};
        double block_max = 0.0;

        /* crude noise gate */
        for (int k = 0; k < BLOCKSIZE; ++k)
        {
            if (fabs(data[n+k]) > block_max)
            {
                block_max = fabs(data[n+k]);
            }
            
            if (data[n+k] > .1)
            {
                gated[k] = data[n+k];
            }
        }
        
        /* normalise */
        double norm_factor = block_max > 0.0 ? 1.0 / block_max : 0.0;
        
        for (int k = 0; k < BLOCKSIZE; ++k)
        {
            gated[k] *= norm_factor;
        }
        
        /* compute Spectral Flux */
        argd[0] = SAMPLERATE / HALF_BLOCKSIZE;
        argd[1] = XTRACT_LOG_POWER_SPECTRUM;
        argd[2] = 0.f; /* DC component */
        argd[3] = 1.f; /* Yes Normalisation */
        
        xtract_features_from_subframes(gated, BLOCKSIZE, XTRACT_WINDOWED, window_subframe, subframes_windowed);
        xtract_init_fft(Half_BlockSize, XTRACT_SPECTRUM);
        xtract_features_from_subframes(subframes_windowed, BLOCKSIZE, XTRACT_SPECTRUM, argd, subframes_spectrum);
        for(int i =0; i< BLOCKSIZE; i++){
            //NSLog(@"xtract_features_from_subframes :%f",subframes_spectrum[i]);
        }
        

        xtract_free_fft();
        
        argd[0] = 0.5; /* smoothing factor */
        
        /* smooth the amplitude components of the first and second spectra */
        xtract_smoothed(subframes_spectrum, Half_BlockSize/2, argd, subframes_spectrum);
        for(int i =0; i< BLOCKSIZE; i++){
            //NSLog(@"xtract_smoothed :%f",subframes_spectrum[i]);
        }
        xtract_smoothed(subframes_spectrum + Half_BlockSize, Half_BlockSize/2, argd, subframes_spectrum + Half_BlockSize);
        for(int i =0; i< BLOCKSIZE; i++){
           // NSLog(@"xtract_smoothed from half block size :%f",subframes_spectrum[i]);
        }
        
        /* difference between the two spectra */
        xtract_difference_vector(subframes_spectrum, BLOCKSIZE, NULL, difference);
        for(int i =0; i< BLOCKSIZE; i++){
            //NSLog(@"xtract_difference_vector :%f",difference[i]);
        }
        
        
        argd[0] = .25; /* norm order */
        argd[1] = XTRACT_POSITIVE_SLOPE; /* positive slope */
        argd[2] = 1; /* normalise */
        
        /* Right shift HALF_BLOCKSIZE because we only want amplitudes not frequencies */
        xtract_flux(difference, Half_BlockSize/2, argd, &flux);
        //NSLog(@"xtract_flux :%f",flux);
        
        xtract_last_n(last_n_state, &flux, MAVG_COUNT, NULL, lastn);
        for(int i =0; i< MAVG_COUNT; i++){
            //NSLog(@"xtract_last_n :%f",lastn[i]);
        }
        
        
        argd[0] = 10; /* flux threshold */
        double flux_current = 0.0;
        
        peak_found = xtract_peak(lastn, MAVG_COUNT, argd, &flux_current);
         //NSLog(@"xtract_peak :%d",peak_found);
        
        if (peak_found == XTRACT_SUCCESS)
        {
            double peak_time = n / (float)SAMPLERATE;
            if (peak_time - last_found_peak_time > .05 || peak_time < .05)
            {
                //printf("Onset at %f seconds\n", n / (float)SAMPLERATE);
                last_found_peak_time = peak_time;
            }
        }
    }
    
    //Audio Recogniztion
    
    /*Saving Features in a file*/
    
    //Total 14 features
    
    
//    featureData = [NSString stringWithFormat:@"1,%f,%f,%f,%f,%f,%f,%f,%f,%f\r\n",libxtract_StandardDeviation*10,libxtract_Varience*10, log(libxtract_spectral_standardDeviation), log(libxtract_spectral_varience),libxtract_zcr,libxtract_Loudness/10,libxtract_irregularity_j/10,libxtract_irregularity_k,libxtract_highest_value];
//    //NSLog(@"feature data is %@",featureData);
    
    
    featureData = [NSString stringWithFormat:@"4,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,%.10f\r\n",(mean*10)+10,(libxtract_StandardDeviation*10)+10,(libxtract_Varience*10)+10, libxtract_spectral_centroid+10,libxtract_zcr+10,libxtract_Loudness+10,libxtract_kurtosis+10,libxtract_irregularity_j+10,libxtract_irregularity_k+10,libxtact_skewness+10,(libxtract_highest_value*10)+10];
    NSLog(@"old feature data is %@",featureData);

    if (readypauseData == 1) {
        
        NSLog(@"saving features in file");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:@"Test1_FireAlarmData.txt"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:documentTXTPath])
        {
            [featureData writeToFile:documentTXTPath
                          atomically:YES
                            encoding:NSStringEncodingConversionAllowLossy
                               error:nil];
        }
        else
        {
            NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
            [myHandle seekToEndOfFile];
            [myHandle writeData:[featureData dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSLog(@"Done Saving in file");
    }
    
    
    /* cleanup */
    for(n = 0; n < MFCC_FREQ_BANDS; ++n)
    {
        free(mel_filters.filters[n]);
    }
    free(mel_filters.filters);
    xtract_free_window(window);
    xtract_free_window(window_subframe);
    return 1;
}

- (IBAction)readfromsfile:(id)sender {

    //reading data from file
    NSString* filePath1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];    //NSLog(@"file path1 %@",filePath1);
    NSString* fileName1 = @"silentData.txt";
    NSString* fileAtPath1 = [filePath1 stringByAppendingPathComponent:fileName1];
    //NSLog(@"file at path %@",fileAtPath1);
    NSString *filecontent = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath1] encoding:NSUTF8StringEncoding];
    //NSLog(@" file contect = %@",filecontent);
}

- (IBAction)getDataForTraining:(id)sender {
    
    NSLog(@"in getDatafortraining");
    //for saving data for training
    readypauseData = 1;
}

- (IBAction)pauseTrainData:(id)sender {
    //for pausing saving data for training
    NSLog(@"in pauseTrainData");
    readypauseData = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    //[audioData4Libxtract release];
    //[_LPF_cornerFrequency release];
    //[_SegmentControl release];
    //[_bropdownButton release];
    //[_tableViewDropDown release];
    //[super dealloc];
}


@end
