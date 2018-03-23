//
//  XEventAnnotation.h
//  XJYChart
//
//  Created by 谢俊逸 on 16/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//
#ifndef XEventAnnotation_h
#define XEventAnnotation_h

@protocol XEventAnnotation

@required

@property(nonatomic, readonly) NSTimeInterval time;
@property(nonatomic, copy, readonly) NSString* name;
@property(nonatomic, copy, readonly) NSString* event;


- (void)setTime:(NSTimeInterval)time;

@end


#endif /* XEventAnnotation_h */

