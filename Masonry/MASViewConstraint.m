//
//  MASViewConstraint.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASViewConstraint.h"
#import "MASConstraint+Private.h"
#import "MASCompositeConstraint.h"
#import "MASLayoutConstraint.h"
#import "View+MASAdditions.h"
#import <objc/runtime.h>

@interface MAS_VIEW (MASConstraints)

@property (nonatomic, readonly) NSMutableSet *mas_installedConstraints;

@end

@implementation MAS_VIEW (MASConstraints)

static char kInstalledConstraintsKey;

- (NSMutableSet *)mas_installedConstraints {
    NSMutableSet *constraints = objc_getAssociatedObject(self, &kInstalledConstraintsKey);
    if (!constraints) {
        constraints = [NSMutableSet set];
        objc_setAssociatedObject(self, &kInstalledConstraintsKey, constraints, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return constraints;
}

@end


@interface MASViewConstraint ()
/// 保存参考约束视图及其属性类对象, 也就是 view2 + attr2
@property (nonatomic, strong, readwrite) MASViewAttribute *secondViewAttribute;
/// 保存安装约束的接收视图
@property (nonatomic, weak) MAS_VIEW *installedView;
/// 保存约束对象
@property (nonatomic, weak) MASLayoutConstraint *layoutConstraint;
/// 保存约束关系, 也就是relation
@property (nonatomic, assign) NSLayoutRelation layoutRelation;
/// 保存约束优先级
@property (nonatomic, assign) MASLayoutPriority layoutPriority;
/// 保存约束乘数, 也就是multiplier
@property (nonatomic, assign) CGFloat layoutMultiplier;
/// 保存约束常数, 即 c
@property (nonatomic, assign) CGFloat layoutConstant;
/// 保存是否已经设置过约束关系
@property (nonatomic, assign) BOOL hasLayoutRelation;
/// 保存约束对象标识
@property (nonatomic, strong) id mas_key;
/// 保存安装约束时是否使用动画
@property (nonatomic, assign) BOOL useAnimator;

@end

@implementation MASViewConstraint

- (id)initWithFirstViewAttribute:(MASViewAttribute *)firstViewAttribute {
    self = [super init];
    if (!self) return nil;
    // 保存参数
    _firstViewAttribute = firstViewAttribute;
    // 设置属性
    self.layoutPriority = MASLayoutPriorityRequired;
    self.layoutMultiplier = 1;
    
    return self;
}

#pragma mark - NSCoping

- (id)copyWithZone:(NSZone __unused *)zone {
    MASViewConstraint *constraint = [[MASViewConstraint alloc] initWithFirstViewAttribute:self.firstViewAttribute];
    constraint.layoutConstant = self.layoutConstant;
    constraint.layoutRelation = self.layoutRelation;
    constraint.layoutPriority = self.layoutPriority;
    constraint.layoutMultiplier = self.layoutMultiplier;
    constraint.delegate = self.delegate;
    return constraint;
}

#pragma mark - Public

+ (NSArray *)installedConstraintsForView:(MAS_VIEW *)view {
    // 获取保存的所有元素
    return [view.mas_installedConstraints allObjects];
}

#pragma mark - Private
// 重写setter
- (void)setLayoutConstant:(CGFloat)layoutConstant {
    _layoutConstant = layoutConstant;

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)
    if (self.useAnimator) {
        [self.layoutConstraint.animator setConstant:layoutConstant];
    } else {
        self.layoutConstraint.constant = layoutConstant;
    }
#else
    self.layoutConstraint.constant = layoutConstant;
#endif
}

- (void)setLayoutRelation:(NSLayoutRelation)layoutRelation {
    // 保存参数
    _layoutRelation = layoutRelation;
    // 保存状态
    self.hasLayoutRelation = YES;
}

// 判断当前系统版本是否支持 isActive 属性，iOS8 之后的版本支持这个属性，用于版本兼容
- (BOOL)supportsActiveProperty {
    return [self.layoutConstraint respondsToSelector:@selector(isActive)];
}

// 判断约束对象是否处于活动状态
- (BOOL)isActive {
    BOOL active = YES;
    // 判断是否支持这个属性
    if ([self supportsActiveProperty]) {
        // 获取该属性的值
        active = [self.layoutConstraint isActive];
    }

    return active;
}

// 判断约束对象是否已安装
- (BOOL)hasBeenInstalled {
    // 必须有约束对象, 并且约束对象处于活动状态, 才是已安装
    return (self.layoutConstraint != nil) && [self isActive];
}

- (void)setSecondViewAttribute:(id)secondViewAttribute {
    if ([secondViewAttribute isKindOfClass:NSValue.class]) {
        // 如果传入的约束属性是 NSValue 类型的, 就调用父类 MASConstraint 中的方法处理
        [self setLayoutConstantWithValue:secondViewAttribute];
    } else if ([secondViewAttribute isKindOfClass:MAS_VIEW.class]) {
        // 如果传入的约束属性是UIView类型的, 就以传入的视图和 attr1 实例化一个约束视图及其属性类并保存
        _secondViewAttribute = [[MASViewAttribute alloc] initWithView:secondViewAttribute layoutAttribute:self.firstViewAttribute.layoutAttribute];
    } else if ([secondViewAttribute isKindOfClass:MASViewAttribute.class]) {
        // 如果传入的约束属性是 MASViewAttribute 类型的, 就直接保存
        MASViewAttribute *attr = secondViewAttribute;
        if (attr.layoutAttribute == NSLayoutAttributeNotAnAttribute) {
            _secondViewAttribute = [[MASViewAttribute alloc] initWithView:attr.view item:attr.item layoutAttribute:self.firstViewAttribute.layoutAttribute];;
        } else {
            _secondViewAttribute = secondViewAttribute;
        }
    } else {
        // 传入的参数, 只能是上面三种情况之一
        NSAssert(NO, @"attempting to add unsupported attribute: %@", secondViewAttribute);
    }
}

#pragma mark - NSLayoutConstraint multiplier proxies

- (MASConstraint * (^)(CGFloat))multipliedBy {
    return ^id(CGFloat multiplier) {
        NSAssert(!self.hasBeenInstalled,
                 @"Cannot modify constraint multiplier after it has been installed");
        
        self.layoutMultiplier = multiplier;
        return self;
    };
}


- (MASConstraint * (^)(CGFloat))dividedBy {
    return ^id(CGFloat divider) {
        NSAssert(!self.hasBeenInstalled,
                 @"Cannot modify constraint multiplier after it has been installed");

        self.layoutMultiplier = 1.0/divider;
        return self;
    };
}

#pragma mark - MASLayoutPriority proxy

- (MASConstraint * (^)(MASLayoutPriority))priority {
    return ^id(MASLayoutPriority priority) {
        // 已安装的约束无法更改
        NSAssert(!self.hasBeenInstalled,
                 @"Cannot modify constraint priority after it has been installed");
        
        self.layoutPriority = priority;
        return self;
    };
}

#pragma mark - NSLayoutRelation proxy

- (MASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation {
    return ^id(id attribute, NSLayoutRelation relation) {
        if ([attribute isKindOfClass:NSArray.class]) {
            // 如果传入的属性是 NSArray 类型的
            // 已设置约束关系的约束无法修改
            NSAssert(!self.hasLayoutRelation, @"Redefinition of constraint relation");
            // 创建属性保存约束视图及其属性类
            NSMutableArray *children = NSMutableArray.new;
            // 遍历传入的参数
            for (id attr in attribute) {
                // 获取当前对象的副本, 设置属性, 并添加到数组
                MASViewConstraint *viewConstraint = [self copy];
                viewConstraint.layoutRelation = relation;
                viewConstraint.secondViewAttribute = attr;
                [children addObject:viewConstraint];
            }
            // 创建多约束封装对象
            MASCompositeConstraint *compositeConstraint = [[MASCompositeConstraint alloc] initWithChildren:children];
            // 设置代理对象为当前对象的代理对象, 也就是 MASConstraintMaker 对象
            compositeConstraint.delegate = self.delegate;
            // 调用代理对象实现的方法进行约束对象替换
            [self.delegate constraint:self shouldBeReplacedWithConstraint:compositeConstraint];
            // 返回多约束封装对象
            return compositeConstraint;
        } else {
            // 要么没有设置过约束关系
            // 要么设置过约束关系, 但是心设置的约束关系和之前设置的是相同的, 并且传入的参数是NSValue类型的
            NSAssert(!self.hasLayoutRelation || self.layoutRelation == relation && [attribute isKindOfClass:NSValue.class], @"Redefinition of constraint relation");
            // 保存参数
            self.layoutRelation = relation;
            self.secondViewAttribute = attribute;
            return self;
        }
    };
}

#pragma mark - Semantic properties

- (MASConstraint *)with {
    // 重写这个方法主要是为了返回当前类的类型, 否则返回的对象还是其父类 MASConstraint 类型的对象
    return self;
}

- (MASConstraint *)and {
    // 重写这个方法主要是为了返回当前类的类型, 否则返回的对象还是其父类 MASConstraint 类型的对象
    return self;
}

#pragma mark - attribute chaining

- (MASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    // 约束属性应该在添加约束关系之前添加
    NSAssert(!self.hasLayoutRelation, @"Attributes should be chained before defining the constraint relation");
    // 调用代理对象实现的方法进行约束对象添加
    return [self.delegate constraint:self addConstraintWithLayoutAttribute:layoutAttribute];
}

#pragma mark - Animator proxy

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)

- (MASConstraint *)animator {
    self.useAnimator = YES;
    return self;
}

#endif

#pragma mark - debug helpers

- (MASConstraint * (^)(id))key {
    return ^id(id key) {
        // 保存传入的参数
        self.mas_key = key;
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant setters

- (void)setInsets:(MASEdgeInsets)insets {
    // 获取已设置的 attr1
    NSLayoutAttribute layoutAttribute = self.firstViewAttribute.layoutAttribute;
    // 根据 attr1 设置不同的常数 c
    switch (layoutAttribute) {
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:
            self.layoutConstant = insets.left;
            break;
        case NSLayoutAttributeTop:
            self.layoutConstant = insets.top;
            break;
        case NSLayoutAttributeBottom:
            self.layoutConstant = -insets.bottom;
            break;
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:
            self.layoutConstant = -insets.right;
            break;
        default:
            break;
    }
}

- (void)setInset:(CGFloat)inset {
    // 调用上面的方法
    [self setInsets:(MASEdgeInsets){.top = inset, .left = inset, .bottom = inset, .right = inset}];
}

- (void)setOffset:(CGFloat)offset {
    // 记录参数
    self.layoutConstant = offset;
}

- (void)setSizeOffset:(CGSize)sizeOffset {
    // 获取已设置的attr1
    NSLayoutAttribute layoutAttribute = self.firstViewAttribute.layoutAttribute;
    // 根据 attr1 设置不同的参数 c
    switch (layoutAttribute) {
        case NSLayoutAttributeWidth:
            self.layoutConstant = sizeOffset.width;
            break;
        case NSLayoutAttributeHeight:
            self.layoutConstant = sizeOffset.height;
            break;
        default:
            break;
    }
}

- (void)setCenterOffset:(CGPoint)centerOffset {
    // 获取已设置的attr1
    NSLayoutAttribute layoutAttribute = self.firstViewAttribute.layoutAttribute;
    // 根据 attr1 设置不同的参数 c
    switch (layoutAttribute) {
        case NSLayoutAttributeCenterX:
            self.layoutConstant = centerOffset.x;
            break;
        case NSLayoutAttributeCenterY:
            self.layoutConstant = centerOffset.y;
            break;
        default:
            break;
    }
}

#pragma mark - MASConstraint

- (void)activate {
    // 直接调用该类的 install 方法
    [self install];
}

- (void)deactivate {
    // 直接调用该类的 uninstall 方法
    [self uninstall];
}

- (void)install {
    // 如果已经安装了就直接返回
    if (self.hasBeenInstalled) {
        return;
    }
    
    // 兼容iOS 8 以后的版本
    if ([self supportsActiveProperty] && self.layoutConstraint) {
        // 将约束对象的活动状态激活
        self.layoutConstraint.active = YES;
        // 保存已安装的视图约束封装对象
        [self.firstViewAttribute.view.mas_installedConstraints addObject:self];
        // 返回
        return;
    }
    
    // 兼容 iOS 8 之前的版本
    // 获取生成约束对象的参数
    MAS_VIEW *firstLayoutItem = self.firstViewAttribute.item;
    NSLayoutAttribute firstLayoutAttribute = self.firstViewAttribute.layoutAttribute;
    MAS_VIEW *secondLayoutItem = self.secondViewAttribute.item;
    NSLayoutAttribute secondLayoutAttribute = self.secondViewAttribute.layoutAttribute;

    // alignment attributes must have a secondViewAttribute
    // therefore we assume that is refering to superview
    // eg make.left.equalTo(@10)
    // 如果设置了像 make.left.equalTo(@10) 这样的约束
    if (!self.firstViewAttribute.isSizeAttribute && !self.secondViewAttribute) {
        secondLayoutItem = self.firstViewAttribute.view.superview;
        secondLayoutAttribute = firstLayoutAttribute;
    }
    
    // 实例化约束对象
    MASLayoutConstraint *layoutConstraint
        = [MASLayoutConstraint constraintWithItem:firstLayoutItem
                                        attribute:firstLayoutAttribute
                                        relatedBy:self.layoutRelation
                                           toItem:secondLayoutItem
                                        attribute:secondLayoutAttribute
                                       multiplier:self.layoutMultiplier
                                         constant:self.layoutConstant];
    
    // 设置约束对象的属性
    layoutConstraint.priority = self.layoutPriority;
    layoutConstraint.mas_key = self.mas_key;
    
    if (self.secondViewAttribute.view) {
        // 如果设置了 view2
        // 获取 view1 和 view2 的公共父视图
        MAS_VIEW *closestCommonSuperview = [self.firstViewAttribute.view mas_closestCommonSuperview:self.secondViewAttribute.view];
        // view1 和 view 必须有公共父视图
        NSAssert(closestCommonSuperview,
                 @"couldn't find a common superview for %@ and %@",
                 self.firstViewAttribute.view, self.secondViewAttribute.view);
        // 要设置约束的视图就是他们的公共父视图
        self.installedView = closestCommonSuperview;
    } else if (self.firstViewAttribute.isSizeAttribute) {
        // 如果设置的属性为size 类型的, 要设置约束的视图就是 view1
        self.installedView = self.firstViewAttribute.view;
    } else {
        // 否则, 要设置约束的视图就是 view1 的父视图
        self.installedView = self.firstViewAttribute.view.superview;
    }

    // 创建变量保存之前添加的约束
    MASLayoutConstraint *existingConstraint = nil;
    if (self.updateExisting) {
        // 如果需要更新约束, 就获取之前的约束对象
        existingConstraint = [self layoutConstraintSimilarTo:layoutConstraint];
    }
    if (existingConstraint) {
        // just update the constant
        // 如果之前安装过约束对象
        // 更新约束对象的常数c
        existingConstraint.constant = layoutConstraint.constant;
        // 保存新的约束对象
        self.layoutConstraint = existingConstraint;
    } else {
        // 如果之前没有安装过约束对象
        // 安装约束对象
        [self.installedView addConstraint:layoutConstraint];
        // 保存安装的约束对象
        self.layoutConstraint = layoutConstraint;
        [firstLayoutItem.mas_installedConstraints addObject:self];
    }
}

// 获取与指定约束对象相似的约束对象
- (MASLayoutConstraint *)layoutConstraintSimilarTo:(MASLayoutConstraint *)layoutConstraint {
    // check if any constraints are the same apart from the only mutable property constant

    // go through constraints in reverse as we do not want to match auto-resizing or interface builder constraints
    // and they are likely to be added first.
    
    // 遍历要设置约束视图的所有已设置的约束
    // 除了约束对象的常数c之外, 其他属性必须都相同, 才是相似的约束对象
    for (NSLayoutConstraint *existingConstraint in self.installedView.constraints.reverseObjectEnumerator) {
        if (![existingConstraint isKindOfClass:MASLayoutConstraint.class]) continue;
        if (existingConstraint.firstItem != layoutConstraint.firstItem) continue;
        if (existingConstraint.secondItem != layoutConstraint.secondItem) continue;
        if (existingConstraint.firstAttribute != layoutConstraint.firstAttribute) continue;
        if (existingConstraint.secondAttribute != layoutConstraint.secondAttribute) continue;
        if (existingConstraint.relation != layoutConstraint.relation) continue;
        if (existingConstraint.multiplier != layoutConstraint.multiplier) continue;
        if (existingConstraint.priority != layoutConstraint.priority) continue;

        return (id)existingConstraint;
    }
    return nil;
}

- (void)uninstall {
    // 兼容iOS8以后的对象
    if ([self supportsActiveProperty]) {
        // 将约束对象的活动状态关闭
        self.layoutConstraint.active = NO;
        // 从集合中移除
        [self.firstViewAttribute.view.mas_installedConstraints removeObject:self];
        return;
    }
    
    // 兼容iOS8 之前的版本
    // 从视图上移除约束
    [self.installedView removeConstraint:self.layoutConstraint];
    // 将属性置空
    self.layoutConstraint = nil;
    self.installedView = nil;
    // 从集合中移除
    [self.firstViewAttribute.view.mas_installedConstraints removeObject:self];
}

@end
