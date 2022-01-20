//
//  MASViewAttribute.m
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASViewAttribute.h"

@implementation MASViewAttribute

- (id)initWithView:(MAS_VIEW *)view layoutAttribute:(NSLayoutAttribute)layoutAttribute {
    // 从这个方法的实现中, 我们可以看到, view 和 item 在大多数情况下是同一个对象
    self = [self initWithView:view item:view layoutAttribute:layoutAttribute];
    return self;
}

- (id)initWithView:(MAS_VIEW *)view item:(id)item layoutAttribute:(NSLayoutAttribute)layoutAttribute {
    // 在这个方法中只是保存了一下传递的参数
    self = [super init];
    if (!self) return nil;
    
    _view = view;
    _item = item;
    _layoutAttribute = layoutAttribute;
    
    return self;
}

- (BOOL)isSizeAttribute {
    // 只要是直接设置了约束的宽和高就返回YES, 否则就是 NO
    return self.layoutAttribute == NSLayoutAttributeWidth
        || self.layoutAttribute == NSLayoutAttributeHeight;
}

- (BOOL)isEqual:(MASViewAttribute *)viewAttribute {
    // 先判断是否是当前类或其子类
    if ([viewAttribute isKindOfClass:self.class]) {
        // 必须满足设置约束的视图和设置约束的属性都相等, 才算两个对象相等
        return self.view == viewAttribute.view
            && self.layoutAttribute == viewAttribute.layoutAttribute;
    }
    // 如果不是当前类或其子类, 就直接调用父类方法判断
    return [super isEqual:viewAttribute];
}

- (NSUInteger)hash {
    // 首先将设置约束的视图的hash从中间反转, 然后再异或上设置约束的属性
    return MAS_NSUINTROTATE([self.view hash], MAS_NSUINT_BIT / 2) ^ self.layoutAttribute;
}

@end
