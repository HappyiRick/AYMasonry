//
//  NSArray+MASAdditions.m
//  
//
//  Created by Daniel Hammond on 11/26/13.
//
//

#import "NSArray+MASAdditions.h"
#import "View+MASAdditions.h"

@implementation NSArray (MASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(MASConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (MAS_VIEW *view in self) {
        NSAssert([view isKindOfClass:[MAS_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view mas_makeConstraints:block]];
    }
    return constraints;
}

- (NSArray *)mas_updateConstraints:(void(^)(MASConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (MAS_VIEW *view in self) {
        NSAssert([view isKindOfClass:[MAS_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view mas_updateConstraints:block]];
    }
    return constraints;
}

- (NSArray *)mas_remakeConstraints:(void(^)(MASConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (MAS_VIEW *view in self) {
        NSAssert([view isKindOfClass:[MAS_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view mas_remakeConstraints:block]];
    }
    return constraints;
}

- (void)mas_distributeViewsAlongAxis:(MASAxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    // 必须有一个以上的视图元素
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    // 获取这些视图的公共父视图
    MAS_VIEW *tempSuperView = [self mas_commonSuperviewOfViews];
    if (axisType == MASAxisTypeHorizontal) {
        // 如果设置的是水平方向布局
        // 创建变量保存前一个视图
        MAS_VIEW *prev;
        // 遍历视图数组
        for (int i = 0; i < self.count; i++) {
            // 获取视图元素
            MAS_VIEW *v = self[i];
            // 添加并安装约束的方法
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                if (prev) {
                    // 如果当前视图不是第一个视图
                    // 当前视图宽度等于第一个视图宽度
                    make.width.equalTo(prev);
                    // 当前视图左边距离前一个视图右边指定的间距
                    make.left.equalTo(prev.mas_right).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        // 如果是最后一个视图
                        // 当前视图的右边距离公共父视图右边指定的尾距
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                }
                else {//first one
                    // 如果当前视图是第一个视图
                    // 当前视图的左边距离公共父视图左边指定的首距
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            // 保存当前视图, 用于下次循环
            prev = v;
        }
    }
    else {
        // 如果是垂直方向布局
        // 创建变量保存前一个视图
        MAS_VIEW *prev;
        // 遍历视图数组
        for (int i = 0; i < self.count; i++) {
            // 获取视图元素
            MAS_VIEW *v = self[i];
            // 添加并安装约束的方法
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                if (prev) {
                    // 如果当前视图不是第一个视图
                    // 当前视图高度等于前一个视图高度
                    make.height.equalTo(prev);
                    // 当前视图顶部距离前一个视图底部指定的间距
                    make.top.equalTo(prev.mas_bottom).offset(fixedSpacing);
                    // 如果是最后一个视图元素
                    if (i == self.count - 1) {//last one
                        // 当前的视图的底部距离公共父视图底部指定的间距
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }                    
                }
                else {//first one
                    // 如果当前视图是第一个视图
                    // 当前视图的顶部艰巨距离公共父视图顶部指定的首距
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            // 保存当前视图, 用于下次循环
            prev = v;
        }
    }
}

- (void)mas_distributeViewsAlongAxis:(MASAxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    // 必须有一个以上的视图元素
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    // 获取这些视图的公共父视图
    MAS_VIEW *tempSuperView = [self mas_commonSuperviewOfViews];
    if (axisType == MASAxisTypeHorizontal) {
        // 如果设置的是水平方向布局
        // 创建变量保存前一个视图
        MAS_VIEW *prev;
        // 遍历视图数组
        for (int i = 0; i < self.count; i++) {
            // 获取当前视图元素
            MAS_VIEW *v = self[i];
            // 添加并安装约束的方法
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                // 当前视图的宽度等于指定的宽度
                make.width.equalTo(@(fixedItemLength));
                if (prev) {
                    // 如果当前视图不是第一个视图
                    if (i == self.count - 1) {//last one
                        // 如果是最后一个视图
                        // 当前视图的右边距离公共父视图右边指定的尾距
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        // 如果不是最后一个视图
                        // 计算偏移量
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        // 当前视图的右边距离公共父视图的右边计算出的大小
                        make.right.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    // 如果当前视图是第一个视图
                    // 当前视图的左边距离公共父视图左边指定的首距
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            // 保存当前视图, 用于下次循环
            prev = v;
        }
    }
    else {
        // 如果设置的是垂直方向布局
        // 创建变量保存前一个视图
        MAS_VIEW *prev;
        // 遍历视图数组
        for (int i = 0; i < self.count; i++) {
            // 获取当前视图元素
            MAS_VIEW *v = self[i];
            // 添加并安装约束的方法
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                // 当前视图的高度等于指定的高度
                make.height.equalTo(@(fixedItemLength));
                if (prev) {
                    // 如果当前视图不是第一个视图
                    if (i == self.count - 1) {//last one
                        // 如果是最后一个视图
                        // 当前视图的底部距离公共父视图底边指定的尾距
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        // 如果不是最后一个视图
                        // 计算偏移量
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        // 当前视图的底部距离公共父视图的底部计算出的距离
                        make.bottom.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    // 如果当前视图是第一个视图
                    // 当前视图的顶边距离公共父视图顶部指定的首距
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            // 保存当前视图, 用于下次循环
            prev = v;
        }
    }
}

// 该方法用于获取视图数组中所有视图元素的公共父视图
- (MAS_VIEW *)mas_commonSuperviewOfViews
{
    // 创建变量保存公共父视图
    MAS_VIEW *commonSuperview = nil;
    // 创建变量保存前一个视图
    MAS_VIEW *previousView = nil;
    // 遍历当前数组中的每一个视图元素
    for (id object in self) {
        // 数组中的元素必须是 UIView 及其子类
        if ([object isKindOfClass:[MAS_VIEW class]]) {
            // 创建变量保存当前视图
            MAS_VIEW *view = (MAS_VIEW *)object;
            if (previousView) {
                // 如果这不是第一个元素, 那就获取当前视图和前一个视图的公共父视图
                commonSuperview = [view mas_closestCommonSuperview:commonSuperview];
            } else {
                // 如果这是第一个元素, 那公共父视图就是当前视图
                commonSuperview = view;
            }
            // 保存当前视图, 用于下次循环
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    // 返回公共父视图
    return commonSuperview;
}

@end
