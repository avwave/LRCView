//
//  LyricParser.h
//  LyricView
//
//  Created by Arvin Rimorin on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LyricParserDelegate <NSObject>
@required
-(void)displayStringIntoLabel :(NSString *)component;

@end

@interface LyricParser : NSObject {
	NSString *lyrics;
	NSMutableArray *lineTimes;
	NSMutableArray *lineContents;
	
	NSMutableArray *wordTimes;
	NSMutableArray *wordContents;
	id <LyricParserDelegate> delegate;
}
@property (retain) id delegate;

-(id)initWithLyrics:(NSString *)l;
-(void)parseLyrics;
-(NSString *)nextLine;
-(void)timerComplete;
-(void)startLyricEngineFromTime:(float)timeInSeconds;
@end
