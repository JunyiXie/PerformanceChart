//
//  XLineChartView.m
//  RecordLife
//
//  Created by 谢俊逸 on 17/03/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "XLineChartView.h"
#import "XAbscissaView.h"
#import "XAreaLineContainerView.h"
#import "XLineChartConfiguration.h"
#import "XLineDataHelper.h"

#define PartWidth 40
#define AbscissaHeight 30

NSString* KVOKeyLineGraphMode = @"lineMode";

@interface XLineChartView ()
@property(nonatomic, strong) XAbscissaView* XAbscissaView;


@property(nonatomic, strong) XAreaLineContainerView* areaLineContainerView;



@end

@implementation XLineChartView

- (instancetype)initWithFrame:(CGRect)frame
                    topNumber:(NSNumber*)topNumbser
                 bottomNumber:(NSNumber*)bottomNumber
                    graphMode:(XLineGraphMode)graphMode
                configuration:(XLineChartConfiguration*)configuration {
  if (self = [super initWithFrame:frame]) {
    self.configuration = configuration;

    self.top = topNumbser;
    self.bottom = bottomNumber;
    self.backgroundColor = [UIColor whiteColor];
    // default line graph mode
    self.lineGraphMode = graphMode;
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  [self clean];
  [self stroke];
}

- (void)clean {
  [_contanierView removeFromSuperview];
  _contanierView = nil;
  _areaLineContainerView = nil;
  
  [_XAbscissaView removeFromSuperview];
  _XAbscissaView = nil;
}

- (void)stroke {

  self.contentSize = [self computeSrollViewCententSizeFromCount:[self.dataHelper.delegate lineChart:self.dataHelper.chart numberOfPointsInLine:0]];
  [self addSubview:self.XAbscissaView];
  self.contanierView =
  [self getLineChartContainerViewWithGraphMode:self.lineGraphMode];
  [self addSubview:self.contanierView];
  
  if ([self.contanierView isKindOfClass:[XAreaLineContainerView class]]) {
    self.bounces = NO;
    self.backgroundColor = [UIColor blueColor];
  }
}



// Acorrding Line Graph Mode Choose Which LineContanier View
- (UIView*)getLineChartContainerViewWithGraphMode:
    (XLineGraphMode)lineGraphMode {
  if (lineGraphMode == AreaLineGraph) {
    return self.areaLineContainerView;
  }
  return self.areaLineContainerView;
}


- (CGSize)computeSrollViewCententSizeFromCount:(NSInteger)count {
  if (count <= 8) {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
  } else {
    CGFloat width = PartWidth * count;
    CGFloat height = self.frame.size.height;
    return CGSizeMake(width, height);
  }
}

#pragma mark Get
- (XAbscissaView*)XAbscissaView {
  
  
  if (!_XAbscissaView) {
    NSMutableArray* titleForAbscissaArray = [NSMutableArray new];
    NSInteger title_count = [self.dataHelper.delegate lineChart:self.dataHelper.chart numberOfPointsInLine:0];
    
    for (int title_idx = 0; title_idx < title_count; title_idx++) {
      NSString* title = [self.dataHelper.delegate lineChart:self.dataHelper.chart titleForAbscissaAtIndex:title_idx];
      [titleForAbscissaArray addObject:title];
    }
    
    _XAbscissaView = [[XAbscissaView alloc]
        initWithFrame:CGRectMake(0, self.contentSize.height - AbscissaHeight,
                                 self.contentSize.width, AbscissaHeight)
                      dataDescribeArray:titleForAbscissaArray];
  }
  return _XAbscissaView;
}

#pragma mark Containers



- (XAreaLineContainerView*)areaLineContainerView {
  if (!_areaLineContainerView) {
    _areaLineContainerView = [[XAreaLineContainerView alloc]
        initWithFrame:CGRectMake(0, 0, self.contentSize.width,
                                 self.contentSize.height - AbscissaHeight)
            topNumber:self.top
         bottomNumber:self.bottom
        configuration:(XAreaLineChartConfiguration*)self.configuration];
  }
  _areaLineContainerView.dataHelper = self.dataHelper;
  return _areaLineContainerView;
}


#pragma mark - Set


- (void)refreshContent {
  [self clean];
  [self stroke];
  self.contentOffset = CGPointMake(self.contentSize.width - self.frame.size.width, 0);
}

@end

