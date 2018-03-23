//
//  XLineDataHelper.m
//  XJYChart
//
//  Created by 谢俊逸 on 16/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//

#import "XLineDataHelper.h"
#import "XNotificationBridge.h"

@implementation XLineDataHelper

- (instancetype)init {
  if (self = [super init]) {
    _annotations = [NSMutableArray new];
  }
  return self;
}

- (void)addAnnotation:(id<XEventAnnotation>)annotation {
  [self.annotations addObject:annotation];
  /// Post Notification
  /// ChartView will add new annotation
  [[NSNotificationCenter defaultCenter] postNotificationName:[XNotificationBridge shareXNotificationBridge].AddAnnotationNotification object:nil];
}

- (void)addAnnotations:(NSMutableArray*)annotions {
  [self.annotations addObjectsFromArray:annotions];
  [[NSNotificationCenter defaultCenter] postNotificationName:[XNotificationBridge shareXNotificationBridge].AddAnnotationNotification object:nil];
}

- (void)setAnnotations:(NSMutableArray<id<XEventAnnotation>> *)annotations {
  _annotations = annotations;
  [[NSNotificationCenter defaultCenter] postNotificationName:[XNotificationBridge shareXNotificationBridge].AddAnnotationNotification object:nil];
}



@end
