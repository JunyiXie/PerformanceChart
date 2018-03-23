//
//  XXLineChart.m
//  RecordLife
//
//  Created by 谢俊逸 on 17/03/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "XLineChart.h"
#import "XOrdinateView.h"
#import "XLineChartView.h"
#import "XLineChartConfiguration.h"
#import "XLineDataHelper.h"
#import "XLineChartPoint.h"

#define OrdinateWidth 30
#define LineChartViewTopInterval 10

@interface XLineMarkView()


@end

@implementation XLineMarkView


- (instancetype)initWithFrame:(CGRect)frame colorLineNameMap:(NSDictionary *)map  {
  if (self = [super initWithFrame:frame]) {
    _ColorLineIndexMap = map;
  
    __block int idx = 0;
    CGFloat perH = frame.size.height/([map count]);
    [_ColorLineIndexMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
      CGFloat H = frame.size.height/[map count] * idx;
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, H, frame.size.width, perH)];

      label.textColor = [UIColor blackColor];
      if (obj == [UIColor blackColor]) {
        label.textColor = [UIColor whiteColor];
      }
      label.text = key;
      label.font = [UIFont systemFontOfSize:10];
      label.backgroundColor = obj;
      [self addSubview:label];
      idx++;
    }];
    self.alpha = 0.8;
  
  }
  return self;
}


@end

@interface XLineChart ()


/// Reuse
{
  /// Key Identifier
  /// Value ClassIvar
  NSMutableDictionary* reuseIdentifierDic;
  
  /// Key Identifier
  /// Value IvarSet
  NSMutableDictionary* reuseDic;
  
  /// Key Identifier
  /// Value IvarSet
  NSMutableDictionary* renderedDic;
  
}

@property(nonatomic, strong) NSNumber* top;
@property(nonatomic, strong) NSNumber* bottom;

@property(nonatomic, strong) XOrdinateView* ordinateView;
@property(nonatomic, strong) UIView* contanierView;




@end

@implementation XLineChart



- (instancetype)initWithFrame:(CGRect)frame
                    topNumber:(NSNumber*)topNumbser
                 bottomNumber:(NSNumber*)bottomNumber
                    graphMode:(XLineGraphMode)graphMode
           chartConfiguration:(XLineChartConfiguration*)configuration {
  
  if (self = [super initWithFrame:frame]) {
    self.dataHelper = [[XLineDataHelper alloc] init];
    self.dataHelper.chart = self;
    [self initReuseMechanism];
    
    self.configuration = configuration;
    self.isAllowGesture = NO;
    self.top = topNumbser;
    self.bottom = bottomNumber;
    self.lineGraphMode = graphMode;
    self.layer.masksToBounds = YES;
    self.lineChartView.layer.masksToBounds = YES;
    [self addSubview:self.ordinateView];
    [self addSubview:self.lineChartView];
  }
  return self;
}
#pragma mark Get

- (XOrdinateView*)ordinateView {
  if (!_ordinateView) {
    _ordinateView = [[XOrdinateView alloc]
        initWithFrame:CGRectMake(0, 0, OrdinateWidth, self.frame.size.height)
            topNumber:self.top
         bottomNumber:self.bottom];
  }
  return _ordinateView;
}

- (XLineChartView*)lineChartView {
  if (!_lineChartView) {
    _lineChartView = [[XLineChartView alloc]
            initWithFrame:CGRectMake(
                              OrdinateWidth, LineChartViewTopInterval,
                              self.frame.size.width - OrdinateWidth,
                              self.frame.size.height - LineChartViewTopInterval)
                topNumber:self.top
             bottomNumber:self.bottom
                graphMode:self.lineGraphMode
            configuration:self.configuration];

    _lineChartView.chartBackgroundColor = self.chartBackgroundColor;
    _lineChartView.dataHelper = self.dataHelper;
  }
  return _lineChartView;
}

#pragma mark Set
- (void)setDelegate:(id<XLineChartDelegate>)delegate {
    _dataHelper.delegate = delegate;
}


#pragma mark Reuse Mechanism

- (void)initReuseMechanism {
  reuseDic = [NSMutableDictionary new];
  reuseIdentifierDic = [NSMutableDictionary new];
  renderedDic = [NSMutableDictionary new];
}

- (__kindof XLineChartPoint*)dequeueReusablePointWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
  //1. 取全部reuseitem
  //2. 找出不显示的item
  //3. 取出一个
  
  
  NSMutableSet* reuseSet = reuseDic[identifier];
  NSLog(@"重用池数量%lu", reuseSet.count);

  
  for (XLineChartPoint* point in reuseSet) {
    /// 找出未显示的point
    CGPoint contentOffset = self.lineChartView.contentOffset;
    CGRect renderRect = CGRectMake(contentOffset.x, contentOffset.y, self.lineChartView.frame.size.width, self.lineChartView.frame.size.height);
    BOOL isRender = CGRectContainsPoint(renderRect, point.center);
    if (isRender == NO) {
      return point;
    }
  }
  /// 如果找不到 就新建一个
  XLineChartPoint* point = [XLineChartPoint new];
  [reuseSet addObject:point];
  
  
  return point;
  
}
- (void)registerClass:(Class)pointClass forPointReuseIdentifier:(NSString *)identifier {
  
  reuseIdentifierDic[identifier] = pointClass;
  
  /// Add new container for identifier
  if (reuseDic[identifier] == nil) {
    NSMutableSet* identifierObjects = [[NSMutableSet alloc] init];
    // 先默认10个吧 待优化
    for (int i = 0; i < 10; i++) {
      [identifierObjects addObject:[pointClass new]];
    }
    reuseDic[identifier] = identifierObjects;
  }
  
}


@end







