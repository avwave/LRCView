//
//  LyricParser.h
//  LyricView
//
//  Created by Arvin Rimorin on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LyricParserDelegate
@required
-(void)displayStringIntoLabel :(NSString *)component;
@end

@interface LyricParser : UIView {
	NSString *lyrics;
	NSMutableArray *lineTimes;
	NSMutableArray *lineContents;
	
	NSMutableArray *wordTimes;
	NSMutableArray *wordContents;
	NSString *currentWord;
	NSString *currentLine;
}
@property (assign) id <LyricParserDelegate> delegate;

-(void)redraw;
-(void)setLyrics:(NSString *)l;
-(void)parseLyrics;
-(NSString *)nextLine;
-(void)timerComplete;
-(void)startLyricEngineFromTime:(float)timeInSeconds;
-(void)startLineEngine;
@end
