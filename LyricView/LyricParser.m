//
//  LyricParser.m
//  LyricView
//
//  Created by Arvin Rimorin on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LyricParser.h"
#define FONTSIZE 25.0
#define kLyricFontRef "Futura LT Book"
#define kLyricFont @"Lato-Regular"
#import <QuartzCore/QuartzCore.h>

@implementation LyricParser {
	BOOL specialCase;
	NSString *displayString;

	NSString *wholeLyrics;
	UILabel *animLabel;
	UILabel *upNextAnimLabel;

	CGRect prevFrame;
	CGRect upNextPrevFrame;
}
@synthesize delegate, timerArray, startTimeInSeconds, endTimeInSeconds;

-(void) invalidateTimers {
	for (NSTimer *timer in self.timerArray) {
		[timer invalidate];
	}
}

-(void)clearStrings {
	for (int i=0; i < [progressLineArray count] ; i++) {
		[progressLineArray replaceObjectAtIndex:i withObject:@""];
	}

	currentWord = @"";
	currentLine = @"";
	wholeLyrics = @"\n";
	displayString = @"\n";
	animLabel.text = @"";

	if (specialCase) {
		displayLine = 0;
	} else {
		displayLine = 1;
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		displayLine = 1;
		dispLineArray = [[NSMutableArray alloc] init];
		[self clearStrings];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if (self) {
		animLabel = [[UILabel alloc] init];
		upNextAnimLabel = [[UILabel alloc] init];

		animLabel.backgroundColor = [UIColor clearColor];
		upNextAnimLabel.backgroundColor = [UIColor clearColor];


		animLabel.lineBreakMode = UILineBreakModeWordWrap;
		animLabel.numberOfLines = 100;
		upNextAnimLabel.lineBreakMode = UILineBreakModeWordWrap;
		upNextAnimLabel.numberOfLines = 100;
		animLabel.font = [UIFont fontWithName:kLyricFont size:FONTSIZE];
		animLabel.textColor = [UIColor magentaColor];
		upNextAnimLabel.textColor = [UIColor whiteColor];
		upNextAnimLabel.font = [UIFont fontWithName:kLyricFont size:FONTSIZE];

		self.clipsToBounds = YES;
		[self addSubview:upNextAnimLabel];
		[self addSubview:animLabel];

		animLabel.frame = self.bounds;
		upNextAnimLabel.frame = self.bounds;

		animLabel.text = @"";
		upNextAnimLabel.text = @"\n";
		displayString = @"";

		displayLine = 1;
		dispLineArray = [[NSMutableArray alloc] init];
		progressLineArray = [[NSMutableArray alloc] init];
		[self clearStrings];
    }
    return self;
}


-(void)setLyrics:(NSString *)l {
	lyrics = [NSString stringWithString:l];
	lineTimes = [[NSMutableArray alloc] initWithCapacity:1];
	lineContents = [[NSMutableArray alloc] initWithCapacity:1];
	lineQueue = [[NSMutableArray alloc] initWithCapacity:1];
	displayString = @"";
	[self parseLyrics];

}

-(void)parseLyrics{
	animLabel.frame = self.bounds;
	upNextAnimLabel.frame = self.bounds;

	NSArray *lineSplit = [lyrics componentsSeparatedByCharactersInSet:
						  [NSCharacterSet characterSetWithCharactersInString:@"[]"]];

	NSString *regex = @"\\d{1,}[:]\\d{1,}.\\d{1,}";
	NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

	float previousTime = 0.0f;
	float prTime = 0.0f;
	for (int i=0; i<[lineSplit count]; i++) {
		NSString *str = [[lineSplit objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		if ([regextest evaluateWithObject:str] == YES){
			NSArray *timeComponentArr = [[lineSplit objectAtIndex:i] componentsSeparatedByCharactersInSet:
										 [NSCharacterSet characterSetWithCharactersInString:@":."]];
			float lseconds = ([[timeComponentArr objectAtIndex:0] floatValue] * 60) +
			([[timeComponentArr objectAtIndex:1] floatValue]) +
			([[timeComponentArr objectAtIndex:2] floatValue]/1000.0f);

			previousTime = lseconds;
			[lineTimes addObject: [NSNumber numberWithFloat:lseconds]];

			NSString *lineStr = [lineSplit objectAtIndex:i+1];
			//[lineContents addObject: lineStr];

			NSArray *wordSplit = [lineStr componentsSeparatedByCharactersInSet:
								  [NSCharacterSet characterSetWithCharactersInString:@"<>"]];

			NSMutableArray *tmpLineArr = [[NSMutableArray alloc] initWithCapacity:1];
			wordTimes = [[NSMutableArray alloc] initWithCapacity:1];
			wordContents = [[NSMutableArray alloc] initWithCapacity:1];
			for (int j=0; j<[wordSplit count]; j++) {
				NSString *wstr = [[wordSplit objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
				if ([regextest evaluateWithObject:wstr] == YES){
					NSArray *timeComponentArr = [[wordSplit objectAtIndex:j] componentsSeparatedByCharactersInSet:
												 [NSCharacterSet characterSetWithCharactersInString:@":."]];
					float seconds = ([[timeComponentArr objectAtIndex:0] floatValue] * 60) +
					([[timeComponentArr objectAtIndex:1] floatValue]) +
					([[timeComponentArr objectAtIndex:2] floatValue]/1000.0f);
					prTime = seconds;
					[wordTimes addObject:[NSNumber numberWithFloat: seconds]];
					[wordContents addObject:[[wordSplit objectAtIndex:j+1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
					[tmpLineArr addObject:[[wordSplit objectAtIndex:j+1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
				}
			}

			NSString *terminalString = [wordContents lastObject];
			[wordContents removeLastObject];
			terminalString = [terminalString stringByAppendingString:@"\n"];
			[wordContents addObject:terminalString];


			[lineContents addObject: [NSString stringWithFormat:@"^^%@", [tmpLineArr componentsJoinedByString:@""]]];
			wholeLyrics = [wholeLyrics stringByAppendingString:[NSString stringWithFormat:@"%@\n", [tmpLineArr componentsJoinedByString:@""]]];

			[lineQueue addObject: [tmpLineArr componentsJoinedByString:@""]];

			[lineTimes addObjectsFromArray:wordTimes];
			[lineContents addObjectsFromArray:wordContents];
		}
		//i++;
	}

	if ([lineTimes count] > 0) {
		[self.delegate countdownStart:[[lineTimes objectAtIndex:1] floatValue]];
		[self displayUpNextStringIntoLabel:wholeLyrics];
	}

}

-(void)instantiateLyricFromLine:(int)startLine ToLine:(int)endLine {
	specialCase = YES;
	[self clearStrings];
	//DLog(@"Lyrics: %@", dispLineArray);
}

-(void)startLyricEngine {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	//DLog(@"lyric engine : %.2f to %.2f", startTimeInSeconds, endTimeInSeconds);

	float secondOverlay = 0.0f;
	self.timerArray = [[NSMutableArray alloc] initWithCapacity:1];
	for (int i=0; i< [lineTimes count]; i++) {
		if ([[lineTimes objectAtIndex:i] floatValue] > startTimeInSeconds) {
			//DLog(@"%f, %@", [[lineTimes objectAtIndex:i] floatValue], [lineContents objectAtIndex:i]);

			float lineTimeOffset = 0;
			if (i+1 <[lineTimes count]) {
				lineTimeOffset = [lineTimes[i + 1] floatValue] - [lineTimes[i] floatValue];
			}
			NSDictionary *dict = @{
						  @"line": lineContents[i],
		@"time":[NSNumber numberWithFloat:lineTimeOffset]
		};
			NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:([[lineTimes objectAtIndex:i] floatValue] - startTimeInSeconds - secondOverlay) target:self selector:@selector(timerComplete:) userInfo:dict repeats:NO];
			[self.timerArray addObject:timer];
			//[self performSelector:@selector(timerComplete:) withObject:[lineContents objectAtIndex:i] afterDelay:[[lineTimes objectAtIndex:i] floatValue] - timeInSeconds - secondOverlay];
		}

	}
	[self clearStrings];

}


-(void)timerComplete:(NSTimer *)timer {
	NSDictionary *dict = [timer userInfo];
	NSString *string = dict[@"line"];

	//	DLog(@"lyrline: '%@'", string);
	if (string == nil) {
		return;
	}
	if ([string hasPrefix:@"^^"]) {
		//		[self displayStringIntoLabel:@"\n" withDuration:[dict[@"time"] floatValue]];
	} else {
		[self displayStringIntoLabel:string withDuration:[dict[@"time"] floatValue]];
	}

}

-(NSString *)nextLine {
	return @"";
}
-(void)startLyricEngineFromTime:(float)timeInSeconds {

}

-(void)startLineEngine {

}

-(void)displayStringIntoLabel:(NSString *)component withDuration:(NSTimeInterval)time {
	if([component isEqualToString:@"\n"] && [[displayString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] isEqualToString:@""]) {
		component = @"";
	}
	displayString = [displayString stringByAppendingString:component];

	CATransition *animation = [CATransition animation];
	animation.delegate = self;
	if (time > 0.25) {
		animation.duration = 0.2;
	} else {
		animation.duration = time/2;
	}
	animation.type = kCATransitionFade;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	[animLabel.layer addAnimation:animation forKey:@"changeTextTransition"];

	// Change the text
	if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
		 ([UIScreen mainScreen].bounds.size.height > 480.0f)) {
		if (self.isLessLines) {
			animLabel.text = [displayString stringByAppendingString:@"\n\n\n\n\n\n\n\n"];
		} else {
			animLabel.text = [displayString stringByAppendingString:@"\n\n\n\n\n\n\n\n\n"];
		}
	} else {
		if (self.isLessLines) {
			animLabel.text = [displayString stringByAppendingString:@"\n\n\n\n\n"];
		} else {
			animLabel.text = [displayString stringByAppendingString:@"\n\n\n\n\n\n"];
		}
	}


	[animLabel sizeToFit];
	CGRect rect = animLabel.frame;
	rect.size.width = 265;
	animLabel.frame = rect;
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	[self shiftUp];
}

-(void)shiftUp{
	if (CGRectEqualToRect(prevFrame, animLabel.frame)) {
		return;
	}

	if (animLabel.bounds.size.height > animLabel.superview.bounds.size.height) {
		float heightOffset = animLabel.bounds.size.height - animLabel.superview.bounds.size.height;
		float topOffset = animLabel.frame.origin.y;
		float totalOffset = (heightOffset - (fabsf(topOffset))) + 5.0;
		CGRect frame = CGRectOffset(animLabel.frame, 0, -totalOffset);
		CGRect upNextFrame = CGRectOffset(upNextAnimLabel.frame, 0, -totalOffset);

		[UIView animateWithDuration:0.3f
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseOut
						 animations:^{
							 animLabel.frame = frame;
							 upNextAnimLabel.frame = upNextFrame;
						 }
						 completion:nil];
		prevFrame = frame;
	}
}


-(void)displayUpNextStringIntoLabel:(NSString *)component{
	upNextAnimLabel.text = component;
	[upNextAnimLabel sizeToFit];

	CGRect rect = upNextAnimLabel.frame;
	rect.size.width = 265;
	upNextAnimLabel.frame = rect;
}

@end
