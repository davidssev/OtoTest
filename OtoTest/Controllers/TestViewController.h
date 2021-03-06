//
//  FirstViewController.h
//  OtoTest
//
//  Created by alden on 12/21/12.
//  Copyright (c) 2012 alden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AppDelegate.h"
#import "OTViewController.h"
#import "ResultDetailTableViewController.h"

#define INTER_TONE_TIME        5.0   // in seconds (TODO: make it random)
#define RECOGNITION_WINDOW     4.0   // in seconds
#define FIRST_INCREASE_DB_AMT  20.0  // in decibles
#define SECOND_INCREASE_DB_AMT 5.0
#define DECREASE_DB_AMT        10.0
#define ACTUAL_INITIAL_DB      30.0
// avoid special cases for first play of a frequency, and first frequency
// set value to "one before" initial desired values.
#define INITIAL_DB             ACTUAL_INITIAL_DB - FIRST_INCREASE_DB_AMT 
#define INITIAL_FREQ_IDX       -1
#define INITIAL_EAR            RightEar

// Phases of the Hughson-Westlake test. These aren't anything official
// they just help the implementation.
typedef enum {
  OTTestPhaseFirst,  // larger decible changes, going up until first time tone is heard
  OTTestPhaseSecond, // narowing on and finding the threshold
} OTTestPhase;

typedef enum {
  LeftEar,
  RightEar,
} OTEar;

@interface TestViewController : OTViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *heardItButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;

@property AVAudioPlayer *player;
@property NSArray *frequencies;

@property OTResult *result;          // The result object for the current test
@property OTTestPhase testPhase;     // current phase of the test
@property OTEar ear;                 // ear we are testing
@property BOOL paused;               // is the test paused?
@property NSUInteger frequencyIndex; // current index into the frequencies array
@property double dBVolume;           // last decible volume played
@property NSDate *lastToneTime;      // time at which the most recent tone was played
@property BOOL heardLastTone;        // has user heard most recent tone?
@property NSMutableDictionary *toneHeardHistory; // heard tone? key: string of dB, value: BOOL array for last 0-4 tones

- (void)popTestUI;
- (void)beginTest;
- (IBAction)heardTone;
- (IBAction)pauseButtonPressed:(id)sender;
- (IBAction)cancelTestButtonPressed;

- (void)doToneForTest;
- (void)finishFrequency;
- (void)finishTest;
- (void)cancelTest;
- (BOOL)isDoneWithFrequency;

- (void)applicationWillResignActive:(NSNotification *)notification;

- (double)volumeFromDecibles:(double)decibles;

@end
