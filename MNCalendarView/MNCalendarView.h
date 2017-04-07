//
//  MNCalendarView.h
//  MNCalendarView
//
//  Created by Min Kim on 7/23/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MN_MINUTE 60.f
#define MN_HOUR   MN_MINUTE * 60.f
#define MN_DAY    MN_HOUR * 24.f
#define MN_WEEK   MN_DAY * 7.f
#define MN_YEAR   MN_DAY * 365.f

@protocol MNCalendarViewDelegate;

@interface MNCalendarView : UIView

@property(nonatomic,strong,readonly) UICollectionView *collectionView;

@property(nonatomic,assign) id<MNCalendarViewDelegate> delegate;

@property(nonatomic,strong) NSCalendar *calendar;
@property(nonatomic,copy)   NSDate     *fromDate;
@property(nonatomic,copy)   NSDate     *toDate;
@property(nonatomic,copy)   NSDate     *selectedDate;
@property(nonatomic, copy) NSArray *selectedDateRange;
@property(nonatomic, strong) UIColor *headerTitleColor;
@property(nonatomic, strong) UIColor *enabledDayTextColor;
@property(nonatomic, strong) UIColor *disabledDayTextColor;
@property(nonatomic, strong) UIColor *selectedDayTextColor;
@property(nonatomic, strong) UIColor *todayTextColor;
@property(nonatomic, strong) UIColor *enabledDayBackgroundColor;
@property(nonatomic, strong) UIColor *disabledDayBackgroundColor;

@property(nonatomic,strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR; // default is the standard separator gray
@property(nonatomic,strong) UIColor *beginDateBackgroundColor;
@property(nonatomic,strong) UIColor *inRangeDateBackgroundColor;
@property(nonatomic,strong) UIColor *endateDateBackgroundColor;
@property(nonatomic,strong) UIColor *selectedDayBackgroundColor;
@property(nonatomic,strong) UIColor *todayBackgroundColor;
@property(nonatomic,strong) UIFont *headerFont;
@property(nonatomic,strong) UIFont *weekdayFont;
@property(nonatomic,strong) UIFont *dayFont;
@property(nonatomic,strong) UIFont *todayFont;
@property(nonatomic,assign) BOOL pagingEnableSetting;
@property(nonatomic,assign) BOOL addsFutureDates;
@property(nonatomic, assign) BOOL tapEnabled;

@property(nonatomic,strong) Class headerViewClass;
@property(nonatomic,strong) Class weekdayCellClass;
@property(nonatomic,strong) Class dayCellClass;

- (id)initWithFrame:(CGRect)frame referenceDate:(NSDate *)referenceDate daysBefore:(int)daysBefore daysAfter:(int)daysAfter;

- (void)scrollToMonthForDate:(NSDate *)date;
- (void)scrollToMonthForDate:(NSDate *)date animated:(BOOL)animated;
- (void)scrollToDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
- (void)selectDate:(NSDate *)date animated:(BOOL)animated;

// set header and weekday title color, optionally reloading data
- (void)setHeaderTitleColor:(UIColor *)headerTitleColor reloadData:(BOOL)reloadData;

- (void)reloadData;

@end

@protocol MNCalendarViewDelegate <NSObject>

@optional

- (BOOL)calendarView:(MNCalendarView *)calendarView shouldSelectDate:(NSDate *)date;
- (void)calendarView:(MNCalendarView *)calendarView didSelectDate:(NSDate *)date;

@end