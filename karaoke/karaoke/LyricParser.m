//
//  LyricParser.m
//  karaoke
//
//  Created by Kevin Holesh on 4/16/15.
//  Copyright (c) 2015 Broadway Lab. All rights reserved.
//

#import "LyricParser.h"

@implementation LyricParser

+ (NSDictionary *)parseFromFile:(NSString *)path {
    NSError *error = nil;
    NSString *raw = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!raw || error)
        assert(@"ERROR: The .lrc file does not exist or is not utf8 encoded");
    
    NSArray *lines = [raw componentsSeparatedByString:@"\n"];
    return [self parseRawLRC:lines];
}

+ (NSDictionary *)parseRawLRC:(NSArray *)rawLines {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    int offset = 0;
    
    for (NSString *rawLine in rawLines) {
        if ([rawLine isEqualToString:@""]) {
            [lines addObject:[NSArray array]];
            
        } else if (rawLine.length > 2) {
            NSString *first = [rawLine substringWithRange:NSMakeRange(1,2)];
            if ([[NSScanner scannerWithString:first] scanFloat:NULL]) {
                
                // Change the first timestamp block [01:07.609] to <01:07.609>
                NSMutableArray *line = [[NSMutableArray alloc] init];
                NSMutableString *arrowedString = rawLine.mutableCopy;
                [arrowedString replaceOccurrencesOfString:@"["
                                               withString:@"<"
                                                  options:NSCaseInsensitiveSearch
                                                    range:NSMakeRange(0, arrowedString.length)];
                [arrowedString replaceOccurrencesOfString:@"]"
                                               withString:@">"
                                                  options:NSCaseInsensitiveSearch
                                                    range:NSMakeRange(0, arrowedString.length)];

                // Split up into words with timestamp
                NSArray *timestampedWords = [arrowedString componentsSeparatedByString:@"<"];
                for (NSString *timestampedWord in timestampedWords) {
                    NSArray *word = [timestampedWord componentsSeparatedByString:@">"];
                    if (word.count == 2) {
                        // Convert the timestamp to something usable
                        NSString *timing = word[0];
                        float time = 0.0;
                        NSArray *timeComponents = [timing componentsSeparatedByString:@":"];
                        if (timeComponents.count == 2) {
                            int minutes = [timeComponents[0] intValue];
                            float seconds = [timeComponents[1] floatValue];
                            time = (minutes*60) + seconds + offset;
                        }
                        
                        NSString *text = word[1];
                        [line addObject:@[[NSNumber numberWithFloat:time], text]];
                    }
                }
                [lines addObject:line];
                
            } else {
                NSCharacterSet *toTrim = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
                NSString *property = [rawLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                property = [property stringByTrimmingCharactersInSet:toTrim];
                NSArray *components = [property componentsSeparatedByString:@":"];
                if (components.count == 2) {
                    NSString *key = [NSString string];
                    if ([components[0] isEqualToString:@"ti"]) key = @"title";
                    if ([components[0] isEqualToString:@"ar"]) key = @"artist";
                    if ([components[0] isEqualToString:@"al"]) key = @"album";
                    if ([components[0] isEqualToString:@"offset"]) {
                        key = @"offset";
                        offset = [components[1] intValue];
                    }
                    result[key] = components[1];
                }
                

            }

        }
    }
    result[@"lines"] = lines;

    return [[NSDictionary alloc] initWithDictionary:result];
}

+ (NSString *)humanReadableLine:(NSArray *)timestampedWords {
    NSString *line = @"";
    for (NSArray *timestampedWord in timestampedWords) {
        if (timestampedWord.count == 2) {
            line = [line stringByAppendingString:timestampedWord[1]];
        }
    }
    return line;
}

+ (NSAttributedString *)humanReadableLine:(NSArray *)timestampedWords forIndex:(int)i {
    NSDictionary *pastAttrs = @{NSForegroundColorAttributeName:UIColor.greenColor};
    NSDictionary *futureAttrs = @{NSForegroundColorAttributeName:UIColor.blackColor};
    
    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] init];
    int index = 0;
    for (NSArray *timestampedWord in timestampedWords) {
        if (timestampedWord.count == 2) {
            NSDictionary *attrs = index <= i ? pastAttrs : futureAttrs;
            NSAttributedString *word = [[NSAttributedString alloc] initWithString:timestampedWord[1] attributes:attrs];
            [line appendAttributedString:word];
        }
        index++;
    }
    return line;
}

@end
