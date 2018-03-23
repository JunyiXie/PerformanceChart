//
//  XAreaLineContainerView.m
//  RecordLife
//
//  Created by 谢俊逸 on 09/05/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "XAreaLineContainerView.h"
#import "XAuxiliaryCalculationHelper.h"
#import "XAnimationLabel.h"
#import "XAnimator.h"
#import "CAShapeLayer+XLayerHelper.h"
#import "XNotificationBridge.h"
#import "XEventAnnotationView.h"
#import "XAreaLineChartConfiguration.h"
#import "XLineDataHelper.h"
#import "XLineChartPoint.h"
#import "XLineChartGradientLine.h"
#import "JYPopTipView.h"

#pragma mark - Macro

#define LineWidth 6.0
#define PointDiameter 11.0

// Animation start ratio
#define StartRatio 0.3

#define mark -XGraphAnimationNode

/**
 Contain Point in CADisplayLink Animation Information.

 CurrentPoint: Use it to draw.
 EndPoint: Save final view point.
 */
@interface XGraphAnimationNode : NSObject

@property(nonatomic, assign) CGPoint graphAnimationEndPoint;
@property(nonatomic, assign) CGPoint graphAnimationCurrentPoint;

- (instancetype)initWithAnimationEndPoint:(CGPoint)endPoint;
- (CGFloat)getAnimationNodeX;
- (CGFloat)getAnimationNodeEndY;
- (CGFloat)getAnimationNodeCurrentY;
- (CGPoint)getNodeCGPoint;
@end

@implementation XGraphAnimationNode

- (instancetype)initWithAnimationEndPoint:(CGPoint)endPoint {
  if (self = [super init]) {
    self.graphAnimationEndPoint = endPoint;
    self.graphAnimationCurrentPoint = endPoint;
  }
  return self;
}

- (CGFloat)getAnimationNodeX {
  return self.graphAnimationEndPoint.x;
}

- (CGFloat)getAnimationNodeEndY {
  return self.graphAnimationEndPoint.y;
}

- (CGFloat)getAnimationNodeCurrentY {
  return self.graphAnimationCurrentPoint.y;
}

- (CGPoint)getNodeCGPoint {
  return self.graphAnimationEndPoint;
}

@end

/**
 Manager points.
 Draw layer use.
 */

@interface XAreaAnimationManager : NSObject

/// area nodes. Used to draw up the closed graph
@property(nonatomic, strong) NSMutableArray<XGraphAnimationNode*>* areaNodes;
/// animation needs nodes
/// The point that can be seen in Chart
@property(nonatomic, strong)
    NSMutableArray<XGraphAnimationNode*>* animationNodes;

@property(nonatomic, assign) CGFloat pointMinY;

@end

@implementation XAreaAnimationManager
- (instancetype)init {
  if (self = [super init]) {
  }
  return self;
}

- (instancetype)initWithAreaNodes:(NSMutableArray<XGraphAnimationNode*>*)nodes {
  if (self = [super init]) {
    self.areaNodes = nodes;
  }
  return self;
}

- (NSMutableArray<XGraphAnimationNode*>*)animationNodes {
  NSMutableArray* nodes = [self.areaNodes mutableCopy];
  // gurad
  if (nodes.count == 0) {
    return nodes;
  }
  [nodes removeObjectAtIndex:0];
  [nodes removeLastObject];
  return nodes;
}

- (CGFloat)pointMinY {
  CGFloat min = 0;
  for (XGraphAnimationNode *node in self.animationNodes) {
    if (node.getAnimationNodeEndY < min) {
      min = node.getAnimationNodeEndY;
    }
  }
  return min;
}


@end

/**
 Animation :
 Using CADisplayLink animation.
 By Adding the CALayer In The View.
 Change Shape And Readding.

 EnterAnimaton:
 when UIApplicationDidBecomeActiveNotification add Animation.
 When UIApplicationDidEnterBackgroundNotification. Reset View Will Make
 Animation More coordination.
 */
@interface XAreaLineContainerView ()<XChartDrawProtocol>

@property(nonatomic, strong) UIColor* areaColor;

