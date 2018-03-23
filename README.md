# PerformanceChart

[![CI Status](http://img.shields.io/travis/junyixie/PerformanceChart.svg?style=flat)](https://travis-ci.org/junyixie/PerformanceChart)
[![Version](https://img.shields.io/cocoapods/v/PerformanceChart.svg?style=flat)](http://cocoapods.org/pods/PerformanceChart)
[![License](https://img.shields.io/cocoapods/l/PerformanceChart.svg?style=flat)](http://cocoapods.org/pods/PerformanceChart)
[![Platform](https://img.shields.io/cocoapods/p/PerformanceChart.svg?style=flat)](http://cocoapods.org/pods/PerformanceChart)


## Use
```objectivec
- (XLineChartPoint *)lineChart:(XLineChart *)lineChart pointForLineAtIndexPath:(NSIndexPath *)indexPath {
  XLineChartPoint *point = [[XLineChartPoint alloc] init];

  if (indexPath.section == ChartMonitorKindCPU) {
    point.fillColor = cpu_color.CGColor;
    point.diameter = 4;
    point.pointType = XPointAnnular;
  } else if (indexPath.section == ChartMonitorKindMEMORY) {
    point.fillColor = memory_color.CGColor;
    point.diameter = 4;
    point.pointType = XPointAnnular;
  } else {
    point.fillColor = fps_color.CGColor;
    point.diameter = 4;
    point.pointType = XPointAnnular;
  }

  return point;

}

- (CGFloat)lineChart:(XLineChart *)lineChart valueOfPointAtIndexPath:(NSIndexPath *)indexPath {
    
    // 注意 不能超过图表创建的 top 和 bottom
    return 0.5;
    
}


- (NSInteger)lineChart:(XLineChart *)lineChart numberOfPointsInLine:(NSInteger)section {
  
  // 根据你的数据源数量
  // return array.counts;
}

- (XLineChartGradientLine *)lineChart:(XLineChart *)lineChart lineForLineChartAtIndex:(NSInteger)index {
  XLineChartGradientLine *line = [[XLineChartGradientLine alloc] init];

  if (index == ChartMonitorKindCPU) {

    line.colors = @[
                    (__bridge id)cpu_color.CGColor,
                    (__bridge id)[UIColor whiteColor].CGColor
                    ];
    line.opacity = 0.6;
    line.lineMode = XStraightLine;
    line.lineWidth = 1.5;

  } else if(index == ChartMonitorKindMEMORY) {
    line.lineWidth = 1.5;
    line.lineMode = XStraightLine;
    line.colors = @[
                    (__bridge id)memory_color.CGColor,
                    (__bridge id)[UIColor whiteColor].CGColor
                    ];
    line.opacity = 0.6;
  } else {
    line.lineWidth = 1.5;
    line.lineMode = XStraightLine;
    line.colors = @[
                    (__bridge id)fps_color.CGColor,
                    (__bridge id)[UIColor whiteColor].CGColor
                    ];
    line.opacity = 0.6;
  }

  
  return line;


}

-(NSInteger)numberOfLinesInLineChart:(XLineChart *)lineChart {
// 根据你线的数量
  return 3;
}

- (NSString *)lineChart:(XLineChart *)lineChart titleForAbscissaAtIndex:(NSInteger)index {
  return time_str;
}
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PerformanceChart is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PerformanceChart'
```

## Author

junyixie, xiejunyi19970518@outlook.com

## License

PerformanceChart is available under the MIT license. See the LICENSE file for more info.
