//
//  XXLineChart.h
//  RecordLife
//
//  Created by 谢俊逸 on 17/03/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XEnumHeader.h"
#import "XEventAnnotation.h"


@class XLineChartView;
@class XLineChartConfiguration;
@class XLineDataHelper;
@class XLineChartPoint;
@class XLineChartGradientLine;
@class XEventAnnotationView;
@class XLineChart;

@interface XLineMarkView: UIView
@property (nonatomic, strong, readonly) NSDictionary *ColorLineIndexMap;
- (instancetype)initWithFrame:(CGRect)frame colorLineNameMap:(NSDictionary *)map;
@end

@protocol XLineChartDelegate <NSObject>


@required
/**
 Configuration:
 * point
 * line
 * chart
 */

/// Point
/// Create Point
- (XLineChartPoint*)lineChart:(XLineChart*)lineChart pointForLineAtIndexPath:(NSIndexPath*)indexPath;

/// Point value(number)
/// according to value to calculate point position in ios coordinate system
- (CGFloat)lineChart:(XLineChart*)lineChart valueOfPointAtIndexPath:(NSIndexPath*)indexPath;

/// Line
/// point number
- (NSInteger)lineChart:(XLineChart*)lineChart numberOfPointsInLine:(NSInteger)section;
- (XLineChartGradientLine*)lineChart:(XLineChart*)lineChart lineForLineChartAtIndex:(NSInteger)index;

/// Chart
/// line number
- (NSInteger)numberOfLinesInLineChart:(XLineChart*)lineChart;

- (NSString*)lineChart:(XLineChart*)lineChart titleForAbscissaAtIndex:(NSInteger)index;

@optional
- (XEventAnnotationView*)lineChart:(XLineChart*)lineChart viewForEventAnnotation:(id<XEventAnnotation>)annotation;
- (NSTimeInterval)renderedStartTimeInLineChart:(XLineChart*)lineChart;
- (NSTimeInterval)renderedEndTimeInLineChart:(XLineChart*)lineChart;
@end

@protocol XChartDrawProtocol
@required
/// 1. clean view in screen [layer/view removeFromSuperView/Layer]
/// 2. clean view/data container [data/view array removeAllObjects]
- (void)cleanPreDrawAndDataCache;

/// call cleanPreDrawAndDataCache
/// call stroke
- (void)refreshView;

/// add view/layer in superview
/// add vire/object in array
- (void)stroke;

@end

@interface XLineChart : UIView

@property(nonatomic, strong) XLineChartView* lineChartView;

@property(nonatomic, strong) XLineDataHelper* dataHelper;

@property(nonatomic, weak) id<XLineChartDelegate> delegate;


@property(nonatomic, strong) UIColor* chartBackgroundColor;

/// tap and pin gesture
@property(nonatomic, assign) BOOL isAllowGesture;

@property(nonatomic, strong) XLineChartConfiguration* configuration;


/**
 Line Graph Mode
 - MutiLine
 - GraphLine

 Default is MutiLine
 */
@property(nonatomic, assign) XLineGraphMode lineGraphMode;

/**
 XXLineChart初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame
                    topNumber:(NSNumber*)topNumbser
                 bottomNumber:(NSNumber*)bottomNumber
                    graphMode:(XLineGraphMode)graphMode
           chartConfiguration:(XLineChartConfiguration*)configuration;


/// 重用机制
//- (void)registerClass:(Class)pointClass forPointReuseIdentifier:(NSString *)identifier;
//- (__kindof XLineChartPoint*)dequeueReusablePointWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

@end