@property(nonatomic, strong) NSMutableArray<CAGradientLayer*> *gradientLayers;

@property(nonatomic, strong) NSMutableArray<CAShapeLayer*>* edgeShapeLayers;

@property(nonatomic, strong) NSMutableArray<XAnimationLabel*>* labelArray;

@property(nonatomic, strong) NSMutableArray<CAShapeLayer*>* pointLayerArray;

@property(nonatomic, strong) NSMutableArray<XAreaAnimationManager*> *managers;

@property(nonatomic, strong) NSMutableArray<XEventAnnotationView*>* annotationViews;

@end

@implementation XAreaLineContainerView

- (instancetype)initWithFrame:(CGRect)frame
                    topNumber:(NSNumber*)topNumber
                 bottomNumber:(NSNumber*)bottomNumber
                configuration:(__kindof XAreaLineChartConfiguration*)configuration {
  if (self = [super initWithFrame:frame]) {
    self.configuration = configuration;
    self.backgroundColor = self.configuration.chartBackgroundColor;

    self.pointLayerArray = [NSMutableArray new];
    self.labelArray = [NSMutableArray new];
    self.gradientLayers = [NSMutableArray new];
    self.annotationViews = [NSMutableArray new];
    self.edgeShapeLayers = [NSMutableArray new];

    self.top = topNumber;
    self.bottom = bottomNumber;


#pragma mark Register Notifications

    // App Alive Animation Notification
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(becomeAlive)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];

    // App Resign Set Animation Start State
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(enterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    
    // Add Annotation Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAnnotationAction) name:[XNotificationBridge shareXNotificationBridge].AddAnnotationNotification object:nil];
  }
  return self;
}

- (NSMutableArray<XAreaAnimationManager*> *)makeManagers {
  NSMutableArray *managers = [NSMutableArray new];
  NSInteger lineCount = [self.dataHelper.delegate numberOfLinesInLineChart:self.dataHelper.chart];
  for (int line_idx = 0; line_idx < lineCount; line_idx++) {
    NSMutableArray<XGraphAnimationNode*>* areaNodes =
    [self getAreaDrawableAnimationNodesAtLineIdx:line_idx];
    XAreaAnimationManager* manager =
    [[XAreaAnimationManager alloc] initWithAreaNodes:[areaNodes mutableCopy]];
    [managers addObject:manager];
  }
  return managers;
}


- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();
  // 数据处理，集中管理
  self.managers = [self makeManagers];

  [self strokeAuxiliaryLineInContext:context];
//  [self startAnimation];
  [self refreshView];
}

// Start Animation
- (void)startAnimation {
  
  [self.managers enumerateObjectsUsingBlock:^(XAreaAnimationManager * _Nonnull manager, NSUInteger manager_idx, BOOL * _Nonnull stop) {
    XAnimator* animator = [[XAnimator alloc] init];
    [animator
     AnimatorDuration:2
     timingFuncType:XQuarticEaseInOut
     animationBlock:^(CGFloat percentage) {
       [manager
        .areaNodes enumerateObjectsUsingBlock:^(
                                                XGraphAnimationNode* _Nonnull node,
                                                NSUInteger idx, BOOL* _Nonnull stop) {
          node.graphAnimationCurrentPoint = CGPointMake(
                                                        node.getAnimationNodeX,
                                                        [[XAuxiliaryCalculationHelper shareCalculationHelper]
                                                         getOriginYIncreaseInFilpCoordinateSystemWithBoundsH:
                                                         self.bounds.size.height
                                                         targetY:
                                                         node.getAnimationNodeEndY
                                                         percentage:
                                                         percentage
                                                         startRatio:
                                                         StartRatio]);
        }];
       [self refreshView];
     }];
  }];
  

}

- (void)refreshView {
  // remove pre data and layer
  [self cleanPreDrawAndDataCache];
  [self stroke];
}

