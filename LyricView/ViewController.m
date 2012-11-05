//
//  ViewController.m
//  LyricView
//
//  Created by Arvin Rimorin on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
	NSTimer *sliderTimer;
}
-(void)readFile;
@end

@implementation ViewController
@synthesize audioPlayer;

-(void)displayStringIntoLabel:(NSString *)component {
	NSLog(@"%@", component);
	[lyricField setText:component];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSError* error = nil;
	NSString* soundfilePath = [[NSBundle mainBundle] pathForResource:@"onsec" ofType:@"mp3"];
	NSURL* soundfileURL = [NSURL fileURLWithPath:soundfilePath];
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundfileURL error:&error];
	[self.audioPlayer play];  
	

	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"05121_Don't Stop Believin'_Journey" ofType:@"mp3"]];
	
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	
	sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
	
	if (self.audioPlayer != nil) {
		[slider setMaximumValue:[self.audioPlayer duration]];
		[self readFile];
		[self.audioPlayer prepareToPlay];

	}
}

-(void)updateSlider {
	[timeField setText:[NSString stringWithFormat:@"%.2f",self.audioPlayer.currentTime]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)readFile {
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"05121_Don't Stop Believin'_Journey" ofType:@"lrc"];
	NSError *error;
	NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
													usedEncoding:nil
														   error:&error];
	[lyricParser setDelegate:self];
	[lyricParser setLyrics:content];
}

-(void)startPlaying:(id)sender {
	if ([self.audioPlayer isPlaying]) {
		[self.audioPlayer stop];
	}
	[lyricParser startLyricEngineFromTime:[slider value]];
	NSTimeInterval now = self.audioPlayer.deviceCurrentTime;
	
	[self.audioPlayer setCurrentTime:[slider value]];
	[self.audioPlayer play];
}

- (NSString *)convertTimeFromSeconds:(float)seconds {
    
    // Return variable.
    NSString *result = @"";
	
    // Int variables for calculation.
    float secs = seconds;
    int tempHour    = 0;
    int tempMinute  = 0;
    int tempSecond  = 0;
	
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
	
    // Convert the seconds to hours, minutes and seconds.
    tempHour    = secs / 3600;
    tempMinute  = secs / 60 - tempHour * 60;
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60);
    
    hour    = [[NSNumber numberWithInt:tempHour] stringValue];
    minute  = [[NSNumber numberWithInt:tempMinute] stringValue];
    second  = [[NSNumber numberWithInt:tempSecond] stringValue];
    
    // Make time look like 00:00:00 and not 0:0:0
    if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    } 
    
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    
    if (tempHour == 0) {
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
        
    } else {
		result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
        
    }
    
    return result;
	
}


-(void)scrub:(UISlider *)sender {
	NSTimeInterval theTimeInterval = [sender value];
	
	[timeField setText:[self convertTimeFromSeconds:theTimeInterval]];
}
@end
