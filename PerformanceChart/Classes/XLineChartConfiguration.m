//
//  XLineChartConfiguration.m
//  XJYChart
//
//  Created by JunyiXie on 2017/12/3.
//  Copyright © 2017年 JunyiXie. All rights reserved.
//

#import "XLineChartConfiguration.h"
  
@implementation XLineChartConfiguration

- (instancetype)init {
  if (self = [super init]) {
    self.lineMode = XStraightLine;
    self.isShowAuxiliaryDashLine = YES;
    self.auxiliaryDashLineColor = [UIColor colorWithWhite:0.75 alpha:1];
  }
  return self;
}

@end
