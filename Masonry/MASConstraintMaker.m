//
//  MASConstraintMaker.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASConstraintMaker.h"
#import "MASViewConstraint.h"
#import "MASCompositeConstraint.h"
#import "MASConstraint+Private.h"
#import "MASViewAttribute.h"
#import "View+MASAdditions.h"

@interface MASConstraintMaker () <MASConstraintDelegate>
/// 保存view1
@property (nonatomic, weak) MAS_VIEW *view;
/// 保存设置的约束对象
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation MASConstraintMaker

- (id)initWithView:(MAS_VIEW *)view {
    self = [super init];
    if (!self) return nil;
    // 保存属性
    self.view = view;
    self.constraints = NSMutableArray.new;
    
    return self;
}

- (NSArray *)install {
    // 如果设置了安装前移除已安装的约束
    if (self.removeExisting) {
        // 获取安装在当前视图上的所有约束对象
        NSArray *installedConstraints = [MASViewConstraint installedConstraintsForView:self.view];
        // 遍历已安装的约束对象并调用它们的卸载方法
        for (MASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    // 获取已设置的约束对象
    NSArray *constraints = self.constraints.copy;
    // 遍历设置的约束对象, 设置属性, 并调用它们的安装方法
    for (MASConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    // 清空保存设置的约束对象的数组
    [self.constraints removeAllObjects];
    // 返回已安装的约束对象
    return constraints;
}

#pragma mark - MASConstraintDelegate

- (void)constraint:(MASConstraint *)constraint shouldBeReplacedWithConstraint:(MASConstraint *)replacementConstraint {
    // 获取要替换约束在当前数组中的索引
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    // 替换数组中地址索引的约束
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (MASConstraint *)constraint:(MASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    // 根据当前视图和传入的参数创建视图属性封装对象
    MASViewAttribute *viewAttribute = [[MASViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    // 根据生成的视图属性封装对象创建视图约束封装对象
    MASViewConstraint *newConstraint = [[MASViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    // 判断参数是否是MASViewConstraint 类型的
    if ([constraint isKindOfClass:MASViewConstraint.class]) {
        // 如果是, 也就是设置多约束 make.top.left.equalTo(self.view);
        // 创建数组保存约束对象
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        // 创建多约束对象
        MASCompositeConstraint *compositeConstraint = [[MASCompositeConstraint alloc] initWithChildren:children];
        // 设置代理对象
        compositeConstraint.delegate = self;
        // 用多约束对象替换之前的约束对象
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        // 返回新创建的多约束对象
        return compositeConstraint;
    }
    if (!constraint) {
        // 如果没有传参, 也就是第一次设置
        // 设置代理对象
        newConstraint.delegate = self;
        // 将约束对象添加到数组中保存
        [self.constraints addObject:newConstraint];
    }
    // 返回约束对象
    return newConstraint;
}

- (MASConstraint *)addConstraintWithAttributes:(MASAttribute)attrs {
    // 定义变量获取所有可设置的枚举值
    // __unused 的作用是：如果定义的变量未使用的话编译器就会报警, 添加 _unused 前缀以后就不会有报警
    __unused MASAttribute anyAttribute = (MASAttributeLeft | MASAttributeRight | MASAttributeTop | MASAttributeBottom | MASAttributeLeading
                                          | MASAttributeTrailing | MASAttributeWidth | MASAttributeHeight | MASAttributeCenterX
                                          | MASAttributeCenterY | MASAttributeBaseline
                                          | MASAttributeFirstBaseline | MASAttributeLastBaseline
#if TARGET_OS_IPHONE || TARGET_OS_TV
                                          | MASAttributeLeftMargin | MASAttributeRightMargin | MASAttributeTopMargin | MASAttributeBottomMargin
                                          | MASAttributeLeadingMargin | MASAttributeTrailingMargin | MASAttributeCenterXWithinMargins
                                          | MASAttributeCenterYWithinMargins
#endif
                                          );
    // 传入的参数必须是枚举中的枚举值
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    // 创建变量保存视图属性封装对象
    NSMutableArray *attributes = [NSMutableArray array];
    
    // 根据传入的枚举值添加相应的视图属性封装对象
    if (attrs & MASAttributeLeft) [attributes addObject:self.view.mas_left];
    if (attrs & MASAttributeRight) [attributes addObject:self.view.mas_right];
    if (attrs & MASAttributeTop) [attributes addObject:self.view.mas_top];
    if (attrs & MASAttributeBottom) [attributes addObject:self.view.mas_bottom];
    if (attrs & MASAttributeLeading) [attributes addObject:self.view.mas_leading];
    if (attrs & MASAttributeTrailing) [attributes addObject:self.view.mas_trailing];
    if (attrs & MASAttributeWidth) [attributes addObject:self.view.mas_width];
    if (attrs & MASAttributeHeight) [attributes addObject:self.view.mas_height];
    if (attrs & MASAttributeCenterX) [attributes addObject:self.view.mas_centerX];
    if (attrs & MASAttributeCenterY) [attributes addObject:self.view.mas_centerY];
    if (attrs & MASAttributeBaseline) [attributes addObject:self.view.mas_baseline];
    if (attrs & MASAttributeFirstBaseline) [attributes addObject:self.view.mas_firstBaseline];
    if (attrs & MASAttributeLastBaseline) [attributes addObject:self.view.mas_lastBaseline];
    
#if TARGET_OS_IPHONE || TARGET_OS_TV
    
    if (attrs & MASAttributeLeftMargin) [attributes addObject:self.view.mas_leftMargin];
    if (attrs & MASAttributeRightMargin) [attributes addObject:self.view.mas_rightMargin];
    if (attrs & MASAttributeTopMargin) [attributes addObject:self.view.mas_topMargin];
    if (attrs & MASAttributeBottomMargin) [attributes addObject:self.view.mas_bottomMargin];
    if (attrs & MASAttributeLeadingMargin) [attributes addObject:self.view.mas_leadingMargin];
    if (attrs & MASAttributeTrailingMargin) [attributes addObject:self.view.mas_trailingMargin];
    if (attrs & MASAttributeCenterXWithinMargins) [attributes addObject:self.view.mas_centerXWithinMargins];
    if (attrs & MASAttributeCenterYWithinMargins) [attributes addObject:self.view.mas_centerYWithinMargins];
    
#endif
    // 创建变量保存视图约束封装对象
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    // 遍历视图属性封装对象
    for (MASViewAttribute *a in attributes) {
        // 创建视图约束封装对象, 并添加到数组中
        [children addObject:[[MASViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    // 创建多约束封装对象
    MASCompositeConstraint *constraint = [[MASCompositeConstraint alloc] initWithChildren:children];
    // 设置代理对象
    constraint.delegate = self;
    // 添加到数组中保存
    [self.constraints addObject:constraint];
    // 多约束封装对象
    return constraint;
}

#pragma mark - standard Attributes

- (MASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    // 调用MASConstraintDelegate 中的方法, 并且第一个参数传 nil, 也就是创建 MASViewConstraint 类型对象
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
}

- (MASConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (MASConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (MASConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (MASConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (MASConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (MASConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (MASConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (MASConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (MASConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (MASConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (MASConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

- (MASConstraint *(^)(MASAttribute))attributes {
    return ^(MASAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
}

- (MASConstraint *)firstBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeFirstBaseline];
}

- (MASConstraint *)lastBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLastBaseline];
}

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (MASConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (MASConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (MASConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (MASConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (MASConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (MASConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (MASConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (MASConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif


#pragma mark - composite Attributes

- (MASConstraint *)edges {
    return [self addConstraintWithAttributes:MASAttributeTop | MASAttributeLeft | MASAttributeRight | MASAttributeBottom];
}

- (MASConstraint *)size {
    return [self addConstraintWithAttributes:MASAttributeWidth | MASAttributeHeight];
}

- (MASConstraint *)center {
    return [self addConstraintWithAttributes:MASAttributeCenterX | MASAttributeCenterY];
}

#pragma mark - grouping

- (MASConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        // 记录执行block之前约束封装对象的数量
        NSInteger previousCount = self.constraints.count;
        // 执行block
        group();
        // 获取执行block之后新增的约束封装对象
        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        // 将新增的约束封装对象封装成一个多约束封装对象
        MASCompositeConstraint *constraint = [[MASCompositeConstraint alloc] initWithChildren:children];
        // 设置代理
        constraint.delegate = self;
        // 返回多约束封装对象
        return constraint;
    };
}

@end
