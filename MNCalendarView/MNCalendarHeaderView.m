//
//  MNCalendarHeaderView.m
//  MNCalendarView
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarHeaderView.h"

NSString *const MNCalendarHeaderViewIdentifier = @"MNCalendarHeaderViewIdentifier";

@interface MNCalendarHeaderView()

@property(nonatomic,strong,readwrite) UILabel *titleLabel;

@end

@implementation MNCalendarHeaderView

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.titleLabel.backgroundColor = UIColor.clearColor;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.accessibilityTraits = UIAccessibilityTraitHeader;

    [self addSubview:self.titleLabel];
  }
  return self;
}

-(void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    [self.titleLabel setTextColor:titleColor];
}

- (void)setDate:(NSDate *)date {
  _date = date;

  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  [dateFormatter setDateFormat:@"MMMM yyyy"];

  self.titleLabel.text = [dateFormatter stringFromDate:self.date];
}

@end
