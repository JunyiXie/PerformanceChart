//
//  XLineChartPoint.m
//  XJYChart
//
//  Created by 谢俊逸 on 15/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//

#import "XLineChartPoint.h"


@implementation XLineChartPoint

- (instancetype)init {
  if (self = [super init]) {
    _pointType = XPointSolid;
  }
  return self;
}

- (void)pointLayerSetCenter:(CGPoint)center {
  switch (_pointType) {
    case XPointSolid:
      return [self solidPointLayerSetCenter:center];
      break;
    case XPointAnnular:
      return [self annularPointLayerSetCenter:center];
      break;
    default:
      return [self solidPointLayerSetCenter:center];
      break;
  }
}
- (void)annularPointLayerSetCenter:(CGPoint)center {
  
  UIBezierPath* path = [UIBezierPath
                        bezierPathWithRoundedRect:CGRectMake(center.x - _diameter / 2,
                                                             center.y - _diameter / 2, _diameter,
                                                             _diameter)
                        cornerRadius:_diameter / 2];
  
  self.path = path.CGPath;
  self.strokeColor = [UIColor whiteColor].CGColor;
  self.lineWidth = 1.5;
  _center = center;
}

- (void)solidPointLayerSetCenter:(CGPoint)center {
  
  UIBezierPath* path = [UIBezierPath
                        bezierPathWithRoundedRect:CGRectMake(center.x - _diameter / 2,
                                                             center.y - _diameter / 2, _diameter,
                                                             _diameter)
                        cornerRadius:_diameter / 2];
  
  self.path = path.CGPath;
  _center = center;
}

@end