- (void)stroke {
  // Add SubLayers
  [self strokeLine];
  [self strokePoint];
  // Add AnnotationViews
  [self strokeAllAnnotationView];
}
- (void)strokeAllAnnotationView {
  NSMutableArray* annotations = [self.dataHelper valueForKey:@"annotations"];
  if ([self.dataHelper.delegate respondsToSelector:@selector(lineChart:viewForEventAnnotation:)]) {
    for (id<XEventAnnotation> annotation in annotations) {
      XEventAnnotationView* annotationView = [self.dataHelper.delegate lineChart:self.dataHelper.chart viewForEventAnnotation:annotation];
      NSTimeInterval startTime = [self.dataHelper.delegate renderedStartTimeInLineChart:self.dataHelper.chart];
      NSTimeInterval endTime = [self.dataHelper.delegate renderedEndTimeInLineChart:self.dataHelper.chart];
      NSTimeInterval time = annotation.time;
    
      /// filiter
      if (time < startTime || time > endTime) {
        continue;
      }
      
      /// 计算坐标
      XAreaAnimationManager* manager = self.managers[0];
      CGFloat startX = manager.animationNodes.firstObject.getAnimationNodeX;
      CGFloat endX = manager.animationNodes.lastObject.getAnimationNodeX;
      CGFloat x = ((time - startTime)/(endTime - startTime))*(endX - startX) + startX;
      /// 计算坐标，计算大小，添加到试图上
      /// 根据x_idx 查找 point
      annotationView.center = CGPointMake(x-annotationView.bounds.size.width/2, annotationView.bounds.size.height/2);
      // 点击手势
      UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(annotationViewTap:)];
      tapGes.numberOfTapsRequired = 1;
      [annotationView addGestureRecognizer:tapGes];
      
      
      [self addSubview:annotationView];
      [self.annotationViews addObject:annotationView];
    }
  }
}

/// Stroke Auxiliary
- (void)strokeAuxiliaryLineInContext:(CGContextRef)context {
  if (self.configuration.isShowAuxiliaryDashLine) {
    CGContextSetStrokeColorWithColor(context, self.configuration.auxiliaryDashLineColor.CGColor);
    CGContextSaveGState(context);
    CGFloat lengths[2] = {5.0, 5.0};
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextSetLineWidth(context, 0.2);
    for (int i = 0; i < 11; i++) {
      CGContextMoveToPoint(
                           context, 5, self.frame.size.height - (self.frame.size.height) / 11 * i);
      CGContextAddLineToPoint(
                              context, self.frame.size.width,
                              self.frame.size.height - ((self.frame.size.height) / 11) * i);
      CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.configuration.auxiliaryDashLineColor.CGColor);
  }
}

- (void)strokePoint {
  // Just one data item in dataItemArray

  // reuse 
//  CGPoint offset = self.dataHelper.chart.lineChartView.contentOffset;
//  CGFloat x = offset.x-150 > 0? offset.x-150: 0;
//  CGFloat width = offset.x + self.dataHelper.chart.lineChartView.frame.size.width > self.frame.size.width ? offset.x + self.dataHelper.chart.lineChartView.frame.size.width : self.frame.size.width;
//  CGRect drawRect = CGRectMake(x, 0, width, self.frame.size.height);
//
//
  
  if (self.configuration.isShowPoint) {
    
    [self.managers enumerateObjectsUsingBlock:^(XAreaAnimationManager * _Nonnull manager, NSUInteger manager_idx, BOOL * _Nonnull stop) {
      [manager.animationNodes
       enumerateObjectsUsingBlock:^(XGraphAnimationNode* _Nonnull node,
                                    NSUInteger node_idx, BOOL* _Nonnull stop) {
         CGPoint center = node.graphAnimationCurrentPoint;
         
//         if (CGRectContainsPoint(drawRect, center)) {
           XLineChartPoint *pointLayer = [self.dataHelper.delegate lineChart:self.dataHelper.chart pointForLineAtIndexPath:[NSIndexPath indexPathForRow:node_idx inSection:manager_idx]];
           [pointLayer pointLayerSetCenter:center];
           [self.pointLayerArray addObject:pointLayer];
           [self.layer addSublayer:pointLayer];
           
//         }
         
 
       }];
    }];
    
  }
}

