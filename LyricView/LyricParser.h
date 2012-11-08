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
-(void)playAudio;
-(void)countdownStart :(float)cTime;
@end

@interface LyricParser : UIView {
	NSString *lyrics;
	NSMutableArray *lineTimes;
	NSMutableArray *lineContents;
	NSMutableArray *lineQueue;
	
	NSMutableArray *wordTimes;
	NSMutableArray *wordContents;
	NSString *currentWord;
	NSString *currentLine;
	
	NSMutableArray *dispLineArray;
	NSMutableArray *progressLineArray;
	NSMutableArray *dispWordArray;
	
    float startTimeInSeconds;
    float endTimeInSeconds;
    
	int displayLine;
}
@property (assign) id delegate;
@property (nonatomic, retain) NSMutableArray* timerArray;

@property (readwrite) float startTimeInSeconds;
@property (readwrite) float endTimeInSeconds;


-(void)redraw;
-(void)setLyrics:(NSString *)l;
-(void)parseLyrics;
-(NSString *)nextLine;
-(void)startLyricEngineFromTime:(float)timeInSeconds;
-(void)startLyricEngine;
-(void)startLineEngine;
-(void)clearStrings;
-(void)invalidateTimers;
-(void)instantiateLyricFromLine:(int)startLine ToLine:(int)endLine;
@end
