//
//  XLineChartGradientLine.h
//  XJYChart
//
//  Created by 谢俊逸 on 16/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "XEnumHeader.h"
@interface XLineChartGradientLine : CAGradientLayer

@property(nonatomic, assign) CGFloat lineWidth;
@property(nonatomic, assign) BOOL isShowGradient;
@property(nonatomic, assign) XLineMode lineMode;
@end
