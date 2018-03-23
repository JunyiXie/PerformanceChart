//
//  XLineChartView.h
//  RecordLife
//
//  Created by 谢俊逸 on 17/03/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XEnumHeader.h"


@class XLineChartConfiguration;
@class XLineDataHelper;
@class XAreaLineContainerView;
@interface XLineChartView : UIScrollView



@property(nonatomic, strong) XLineDataHelper *dataHelper;


/**
 初始化方法

 @param frame frame
 @param topNumbser top
 @param bottomNumber buttom
 @param configuration LineChartConfiguration
 @return instancetype
 */
- (instancetype)initWithFrame:(CGRect)frame
                    topNumber:(NSNumber*)topNumbser
                 bottomNumber:(NSNumber*)bottomNumber
                    graphMode:(XLineGraphMode)graphMode
                configuration:(XLineChartConfiguration*)configuration;


@property(nonatomic, strong) UIView* contanierView;


@property(nonatomic, strong) NSMutableArray<NSString*>* dataDescribeArray;
/**
 The vertical high
 */
@property(nonatomic, strong) NSNumber* top;

/**
 The vertical low
 */
@property(nonatomic, strong) NSNumber* bottom;


@property(nonatomic, strong) XLineChartConfiguration* configuration;

/**
 Line Graph Mode
 - MutiLine
 - GraphLine

 Default is MutiLine
 */
@property(nonatomic, assign) XLineGraphMode lineGraphMode;
@property(nonatomic, strong) UIColor* chartBackgroundColor;
- (void)refreshContent;
@end
