//
//  ViewController.h
//  LyricView
//
//  Created by Arvin Rimorin on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LyricParser.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <LyricParserDelegate>{
	IBOutlet UILabel *lyricField;
	IBOutlet LyricParser *lyricParser;
	IBOutlet UILabel *timeField;

	NSDateFormatter *timeFormatter;	
	IBOutlet UISlider *slider;
}

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
-(IBAction)startPlaying:(id)sender;
-(IBAction)scrub:(id)sender;

@end
