//
//  NSLayoutConstraint+MASDebugAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 3/08/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSLayoutConstraint+MASDebugAdditions.h"
#import "MASConstraint.h"
#import "MASLayoutConstraint.h"

@implementation NSLayoutConstraint (MASDebugAdditions)

#pragma mark - description maps

+ (NSDictionary *)layoutRelationDescriptionsByValue {
    static dispatch_once_t once;
    static NSDictionary *descriptionMap;
    dispatch_once(&once, ^{
        descriptionMap = @{
            @(NSLayoutRelationEqual)                : @"==",
            @(NSLayoutRelationGreaterThanOrEqual)   : @">=",
            @(NSLayoutRelationLessThanOrEqual)      : @"<=",
        };
    });
    return descriptionMap;
}

+ (NSDictionary *)layoutAttributeDescriptionsByValue {
    static dispatch_once_t once;
    static NSMutableDictionary *descriptionMap;
    dispatch_once(&once, ^{
        descriptionMap[@(NSLayoutAttributeTop)] = @"top";
        descriptionMap[@(NSLayoutAttributeLeft)] = @"left";
        descriptionMap[@(NSLayoutAttributeBottom)] = @"bottom";
        descriptionMap[@(NSLayoutAttributeRight)] = @"right";
        descriptionMap[@(NSLayoutAttributeLeading)] = @"leading";
        descriptionMap[@(NSLayoutAttributeTrailing)] = @"trailing";
        descriptionMap[@(NSLayoutAttributeWidth)] = @"width";
        descriptionMap[@(NSLayoutAttributeHeight)] = @"height";
        descriptionMap[@(NSLayoutAttributeCenterX)] = @"centerX";
        descriptionMap[@(NSLayoutAttributeCenterY)] = @"centerY";
        descriptionMap[@(NSLayoutAttributeBaseline)] = @"baseline";
        descriptionMap[@(NSLayoutAttributeFirstBaseline)] = @"firstBaseline";
        descriptionMap[@(NSLayoutAttributeLastBaseline)] = @"lastBaseline";
        
        
#if TARGET_OS_IPHONE || TARGET_OS_TV
        descriptionMap[@(NSLayoutAttributeLeftMargin)] = @"leftMargin";
        descriptionMap[@(NSLayoutAttributeRightMargin)] = @"rightMargin";
        descriptionMap[@(NSLayoutAttributeTopMargin)] = @"topMargin";
        descriptionMap[@(NSLayoutAttributeBottomMargin)] = @"bottomMargin";
        descriptionMap[@(NSLayoutAttributeLeadingMargin)] = @"leadingMargin";
        descriptionMap[@(NSLayoutAttributeTrailingMargin)] = @"trailingMargin";
        descriptionMap[@(NSLayoutAttributeCenterXWithinMargins)] = @"centerXWithinMargins";
        descriptionMap[@(NSLayoutAttributeCenterYWithinMargins)] = @"centerYWithinMargins";
#endif
    
    });
    return [descriptionMap copy];
}


+ (NSDictionary *)layoutPriorityDescriptionsByValue {
    static dispatch_once_t once;
    static NSDictionary *descriptionMap;
    dispatch_once(&once, ^{
#if TARGET_OS_IPHONE || TARGET_OS_TV
        descriptionMap = @{
            @(MASLayoutPriorityDefaultHigh)      : @"high",
            @(MASLayoutPriorityDefaultLow)       : @"low",
            @(MASLayoutPriorityDefaultMedium)    : @"medium",
            @(MASLayoutPriorityRequired)         : @"required",
            @(MASLayoutPriorityFittingSizeLevel) : @"fitting size",
        };
#elif TARGET_OS_MAC
        descriptionMap = @{
            @(MASLayoutPriorityDefaultHigh)                 : @"high",
            @(MASLayoutPriorityDragThatCanResizeWindow)     : @"drag can resize window",
            @(MASLayoutPriorityDefaultMedium)               : @"medium",
            @(MASLayoutPriorityWindowSizeStayPut)           : @"window size stay put",
            @(MASLayoutPriorityDragThatCannotResizeWindow)  : @"drag cannot resize window",
            @(MASLayoutPriorityDefaultLow)                  : @"low",
            @(MASLayoutPriorityFittingSizeCompression)      : @"fitting size",
            @(MASLayoutPriorityRequired)                    : @"required",
        };
#endif
    });
    return descriptionMap;
}

#pragma mark - description override

+ (NSString *)descriptionForObject:(id)obj {
    if ([obj respondsToSelector:@selector(mas_key)] && [obj mas_key]) {
        return [NSString stringWithFormat:@"%@:%@", [obj class], [obj mas_key]];
    }
    return [NSString stringWithFormat:@"%@:%p", [obj class], obj];
}

- (NSString *)description {
    NSMutableString *description = [[NSMutableString alloc] initWithString:@"<"];

    [description appendString:[self.class descriptionForObject:self]];

    [description appendFormat:@" %@", [self.class descriptionForObject:self.firstItem]];
    if (self.firstAttribute != NSLayoutAttributeNotAnAttribute) {
        [description appendFormat:@".%@", self.class.layoutAttributeDescriptionsByValue[@(self.firstAttribute)]];
    }

    [description appendFormat:@" %@", self.class.layoutRelationDescriptionsByValue[@(self.relation)]];

    if (self.secondItem) {
        [description appendFormat:@" %@", [self.class descriptionForObject:self.secondItem]];
    }
    if (self.secondAttribute != NSLayoutAttributeNotAnAttribute) {
        [description appendFormat:@".%@", self.class.layoutAttributeDescriptionsByValue[@(self.secondAttribute)]];
    }
    
    if (self.multiplier != 1) {
        [description appendFormat:@" * %g", self.multiplier];
    }
    
    if (self.secondAttribute == NSLayoutAttributeNotAnAttribute) {
        [description appendFormat:@" %g", self.constant];
    } else {
        if (self.constant) {
            [description appendFormat:@" %@ %g", (self.constant < 0 ? @"-" : @"+"), ABS(self.constant)];
        }
    }

    if (self.priority != MASLayoutPriorityRequired) {
        [description appendFormat:@" ^%@", self.class.layoutPriorityDescriptionsByValue[@(self.priority)] ?: [NSNumber numberWithDouble:self.priority]];
    }

    [description appendString:@">"];
    return description;
}

@end
