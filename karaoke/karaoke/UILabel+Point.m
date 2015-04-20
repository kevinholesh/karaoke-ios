//
//  UILabel+Point.m
//  karaoke
//
//  Created by Kevin Holesh on 4/17/15.
//  Copyright (c) 2015 Broadway Lab. All rights reserved.
//

#import "UILabel+Point.h"

@implementation UILabel (Point)

- (CGFloat)xForLetterAtIndex:(NSUInteger)index {
    if (self.text.length == 0)
        return self.bounds.origin.x;
    
    NSString *letter = [self.text substringWithRange:NSMakeRange(index, 1)];
    int end = index-1;
    if (end < 0)
        end = 0;
    NSString *lineSubstr = [self.text substringWithRange:NSMakeRange(0, end)];
    float x = [lineSubstr sizeWithAttributes:@{NSFontAttributeName:self.font}].width - [letter sizeWithAttributes:@{NSFontAttributeName:self.font}].width;
    
    return x;
}

@end