- (void)cleanPreDrawAndDataCache {
  [self.annotationViews enumerateObjectsUsingBlock:^(XEventAnnotationView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [obj removeFromSuperview];
    });
  }];
  [self.annotationViews removeAllObjects];
  
  [self.gradientLayers enumerateObjectsUsingBlock:^(CAGradientLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [obj removeFromSuperlayer];
  }];
  [self.gradientLayers removeAllObjects];
  
  [self.edgeShapeLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [obj removeFromSuperlayer];
  }];
  [self.edgeShapeLayers removeAllObjects];
  
  [self.pointLayerArray
      enumerateObjectsUsingBlock:^(CAShapeLayer* _Nonnull obj, NSUInteger idx,
                                   BOOL* _Nonnull stop) {
        [obj removeFromSuperlayer];
      }];
  [self.pointLayerArray removeAllObjects];

  [self.labelArray
      enumerateObjectsUsingBlock:^(XAnimationLabel* _Nonnull obj,
                                   NSUInteger idx, BOOL* _Nonnull stop) {
        [obj removeFromSuperview];
      }];

  [self.labelArray removeAllObjects];
}

/// line mask cashape layer
- (void)strokeLine {
  [self.managers enumerateObjectsUsingBlock:^(XAreaAnimationManager * _Nonnull manager, NSUInteger manager_idx, BOOL * _Nonnull stop) {
    // animation end layer
    NSMutableArray* currentPointArray = [NSMutableArray new];
    [manager.areaNodes
     enumerateObjectsUsingBlock:^(XGraphAnimationNode* _Nonnull obj,
                                  NSUInteger idx, BOOL* _Nonnull stop) {
       [currentPointArray
        addObject:[NSValue
                   valueWithCGPoint:obj.graphAnimationCurrentPoint]];
     }];
    
    
    CGPoint leftConerPoint = CGPointMake(
                                         self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
    CGPoint rightConerPoint =
    CGPointMake(self.frame.origin.x + self.frame.size.width,
                self.frame.origin.y + self.frame.size.height);
    
    CAShapeLayer* shapeLayer = [self getLineShapeLayerWithPoints:currentPointArray leftConerPoint:leftConerPoint rightConerPoint:rightConerPoint];
    
    XLineChartGradientLine* gradientLayer = [self.dataHelper.delegate lineChart:self.dataHelper.chart lineForLineChartAtIndex:manager_idx];
    
    if (gradientLayer.isShowGradient == true) {
      gradientLayer.frame = CGRectMake(self.frame.origin.x, manager.pointMinY, self.frame.size.width, self.frame.size.height - manager.pointMinY);
      gradientLayer.mask = shapeLayer;
      
      [_gradientLayers addObject:gradientLayer];
      [self.layer addSublayer:gradientLayer];
    }
  
    CAShapeLayer* edgeLayer = [CAShapeLayer lineShapeLayerWithPoints:currentPointArray color:[UIColor colorWithCGColor:(__bridge CGColorRef _Nonnull)(gradientLayer.colors[0])] lineMode:gradientLayer.lineMode lineWidth:gradientLayer.lineWidth];
    [self.edgeShapeLayers addObject:edgeLayer];
    [self.layer addSublayer:edgeLayer];
  }];

}

#pragma mark data Handling
- (NSMutableArray<XGraphAnimationNode*>*)getAreaDrawableAnimationNodesAtLineIdx:(NSInteger)line_idx {
  NSMutableArray<NSValue*>* drawablePoints = [self getDrawablePointsAtLineIndex:line_idx];
  
  /// drawablePoint empty 
  if (drawablePoints.count == 0) {
    NSMutableArray<XGraphAnimationNode*>* areaNodes = [NSMutableArray new];
    return areaNodes;
  }
  
  // Make Close Points
  CGPoint temfirstPoint = drawablePoints[0].CGPointValue;
  CGPoint temlastPoint = drawablePoints.lastObject.CGPointValue;
  CGPoint firstPoint = CGPointMake(0, temfirstPoint.y);
  CGPoint lastPoint = CGPointMake(self.frame.size.width, temlastPoint.y);

  // AreaDrawablePoints
  NSMutableArray<XGraphAnimationNode*>* areaNodes = [NSMutableArray new];
  [drawablePoints
      enumerateObjectsUsingBlock:^(NSValue* _Nonnull pointValue, NSUInteger idx,
                                   BOOL* _Nonnull stop) {
        [areaNodes
            addObject:[[XGraphAnimationNode alloc]
                          initWithAnimationEndPoint:pointValue.CGPointValue]];
      }];
  [areaNodes insertObject:[[XGraphAnimationNode alloc]
                              initWithAnimationEndPoint:firstPoint]
                  atIndex:0];
  [areaNodes addObject:[[XGraphAnimationNode alloc]
                           initWithAnimationEndPoint:lastPoint]];

  return areaNodes;
}

- (NSMutableArray<NSValue*>*)getDrawablePointsAtLineIndex:(NSInteger)line_idx {
  NSMutableArray* linePointArray = [NSMutableArray new];
  NSInteger count = [self.dataHelper.delegate lineChart:self.dataHelper.chart numberOfPointsInLine:line_idx];
  for (int point_idx = 0; point_idx < count; point_idx++) {
    
    CGFloat obj = [self.dataHelper.delegate lineChart:self.dataHelper.chart valueOfPointAtIndexPath:[NSIndexPath indexPathForRow:point_idx inSection:line_idx]];
    CGPoint point = [self calculateDrawablePointWithNumber:@(obj)
                                                       idx:point_idx
                                                     count:count
                                                    bounds:self.bounds];
    NSValue* pointValue = [NSValue valueWithCGPoint:point];
    [linePointArray addObject:pointValue];
  }
  return linePointArray;
}

#pragma mark ShapeLayerDrawer

- (CAShapeLayer*)getLineShapeLayerWithPoints:(NSArray<NSValue*>*)points
                              leftConerPoint:(CGPoint)leftConerPoint
                             rightConerPoint:(CGPoint)rightConerPoint {

  CAShapeLayer* lineLayer = [CAShapeLayer layer];
  UIBezierPath* line = [[UIBezierPath alloc] init];

  // points count == 0 gurad
  if (points.count == 0) {
    return lineLayer;
  }
  // line
  for (int i = 0; i < points.count - 1; i++) {
    CGPoint point1 = points[i].CGPointValue;
    CGPoint point2 = points[i + 1].CGPointValue;
    if (i == 0) {
      [line moveToPoint:point1];
    }
    if (self.configuration.lineMode == XCurveLine) {
      CGPoint midPoint = [[XAuxiliaryCalculationHelper shareCalculationHelper]
          midPointBetweenPoint1:point1
                      andPoint2:point2];
      [line addQuadCurveToPoint:midPoint
                   controlPoint:[[XAuxiliaryCalculationHelper
                                    shareCalculationHelper]
                                    controlPointBetweenPoint1:midPoint
                                                    andPoint2:point1]];
      [line addQuadCurveToPoint:point2
                   controlPoint:[[XAuxiliaryCalculationHelper
                                    shareCalculationHelper]
                                    controlPointBetweenPoint1:midPoint
                                                    andPoint2:point2]];
    } else {
      [line addLineToPoint:point2];
    }
  }
  // closePoint
  [line addLineToPoint:rightConerPoint];
  [line addLineToPoint:leftConerPoint];
  [line addLineToPoint:points[0].CGPointValue];
  lineLayer.path = line.CGPath;
  lineLayer.strokeColor = [UIColor clearColor].CGColor;
  lineLayer.fillColor = [UIColor whiteColor].CGColor;
  lineLayer.opacity = 1;

  lineLayer.lineWidth = 1;
  lineLayer.lineCap = kCALineCapRound;
  lineLayer.lineJoin = kCALineJoinRound;
  return lineLayer;
}

#pragma mark Observerhelper



#pragma mark Gestures Action
- (void)annotationViewTap:(UITapGestureRecognizer *)tagGes
{
  [self.annotationViews enumerateObjectsUsingBlock:^(XEventAnnotationView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj isEqual:tagGes.view]) {
      JYPopTipView* roundRectButtonPopTipView = [[JYPopTipView alloc] initWithMessage:[NSString stringWithFormat:@"%@ %@",obj.annotation.name, obj.annotation.event]];
      roundRectButtonPopTipView.textFont = [UIFont systemFontOfSize:12];
      roundRectButtonPopTipView.backgroundColor = [UIColor colorWithRed:115/255.0 green:160/255.0 blue:240/255.0 alpha:1];
      roundRectButtonPopTipView.textColor = [UIColor blackColor];
      roundRectButtonPopTipView.has3DStyle = NO;
      roundRectButtonPopTipView.borderWidth = 0;
      roundRectButtonPopTipView.hasShadow = NO;
      roundRectButtonPopTipView.dismissTapAnywhere = YES;
      [roundRectButtonPopTipView presentPointingAtView:tagGes.view inView:self animated:YES];
    }
  }];
}
#pragma mark Notification Action
- (void)becomeAlive {
  [self startAnimation];
}

