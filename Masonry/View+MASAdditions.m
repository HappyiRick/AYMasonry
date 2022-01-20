//
//  UIView+MASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+MASAdditions.h"
#import <objc/runtime.h>

@implementation MAS_VIEW (MASAdditions)
/**
 这三个方法的实现大体上是相同的：

 将当前视图的 translatesAutoresizingMaskIntoConstraints 属性设为 NO。
 以当前视图为参数创建 MASConstraintMaker 对象。
 根据不同方法约束工厂对象会被设置不同的属性值：

 mas_makeConstraints: 方法中不设置属性。
 mas_updateConstraints: 方法会将 updateExisting 属性设置为 YES。
 mas_remakeConstraints: 方法会将 removeExisting 属性设置为 YES。


 通过 block 回调约束工厂对象，以便用户创建约束。
 安装用户创建的约束。
 返回已安装的约束对象数组
 */
- (NSArray *)mas_makeConstraints:(void(^)(MASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_updateConstraints:(void(^)(MASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_remakeConstraints:(void(^)(MASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (MASViewAttribute *)mas_left {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (MASViewAttribute *)mas_top {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (MASViewAttribute *)mas_right {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (MASViewAttribute *)mas_bottom {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (MASViewAttribute *)mas_leading {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (MASViewAttribute *)mas_trailing {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (MASViewAttribute *)mas_width {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (MASViewAttribute *)mas_height {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (MASViewAttribute *)mas_centerX {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (MASViewAttribute *)mas_centerY {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (MASViewAttribute *)mas_baseline {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (MASViewAttribute *(^)(NSLayoutAttribute))mas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

- (MASViewAttribute *)mas_firstBaseline {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (MASViewAttribute *)mas_lastBaseline {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (MASViewAttribute *)mas_leftMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (MASViewAttribute *)mas_rightMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (MASViewAttribute *)mas_topMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (MASViewAttribute *)mas_bottomMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (MASViewAttribute *)mas_leadingMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (MASViewAttribute *)mas_trailingMargin {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (MASViewAttribute *)mas_centerXWithinMargins {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (MASViewAttribute *)mas_centerYWithinMargins {
    return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuide {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeNotAnAttribute];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideLeading {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeading];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideTrailing {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTrailing];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideLeft {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideRight {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideTop {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideBottom {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideWidth {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeWidth];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideHeight {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeHeight];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideCenterX {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeCenterX];
}

- (MASViewAttribute *)mas_safeAreaLayoutGuideCenterY {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeCenterY];
}

#endif

#pragma mark - associated properties
// 关联对象绑定属性
- (id)mas_key {
    return objc_getAssociatedObject(self, @selector(mas_key));
}

- (void)setMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(mas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas_closestCommonSuperview:(MAS_VIEW *)view {
    // 创建父视图
    MAS_VIEW *closestCommonSuperview = nil;
    // 记录其他view父视图
    MAS_VIEW *secondViewSuperview = view;
    // 只要没有找到父视图, 并且有传入视图的父视图, 就进行循环
    while (!closestCommonSuperview && secondViewSuperview) {
        // 创建变量保存当前的视图的父视图
        MAS_VIEW *firstViewSuperview = self;
        // 只要没有找到公共父视图, 并且有当前视图的父视图, 就进行循环
        while (!closestCommonSuperview && firstViewSuperview) {
            // 如果传入视图的父视图和当前视图的父视图是同一个视图
            if (secondViewSuperview == firstViewSuperview) {
                // 则公共父视图找到了, 保存并跳出循环
                closestCommonSuperview = secondViewSuperview;
            }
            // 如果当前的父视图不满足条件的话就取当前父视图的父视图
            firstViewSuperview = firstViewSuperview.superview;
        }
        // 如果传入视图的父视图不满足条件的话就获取传入视图父视图的父视图
        secondViewSuperview = secondViewSuperview.superview;
    }
    // 返回公共父视图
    return closestCommonSuperview;
}

@end
