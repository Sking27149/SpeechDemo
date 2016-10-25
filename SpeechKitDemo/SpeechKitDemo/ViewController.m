//
//  ViewController.m
//  SpeechKitDemo
//
//  Created by 刘伟 on 16/10/25.
//  Copyright © 2016年 Sking. All rights reserved.
//

#import "ViewController.h"
#import <Speech/Speech.h>


@interface ViewController ()<SFSpeechRecognizerDelegate>

@property (nonatomic, strong) SFSpeechRecognizer *sf;

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UITextView *textView;


@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

@property (nonatomic, strong) AVAudioEngine *audoEngine;

@end

@implementation ViewController {
    
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    
    SFSpeechRecognitionTask *recognitionTask;

}


- (SFSpeechRecognizer *)sf {
    if (_sf == nil) {
        _sf = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    }
    return _sf;
}

- (void)startRecordig {
    if (recognitionTask != nil) {
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [audioSession setActive:YES error:nil];
    
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    
    
//    guard let inputNode = audioEngine.inputNode else {
//        fatalError("Audio engine has no input node")
//    }
//    
//    guard let recognitionRequest = recognitionRequest else {
//        fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
//    }
    
    
    
    recognitionRequest.shouldReportPartialResults = true;
    
    recognitionTask = [self.sf recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        
        BOOL isFinal = NO;
        
        if (result != nil) {
            self.textView.text = result.bestTranscription.formattedString;
            isFinal = result.isFinal;
        }
        if (error != nil || isFinal) {
            
            [self.audoEngine stop];
            [self.audoEngine.inputNode removeTapOnBus:0];
            
            recognitionRequest = nil;
            recognitionTask = nil;
            
            
         
        }
    }];
    
     AVAudioFormat *recordingFormat = [self.audoEngine.inputNode outputFormatForBus:0];
    
    [self.audoEngine.inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audoEngine prepare];
    
    [self.audoEngine startAndReturnError:nil];
    
 
    self.textView.text = @"Say something, I'm listening!";
}

//- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
//    if (available) {
//        self.recordBtn.enabled = YES;
//    }else {
//        self.recordBtn.enabled = NO;
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sf.delegate = self;
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"%ld", (long)status);
    }];
    self.audoEngine = [[AVAudioEngine alloc] init];
}

- (IBAction)SpeechClick:(id)sender {
    if (self.audoEngine.isRunning) {
        [self.audoEngine stop];
        [recognitionRequest endAudio];
        [self.recordBtn setTitle:@"start record" forState:(UIControlStateNormal)];
    }else {
        [self startRecordig];
        [self.recordBtn setTitle:@"stop record" forState:(UIControlStateNormal)];
    }
}

@end
