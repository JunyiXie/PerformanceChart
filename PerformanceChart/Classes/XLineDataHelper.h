//
//  XLineDataHelper.h
//  XJYChart
//
//  Created by 谢俊逸 on 16/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLineChart.h"

@class XEventAnnotation;


@interface XLineDataHelper : NSObject

@property(nonatomic, weak) id<XLineChartDelegate> delegate;
@property(nonatomic, strong, readonly) NSMutableArray<id<XEventAnnotation>>* annotations;
- (void)addAnnotation:(id<XEventAnnotation>)annotation;
- (void)addAnnotations:(NSMutableArray*)annotions;
- (void)setAnnotations:(NSMutableArray<id<XEventAnnotation>> *)annotations;
@property(nonatomic, weak) XLineChart* chart;
@end
