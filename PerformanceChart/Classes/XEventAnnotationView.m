//
//  XEventAnnotationView.m
//  XJYChart
//
//  Created by 谢俊逸 on 16/1/2018.
//  Copyright © 2018 JunyiXie. All rights reserved.
//

#import "XEventAnnotationView.h"
@interface XEventAnnotationView()

@property(nonatomic, strong) UILabel* label;


@end


@implementation XEventAnnotationView

- (instancetype)initWithAnnotation:(id<XEventAnnotation>)annotation {
  if (self = [super init]) {
    _annotation = annotation;
    self.backgroundColor = [UIColor whiteColor];
    self.alpha = 0.8;
//    self.label = [[UILabel alloc] init];
//    self.label.backgroundColor = [UIColor redColor];
//    self.label.text = [NSString stringWithFormat:@"%@.%@", annotation.name, annotation.event];
//    self.label.font = [UIFont systemFontOfSize:8];
//    self.label.lineBreakMode = NSLineBreakByWordWrapping;
//    self.label.numberOfLines = 0;
//    self.label.textColor = [UIColor blackColor];
//    [self addSubview:self.label];
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
//  self.label.frame = self.bounds;
}

- (instancetype)initWithAnnotation:(id<XEventAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [self initWithAnnotation:annotation]) {
    
  }
  return self;
}

@end
