//
//  XEventAnnotationView.h
//  XJYChart
//
//  Created by 谢俊逸 on 16/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XEventAnnotation.h"

@interface XEventAnnotationView : UIView

@property(nonatomic, strong, readonly) id<XEventAnnotation> annotation;

- (instancetype)initWithAnnotation:(id<XEventAnnotation>)annotation;

/// optimize interface
- (instancetype)initWithAnnotation:(id<XEventAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
