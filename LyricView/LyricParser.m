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

-(void)clearStrings {
	line1Word = @"";
	line2Word = @"";
	line3Word = @"";
	
	line1Line = @"";
	line2Line = @"";
	line3Line = @"";
	currentWord = @"";
	currentLine = @"";
	displayLine = 1;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self clearStrings];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if (self) {
		[self clearStrings];
    }
    return self;	
}

-(void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSelectFont(context, "Helvetica", 16.0, kCGEncodingMacRoman);
	
	CGContextSetTextPosition(context, 0, 0);
	CGContextShowText(context, [currentLine UTF8String], strlen([currentLine UTF8String]));
		
	CGContextSetFillColorWithColor(context, [UIColor magentaColor].CGColor);
	CGContextSelectFont(context, "Helvetica", 16.0, kCGEncodingMacRoman);
	
	CGContextSetTextPosition(context, 0, 0);
	CGContextShowText(context, [currentWord UTF8String], strlen([currentWord UTF8String]));
	

	//Line1
	CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
	CGContextSelectFont(context, "Helvetica", 16.0, kCGEncodingMacRoman);
	
	CGContextSetTextPosition(context, 0, 90);
	CGContextShowText(context, [line1Line UTF8String], strlen([line1Line UTF8String]));
	
	//line2
	CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
	CGContextSelectFont(context, "Helvetica", 16.0, kCGEncodingMacRoman);
	
	CGContextSetTextPosition(context, 0, 60);
	CGContextShowText(context, [line2Line UTF8String], strlen([line2Line UTF8String]));
	
	//line3
	CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
	CGContextSelectFont(context, "Helvetica", 16.0, kCGEncodingMacRoman);
	
	CGContextSetTextPosition(context, 0, 30);
	CGContextShowText(context, [line3Line UTF8String], strlen([line3Line UTF8String]));
		
}

-(void)setLyrics:(NSString *)l {
	self.delegate = nil;
	lyrics = [NSString stringWithString:l];
	lineTimes = [[NSMutableArray alloc] initWithCapacity:1];
	lineContents = [[NSMutableArray alloc] initWithCapacity:1];
	[self parseLyrics];
	
	[NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(redraw) userInfo:nil repeats:YES];
}

-(void)redraw {
	[self setNeedsDisplay];
}

-(void)parseLyrics{
	NSArray *lineSplit = [lyrics componentsSeparatedByCharactersInSet:
						  [NSCharacterSet characterSetWithCharactersInString:@"[]"]];

	NSString *regex = @"\\d\\d[:]\\d\\d.\\d{1,}";
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
			[lineTimes addObject: [NSNumber numberWithFloat:seconds]];
			
			NSString *lineStr = [lineSplit objectAtIndex:i+1];
			//[lineContents addObject: lineStr];
			
			NSArray *wordSplit = [lineStr componentsSeparatedByCharactersInSet:
								  [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
			
			NSMutableArray *tmpLineArr = [[NSMutableArray alloc] initWithCapacity:1];
			wordTimes = [[NSMutableArray alloc] initWithCapacity:1];
			wordContents = [[NSMutableArray alloc] initWithCapacity:1];
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
					[wordTimes addObject:[NSNumber numberWithFloat: seconds]];
					[wordContents addObject:[[wordSplit objectAtIndex:j+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
					[tmpLineArr addObject:[[wordSplit objectAtIndex:j+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
				}
			}
			[lineContents addObject: [NSString stringWithFormat:@"^^%@", [tmpLineArr componentsJoinedByString:@" "]]];
			[lineTimes addObjectsFromArray:wordTimes];
			[lineContents addObjectsFromArray:wordContents];
		}
		//i++;
	}
}

-(void)startLyricEngineFromTime:(float)timeInSeconds {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	for (int i=0; i< [lineTimes count]; i++) {
		if ([[lineTimes objectAtIndex:i] floatValue] > timeInSeconds) {
			NSLog(@"%f, %@", [[lineTimes objectAtIndex:i] floatValue], [lineContents objectAtIndex:i]);
			[self performSelector:@selector(timerComplete:) withObject:[lineContents objectAtIndex:i] afterDelay:[[lineTimes objectAtIndex:i] floatValue] - timeInSeconds];
		}
	}
}

//-(void)startLineEngine {
//	float lineElapseTime = [[lineTimes lastObject] floatValue];
//	[self performSelector:@selector(clearLine) withObject:nil afterDelay:lineElapseTime];
//}
	 
-(void)clearLine {
	currentWord = @"";
	currentLine = [[lineContents lastObject]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	switch (displayLine) {
		case 3:
			displayLine = 0;
			line3Line = currentLine;
			break;
		case 2:
			line2Line = currentLine;
			break;
		case 1:
			line1Line = currentLine;
			break;
		default:
			break;
	}

	[lineTimes removeLastObject];
	[lineContents removeLastObject];

	displayLine ++;
}

-(void)timerComplete:(NSString *)string {
	if (string == nil) {
		return;
	}
	
	NSString *line;
	if ([string hasPrefix:@"^^"]) {
		line = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"^"]];
		
		currentWord = @"";
		currentLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		switch (displayLine) {
			case 3:
				displayLine = 0;
				line3Line = currentLine;
				break;
			case 2:
				line2Line = currentLine;
				break;
			case 1:
				line1Line = currentLine;
				break;
			default:
				break;
		}
		
		displayLine ++;

	} else {
		currentWord = [[NSString stringWithFormat:@"%@ %@", currentWord, string]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	[self setNeedsDisplay];
}
@end