- (void)enterBackground {
  [self.managers enumerateObjectsUsingBlock:^(XAreaAnimationManager * _Nonnull manager, NSUInteger manager_idx, BOOL * _Nonnull stop) {
    [manager.areaNodes enumerateObjectsUsingBlock:^(
                                                                      XGraphAnimationNode* _Nonnull node,
                                                                      NSUInteger idx,
                                                                      BOOL* _Nonnull stop) {
      node.graphAnimationCurrentPoint = CGPointMake(
                                                    node.getAnimationNodeX,
                                                    [[XAuxiliaryCalculationHelper shareCalculationHelper]
                                                     getOriginYIncreaseInFilpCoordinateSystemWithBoundsH:self.bounds.size
                                                     .height
                                                     targetY:
                                                     node.getAnimationNodeEndY
                                                     percentage:0
                                                     startRatio:StartRatio]);
    }];
  }];
  [self refreshView];
}


- (void)addAnnotationAction {
  [self refreshView];
}


#pragma mark - Help Methods
// Calculate -> Point
- (CGPoint)calculateDrawablePointWithNumber:(NSNumber*)number
                                        idx:(NSUInteger)idx
                                numberArray:(NSMutableArray*)numberArray
                                     bounds:(CGRect)bounds {
  CGFloat percentageH = [[XAuxiliaryCalculationHelper shareCalculationHelper]
      calculateTheProportionOfHeightByTop:self.top.doubleValue
                                   bottom:self.bottom.doubleValue
                                   height:number.doubleValue];
  CGFloat percentageW = [[XAuxiliaryCalculationHelper shareCalculationHelper]
      calculateTheProportionOfWidthByIdx:(idx)
                                   count:numberArray.count];
  CGFloat pointY = percentageH * bounds.size.height;
  CGFloat pointX = percentageW * bounds.size.width;
  CGPoint point = CGPointMake(pointX, pointY);
  CGPoint rightCoordinatePoint =
      [[XAuxiliaryCalculationHelper shareCalculationHelper]
          changeCoordinateSystem:point
                  withViewHeight:self.frame.size.height];
  return rightCoordinatePoint;
}

