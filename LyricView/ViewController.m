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

	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Save Tonight.mp3", [[NSBundle mainBundle] resourcePath]]];
	
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	audioPlayer.numberOfLoops = 1;
	
	if (audioPlayer != nil) {
		[audioPlayer prepareToPlay];
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
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"08881_Save Tonight_Eagle-Eye Cherry" ofType:@"lrc"];
	NSError *error;
	NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
													usedEncoding:nil
														   error:&error];
	[lyricParser setDelegate:self];
	[lyricParser setLyrics:content];
}

-(void)startPlaying:(id)sender {
	[lyricParser startLyricEngineFromTime:0.0f];
	[lyricParser startLineEngine];
	[audioPlayer play];
}

@end
