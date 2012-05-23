//
//  LyricParser.m
//  LyricView
//
//  Created by Arvin Rimorin on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LyricParser.h"
#import "NSMutableArray+Reverse.h"

@implementation LyricParser
@synthesize delegate;

-(id)initWithLyrics:(NSString *)l {
	self = [super init];
    if (self) {
		lyrics = [NSString stringWithString:l];
		lineTimes = [[NSMutableArray alloc] initWithCapacity:1];
		lineContents = [[NSMutableArray alloc] initWithCapacity:1];
		wordTimes = [[NSMutableArray alloc] initWithCapacity:1];
		wordContents = [[NSMutableArray alloc] initWithCapacity:1];
        [self parseLyrics];
    }
    return self;

}
-(void)parseLyrics{
	NSArray *lineSplit = [lyrics componentsSeparatedByCharactersInSet:
						  [NSCharacterSet characterSetWithCharactersInString:@"[]"]];

	NSString *regex = @"\\d\\d[:]\\d\\d.\\d\\d";
	NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	float previousTime = 0.0f;
	float prTime = 0.0f;
	for (int i=0; i<[lineSplit count]; i++) {
		NSString *str = [[lineSplit objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([regextest evaluateWithObject:str] == YES){
			NSArray *timeComponentArr = [[lineSplit objectAtIndex:i] componentsSeparatedByCharactersInSet:
										 [NSCharacterSet characterSetWithCharactersInString:@":."]];
			float seconds = ([[timeComponentArr objectAtIndex:0] floatValue] * 60) + 
							([[timeComponentArr objectAtIndex:1] floatValue]) + 
							([[timeComponentArr objectAtIndex:2] floatValue]/100.0f);
						
			float interval = seconds - previousTime;
			previousTime = seconds;
			[lineTimes addObject: [NSNumber numberWithFloat:interval]];
			
			NSString *lineStr = [lineSplit objectAtIndex:i+1];
			[lineContents addObject: lineStr];
			
			NSArray *wordSplit = [lineStr componentsSeparatedByCharactersInSet:
								  [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
			
			for (int j=0; j<[wordSplit count]; j++) {
				NSString *wstr = [[wordSplit objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if ([regextest evaluateWithObject:wstr] == YES){
					NSArray *timeComponentArr = [[wordSplit objectAtIndex:j] componentsSeparatedByCharactersInSet:
												 [NSCharacterSet characterSetWithCharactersInString:@":."]];
					float seconds = ([[timeComponentArr objectAtIndex:0] floatValue] * 60) + 
					([[timeComponentArr objectAtIndex:1] floatValue]) + 
					([[timeComponentArr objectAtIndex:2] floatValue]/100.0f);
					float interval = seconds - prTime;
					prTime = seconds;
					[wordTimes addObject:[NSNumber numberWithFloat: interval]];
					[wordContents addObject:[[wordSplit objectAtIndex:j+1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
				}
			}
			
			
		}
		//i++;
	}
	
	[wordTimes reverse];
	[wordContents reverse];
	[lineTimes reverse];
	[lineContents reverse];
}

-(void)startLyricEngineFromTime:(float)timeInSeconds {
	float elapseTime = [[wordTimes lastObject] floatValue];
	[self performSelector:@selector(timerComplete) withObject:nil afterDelay:elapseTime];
}

-(void)timerComplete {
	[[self delegate] displayStringIntoLabel:[wordContents lastObject]];

	[wordTimes removeLastObject];
	[wordContents removeLastObject];
	[self startLyricEngineFromTime:0.0f];
}
@end
