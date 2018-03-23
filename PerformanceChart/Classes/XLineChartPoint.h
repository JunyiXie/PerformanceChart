//
//  XLineChartPoint.h
//  XJYChart
//
//  Created by 谢俊逸 on 15/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSUInteger, XPointType) {
  XPointSolid,
  XPointAnnular,
};
@interface XLineChartPoint : CAShapeLayer

@property(nonatomic, assign) XPointType pointType;
@property(nonatomic, assign, readonly) CGPoint center;
@property(nonatomic, assign) CGFloat diameter;

- (void)pointLayerSetCenter:(CGPoint)center;
- (void)annularPointLayerSetCenter:(CGPoint)center;
- (void)solidPointLayerSetCenter:(CGPoint)center;
@end
