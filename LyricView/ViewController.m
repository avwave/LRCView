//
//  ViewController.m
//  LyricView
//
//  Created by Arvin Rimorin on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
-(void)readFile;
@end

@implementation ViewController

-(void)displayStringIntoLabel:(NSString *)component {
	NSLog(@"%@", component);
	[lyricField setText:component];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/05421_Wonderwall_Oasis.mp3", [[NSBundle mainBundle] resourcePath]]];
	
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	
	if (audioPlayer != nil) {
		[audioPlayer prepareToPlay];
		[slider setMaximumValue:[audioPlayer duration]];
		[self readFile];
	}
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
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"05421_Wonderwall_Oasis" ofType:@"lrc"];
	NSError *error;
	NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
													usedEncoding:nil
														   error:&error];
	[lyricParser setDelegate:self];
	[lyricParser setLyrics:content];
}

-(void)startPlaying:(id)sender {
	[lyricParser startLyricEngineFromTime:[slider value]];
	NSTimeInterval now = audioPlayer.deviceCurrentTime;
	
	[audioPlayer setCurrentTime:[slider value]];
	[audioPlayer play];
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
