//
//  MNCalendarViewDayCell.m
//  MNCalendarView
//
//  Created by Min Kim on 7/28/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewDayCell.h"

NSString *const MNCalendarViewDayCellIdentifier = @"MNCalendarViewDayCellIdentifier";

@interface MNCalendarViewDayCell()

@property(nonatomic,strong,readwrite) NSDate *date;
@property(nonatomic,strong,readwrite) NSDate *month;
@property(nonatomic,assign,readwrite) NSUInteger weekday;

@end

@implementation MNCalendarViewDayCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.enabledTextColor = [UIColor darkTextColor];
        self.disabledTextColor = [UIColor lightGrayColor];
        self.enabledBackgroundColor = [UIColor whiteColor];
        self.disabledBackgroundColor = [UIColor colorWithRed:.96f green:.96f blue:.96f alpha:1.f];
    }
    return self;
}

- (void)setDate:(NSDate *)date month:(NSDate *)month calendar:(NSCalendar *)calendar
{
    self.date     = date;
    self.month    = month;
    self.calendar = calendar;
    
    NSDateComponents *components = [self.calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:self.date];
    NSDateComponents *monthComponents = [self.calendar components:NSCalendarUnitMonth fromDate:self.month];

    self.weekday = (components.weekday + self.calendar.firstWeekday - 1) % 7;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", @(components.day)];
    
    self.enabled         = monthComponents.month == components.month;
    
    [self setNeedsDisplay];
}

- (BOOL)isOtherMonthDate
{
    NSDateComponents *components      = [self.calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:self.date];
    NSDateComponents *monthComponents = [self.calendar components:NSCalendarUnitMonth fromDate:self.month];

    return (monthComponents.month != components.month);
}

- (void)hideIfOtherMonthDate
{
    if ([self isOtherMonthDate]) {
        [self.titleLabel setText:@""];
        self.selected = NO;
        self.enabled  = NO;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    self.titleLabel.textColor = self.enabled ? self.enabledTextColor : self.disabledTextColor;
    
    self.backgroundColor = self.enabled ? self.enabledBackgroundColor : self.disabledBackgroundColor;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context        = UIGraphicsGetCurrentContext();
    CGColorRef separatorColor   = self.separatorColor.CGColor;
    CGSize size                 = self.bounds.size;
    
    if (self.weekday != 7) {
        CGFloat pixel = 1.f / [UIScreen mainScreen].scale;
        MNContextDrawLine(context,
                          CGPointMake(size.width - pixel, pixel),
                          CGPointMake(size.width - pixel, size.height),
                          separatorColor,
                          pixel);
    }
}

@end
