//
//  XLineChartGradientLine.m
//  XJYChart
//
//  Created by 谢俊逸 on 16/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//

#import "XLineChartGradientLine.h"

@implementation XLineChartGradientLine


- (instancetype)init {
  if (self = [super init]) {
    self.isShowGradient = YES;
    self.lineWidth = 3;
    self.lineMode = XCurveLine;
  }
  return self;
}

@end
