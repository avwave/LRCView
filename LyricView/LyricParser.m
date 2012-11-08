//
//  LyricParser.m
//  LyricView
//
//  Created by Arvin Rimorin on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LyricParser.h"
#define FONTSIZE 25.0

@implementation LyricParser {
	BOOL specialCase;
}
@synthesize delegate, timerArray, startTimeInSeconds, endTimeInSeconds;

-(void)clearStrings {
	for (int i=0; i < [progressLineArray count] ; i++) {
		[progressLineArray replaceObjectAtIndex:i withObject:@""];
	}
	
	currentWord = @"";
	currentLine = @"";
	
	if (specialCase) {
		displayLine = 0;
	} else {
		displayLine = 1;
	}
}
-(void) invalidateTimers {
	for (NSTimer *timer in self.timerArray) {
		[timer invalidate];
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
		displayLine = 1;
		dispLineArray = [[NSMutableArray alloc] init];
		progressLineArray = [[NSMutableArray alloc] initWithCapacity:10];
		[self clearStrings];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	NSString *lfill = @"11111111";
	
	float offset = 25;
	
	int totallinecount = [dispLineArray count] > 8 ? 8 : [dispLineArray count];
	for (int i = 0; i <totallinecount; i++) {
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		CGContextSelectFont(context, "Futura LT Book", FONTSIZE, kCGEncodingMacRoman);
		
		CGContextSetTextPosition(context, 0, (200+offset) - (i*25));
		CGContextShowText(context, [[dispLineArray objectAtIndex:i] UTF8String], strlen([[dispLineArray objectAtIndex:i] UTF8String]));
	}
	
	for (int i = 0; i <[progressLineArray count]; i++) {
		CGContextSetFillColorWithColor(context, [UIColor magentaColor].CGColor);
		CGContextSelectFont(context, "Futura LT Book", FONTSIZE, kCGEncodingMacRoman);
		
		CGContextSetTextPosition(context, 0, (200+offset) - (i*25));
		CGContextShowText(context, [[progressLineArray objectAtIndex:i] UTF8String], strlen([[progressLineArray objectAtIndex:i] UTF8String]));
	}
	
}

-(void)setLyrics:(NSString *)l {
	lyrics = [NSString stringWithString:l];
	lineTimes = [[NSMutableArray alloc] initWithCapacity:1];
	lineContents = [[NSMutableArray alloc] initWithCapacity:1];
	lineQueue = [[NSMutableArray alloc] initWithCapacity:1];
	[self parseLyrics];
	
	[NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(redraw) userInfo:nil repeats:YES];
}

-(void)redraw {
	[self setNeedsDisplay];
}

-(void)parseLyrics{
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
			
			float interval = lseconds - previousTime;
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
					float interval = seconds - prTime;
					prTime = seconds;
					[wordTimes addObject:[NSNumber numberWithFloat: seconds]];
					[wordContents addObject:[[[wordSplit objectAtIndex:j+1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] lowercaseString]];
					[tmpLineArr addObject:[[[wordSplit objectAtIndex:j+1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]lowercaseString]];
				}
			}
			[lineContents addObject: [NSString stringWithFormat:@"^^%@", [tmpLineArr componentsJoinedByString:@""]]];
			
			[lineQueue addObject: [tmpLineArr componentsJoinedByString:@""]];
			
			[lineTimes addObjectsFromArray:wordTimes];
			[lineContents addObjectsFromArray:wordContents];
		}
		//i++;
	}
	
	if ([lineTimes count] > 0) {
		[self.delegate countdownStart:[[lineTimes objectAtIndex:1] floatValue]];
	}
	
}

-(void)instantiateLyricFromLine:(int)startLine ToLine:(int)endLine {
	specialCase = YES;
	[self clearStrings];
	
	dispLineArray = [[NSMutableArray alloc] initWithArray:lineQueue];
	
	progressLineArray = [[NSMutableArray alloc] initWithArray:lineQueue];
	
	[self clearStrings];
	
	//NSLog(@"Lyrics: %@", dispLineArray);
}

-(void)startLyricEngineFromTime:(float)timeInSeconds {
	startTimeInSeconds = timeInSeconds;
	[self startLyricEngine];
}

-(void)startLyricEngine {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	//NSLog(@"lyric engine : %.2f to %.2f", startTimeInSeconds, endTimeInSeconds);
	
	float secondOverlay = 0.0f;
	self.timerArray = [[NSMutableArray alloc] initWithCapacity:1];
	for (int i=0; i< [lineTimes count]; i++) {
		if ([[lineTimes objectAtIndex:i] floatValue] > startTimeInSeconds) {
			//NSLog(@"%f, %@", [[lineTimes objectAtIndex:i] floatValue], [lineContents objectAtIndex:i]);
			
			NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[lineContents objectAtIndex:i], @"line", nil];
			NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:([[lineTimes objectAtIndex:i] floatValue] - startTimeInSeconds - secondOverlay) target:self selector:@selector(timerComplete:) userInfo:dict repeats:NO];
			[self.timerArray addObject:timer];
			//[self performSelector:@selector(timerComplete:) withObject:[lineContents objectAtIndex:i] afterDelay:[[lineTimes objectAtIndex:i] floatValue] - timeInSeconds - secondOverlay];
		}
		
	}
	[self clearStrings];
	
}
- (void)timerComplete:(NSTimer *)timer {
    NSDictionary *dict = [timer userInfo];
	
	NSString *string = [dict objectForKey:@"line"];
	NSLog(@"lyrline: '%@'", string);
	if (string == nil) {
		return;
	}
	
	NSString *line;
	if ([string hasPrefix:@"^^"]) {
		line = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"^"]];
		if ([line length] > 0) {
			displayLine ++;
		} else {
			displayLine = 0;
		}
		
		if (displayLine > 3) {
			[dispLineArray removeObjectAtIndex:0];  //pop line
			[dispLineArray removeObjectAtIndex:0];
			
			[progressLineArray removeObjectAtIndex:0];
			[progressLineArray removeObjectAtIndex:0];
			
			displayLine = 2;
		}
		currentWord = @"";
		
		
	} else {
		currentWord = [[NSString stringWithFormat:@"%@%@", currentWord, string]stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		
		[progressLineArray replaceObjectAtIndex:displayLine - 1 withObject:currentWord];
	}
	[self setNeedsDisplay];
}
@end