// Calculate -> Point
- (CGPoint)calculateDrawablePointWithNumber:(NSNumber*)number
                                        idx:(NSUInteger)idx
                                      count:(NSInteger)count
                                     bounds:(CGRect)bounds {
  CGFloat percentageH = [[XAuxiliaryCalculationHelper shareCalculationHelper]
                         calculateTheProportionOfHeightByTop:self.top.doubleValue
                         bottom:self.bottom.doubleValue
                         height:number.doubleValue];
  CGFloat percentageW = [[XAuxiliaryCalculationHelper shareCalculationHelper]
                         calculateTheProportionOfWidthByIdx:(idx)
                         count:count];
  CGFloat pointY = percentageH * bounds.size.height;
  CGFloat pointX = percentageW * bounds.size.width;
  CGPoint point = CGPointMake(pointX, pointY);
  CGPoint rightCoordinatePoint =
  [[XAuxiliaryCalculationHelper shareCalculationHelper]
   changeCoordinateSystem:point
   withViewHeight:self.frame.size.height];
  return rightCoordinatePoint;
}

#pragma mark GET
- (XAreaLineChartConfiguration*)configuration {
  if (_configuration == nil) {
    _configuration = [[XAreaLineChartConfiguration alloc] init];
  }
  return _configuration;
}


@end
