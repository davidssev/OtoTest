//
//  FirstViewController.m
//  OtoTest
//
//  Created by alden on 12/21/12.
//  Copyright (c) 2012 alden. All rights reserved.
//
//  This controller administrates the Hughson-Westlake hearing test procedure.
//  A good flowchart of this test is available at
//  http://www.who.int/occupational_health/publications/noise8.pdf
//  on page 194, although the decible increments are slightly different here.

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.frequencies = [OTShared toneFiles];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload {
  [self setHeardItButton:nil];
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Testing 

// Main test function. called once every INTER_TONE_TIME seconds
- (void)doToneForTest
{
  if (self.testPhase == OTTestPhaseSecond && self.lastToneWentUp) {
    // maintain a history of the 3 most recent "heard it?" results for acending tones
    if (self.toneHeardHistory.count > 3)
      [self.toneHeardHistory removeObjectAtIndex:0];
    [self.toneHeardHistory addObject:[NSNumber numberWithBool:self.heardLastTone]];
    NSLog(@"heard history:%@", self.toneHeardHistory);
  }
  
  if (self.heardLastTone) {
    if ([self isDoneWithFrequency]) {
      NSLog(@"done with frequency");
      [self finishFrequency];
      return;
    } else {
      if (self.testPhase == OTTestPhaseFirst) {
        NSLog(@"Entering 2nd phase");
      }
      NSLog(@"heard it, but not done with frequency: decreasing vol by %f", DECREASE_DB_AMT);
      self.dBVolume -= DECREASE_DB_AMT;
      self.lastToneWentUp = NO;
      self.testPhase = OTTestPhaseSecond;
    }
  }
  else {
    double dBIncrease = self.testPhase == OTTestPhaseFirst ? FIRST_INCREASE_DB_AMT : SECOND_INCREASE_DB_AMT;
    self.dBVolume += dBIncrease;
    self.lastToneWentUp = YES;
    NSLog(@"didn't hear it, increasing vol by %f", dBIncrease);
  }
  
  if ([self volumeFromDecibles:self.dBVolume] > 1.0) {
    //TODO fail test
    [NSException raise:@"Implement Me" format:@"volume above max"];
  }
  
  [self playCurrentTone];
  self.heardLastTone = NO;
  self.lastToneTime  = [NSDate date];
  [self performSelector:@selector(doToneForTest) withObject:nil afterDelay:INTER_TONE_TIME];
}

- (BOOL)isDoneWithFrequency
{
  if (self.testPhase != OTTestPhaseSecond)
    return NO;
  NSArray *ayes = [self.toneHeardHistory select:^(id heard, NSUInteger idx) {
    return [heard boolValue];
  }];
  return [ayes count] >= 2;
}

- (void)beginNextFrequency
{
  self.frequencyIndex++;
  if (self.frequencyIndex < [self.frequencies count]) {
    self.testPhase = OTTestPhaseFirst;
    self.dBVolume = INITIAL_DB;
    self.lastToneTime = nil;
    self.lastToneWentUp = NO;
    self.heardLastTone = NO;
    self.toneHeardHistory = [NSMutableArray arrayWithCapacity:3];
    [self doToneForTest];
  } else {
    [self finishTest];
  }
}

- (void)finishFrequency
{
  OTFrequencyResult *fr = (OTFrequencyResult *)[NSEntityDescription insertNewObjectForEntityForName:@"OTFrequencyResult"
                                                                             inManagedObjectContext:self.managedObjectContext];

  fr.freq = self.frequencies[self.frequencyIndex];
  fr.dB = @(self.dBVolume);
  fr.result = self.result;
  [self.result addFrequencyResultsObject:fr];

  NSError *error = nil;
  if (![self.managedObjectContext save:&error]) {
    [NSException raise:@"Managed Object Context Save Failed" format:@"%@", [error localizedDescription]];
  }

  [self beginNextFrequency];
}

- (void)finishTest
{
  NSLog(@"RESULT %@", self.result.date);
  for (OTFrequencyResult *fr in self.result.frequencyResults) {
    NSLog(@"%@: %@", fr.freq, fr.dB);
  }
  NSLog(@"");

  self.heardItButton.hidden = YES;

  // allow self.result and its related frequency results to be released
  [self.managedObjectContext refreshObject:self.result mergeChanges:NO];
  self.result = nil;
}

#pragma mark -
#pragma mark Actions

- (IBAction)beginTest
{
  OTResult *result = (OTResult *)[NSEntityDescription insertNewObjectForEntityForName:@"OTResult"
                                                               inManagedObjectContext:self.managedObjectContext];
  result.date = [NSDate date];
  self.result = result;
  self.frequencyIndex = INITIAL_FREQ_IDX;
  self.heardItButton.hidden = NO;
  [self beginNextFrequency];
}

- (IBAction)heardTone
{
  if (([self.lastToneTime timeIntervalSinceNow]*-1) <= RECOGNITION_WINDOW) 
    self.heardLastTone = YES;
}

- (IBAction)soundButtonPressed:(UIButton *)sender {
  self.dBVolume = 100;
  for (NSString *fileName in [OTShared toneFiles]) {
    [self playAudioResource:fileName withExtension:@"mp3"];
    sleep(1);
  }
}

#pragma mark -
#pragma mark Audio

- (void)playCurrentTone
{
  NSString *resource = [self.frequencies objectAtIndex:self.frequencyIndex];
  [self playAudioResource:resource withExtension:@"mp3"];
}

- (void)playAudioResource:(NSString *)resource withExtension:(NSString *)ext
{
  NSURL *soundURL = [[NSBundle mainBundle] URLForResource:resource withExtension:ext];
  // TODO handle error
  self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
  self.player.volume = [self volumeFromDecibles:self.dBVolume];
  [self.player play];
}

- (double)volumeFromDecibles:(double)decibles
{
  // TODO find actual ratio
  return decibles/100.0;
}

@end
  
