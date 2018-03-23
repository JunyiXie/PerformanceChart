//
//  XAbscissaView.m
//  RecordLife
//
//  Created by 谢俊逸 on 16/03/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "XAbscissaView.h"

@interface XAbscissaView ()

@property(nonatomic, strong) NSMutableArray<UILabel*>* labelArray;
@property(nonatomic, strong) NSMutableArray<NSString*>* dataDescribeArray;

@end

@implementation XAbscissaView

- (instancetype)initWithFrame:(CGRect)frame
                dataDescribeArray:(NSMutableArray*)dataDescribeArray {
  if (self = [self initWithFrame:frame]) {
    self.backgroundColor = [UIColor whiteColor];
    self.dataDescribeArray = dataDescribeArray;
    self.labelArray = [NSMutableArray new];
    [self setupUI];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
  }
  return self;
}


- (void)setupUI {
  CGFloat labelWidth = self.frame.size.width / self.dataDescribeArray.count;
  CGFloat intervalWidth = labelWidth / 6;
  for (int i = 0; i < self.dataDescribeArray.count; i++) {
    UILabel* label = [[UILabel alloc]
        initWithFrame:CGRectMake(labelWidth * i + intervalWidth, 0,
                                 labelWidth - 2 * intervalWidth,
                                 self.frame.size.height)];
    label.text = self.dataDescribeArray[i];
    label.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:10];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
  }
}

@end
