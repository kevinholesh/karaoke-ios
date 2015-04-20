//
//  LyricParser.h
//  karaoke
//
//  Created by Kevin Holesh on 4/16/15.
//  Copyright (c) 2015 Broadway Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LyricParser : NSObject

+ (NSDictionary *)parseFromFile:(NSString *)path;
+ (NSString *)humanReadableLine:(NSArray *)timestampedWords;
+ (NSAttributedString *)humanReadableLine:(NSArray *)timestampedWords forIndex:(int)i;

@end
