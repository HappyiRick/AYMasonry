//
//  MASCompositeConstraint.m
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASCompositeConstraint.h"
#import "MASConstraint+Private.h"

@interface MASCompositeConstraint () <MASConstraintDelegate>
/// 保存用于标识约束的key
@property (nonatomic, strong) id mas_key;
/// 保存初始化时传入的约束数组对象
@property (nonatomic, strong) NSMutableArray *childConstraints;

@end

@implementation MASCompositeConstraint

- (id)initWithChildren:(NSArray *)children {
    self = [super init];
    if (!self) return nil;

    _childConstraints = [children mutableCopy];
    // 遍历约束对象设置代理
    for (MASConstraint *constraint in _childConstraints) {
        constraint.delegate = self;
    }

    return self;
}

#pragma mark - MASConstraintDelegate

- (void)constraint:(MASConstraint *)constraint shouldBeReplacedWithConstraint:(MASConstraint *)replacementConstraint {
    // 获取传入约束对象在数组中的位置, 然后替换
    NSUInteger index = [self.childConstraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.childConstraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (MASConstraint *)constraint:(MASConstraint __unused *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    // 获取当前对象的代理, 也就是 MASConstraintMaker 对象
    id<MASConstraintDelegate> strongDelegate = self.delegate;
    // 调用 MASConstraintMaker 对象对该代理方法的实现获取到新约束对象
    MASConstraint *newConstraint = [strongDelegate constraint:self addConstraintWithLayoutAttribute:layoutAttribute];
    // 设置新约束对象的代理对象
    newConstraint.delegate = self;
    // 保存约束对象
    [self.childConstraints addObject:newConstraint];
    return newConstraint;
}

#pragma mark - NSLayoutConstraint multiplier proxies 

- (MASConstraint * (^)(CGFloat))multipliedBy {
    return ^id(CGFloat multiplier) {
        for (MASConstraint *constraint in self.childConstraints) {
            constraint.multipliedBy(multiplier);
        }
        return self;
    };
}

- (MASConstraint * (^)(CGFloat))dividedBy {
    return ^id(CGFloat divider) {
        for (MASConstraint *constraint in self.childConstraints) {
            constraint.dividedBy(divider);
        }
        return self;
    };
}

#pragma mark - MASLayoutPriority proxy

- (MASConstraint * (^)(MASLayoutPriority))priority {
    return ^id(MASLayoutPriority priority) {
        for (MASConstraint *constraint in self.childConstraints) {
            constraint.priority(priority);
        }
        return self;
    };
}

#pragma mark - NSLayoutRelation proxy

- (MASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation {
    return ^id(id attr, NSLayoutRelation relation) {
        for (MASConstraint *constraint in self.childConstraints.copy) {
            constraint.equalToWithRelation(attr, relation);
        }
        return self;
    };
}

#pragma mark - attribute chaining

- (MASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    [self constraint:self addConstraintWithLayoutAttribute:layoutAttribute];
    return self;
}

#pragma mark - Animator proxy

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)

- (MASConstraint *)animator {
    for (MASConstraint *constraint in self.childConstraints) {
        [constraint animator];
    }
    return self;
}

#endif

#pragma mark - debug helpers

- (MASConstraint * (^)(id))key {
    return ^id(id key) {
        self.mas_key = key;
        int i = 0;
        for (MASConstraint *constraint in self.childConstraints) {
            constraint.key([NSString stringWithFormat:@"%@[%d]", key, i++]);
        }
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant setters

- (void)setInsets:(MASEdgeInsets)insets {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.insets = insets;
    }
}

- (void)setInset:(CGFloat)inset {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.inset = inset;
    }
}

- (void)setOffset:(CGFloat)offset {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.offset = offset;
    }
}

- (void)setSizeOffset:(CGSize)sizeOffset {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.sizeOffset = sizeOffset;
    }
}

- (void)setCenterOffset:(CGPoint)centerOffset {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.centerOffset = centerOffset;
    }
}

#pragma mark - MASConstraint

- (void)activate {
    for (MASConstraint *constraint in self.childConstraints) {
        [constraint activate];
    }
}

- (void)deactivate {
    for (MASConstraint *constraint in self.childConstraints) {
        [constraint deactivate];
    }
}

- (void)install {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
}

- (void)uninstall {
    for (MASConstraint *constraint in self.childConstraints) {
        [constraint uninstall];
    }
}

@end
