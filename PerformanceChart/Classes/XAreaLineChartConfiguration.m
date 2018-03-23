//
//  XAreaLineChartConfiguration.m
//  XJYChart
//
//  Created by JunyiXie on 2017/12/3.
//  Copyright © 2017年 JunyiXie. All rights reserved.
//

#import "XAreaLineChartConfiguration.h"

@implementation XAreaLineChartConfiguration

- (instancetype)init {
  if (self = [super init]) {
    self.isShowPoint = YES;

    self.auxiliaryDashLineColor = [UIColor colorWithWhite:0.5 alpha:1];
  }
  return self;
}

@end
