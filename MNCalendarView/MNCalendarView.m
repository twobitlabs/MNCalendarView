//
//  MNCalendarView.m
//  MNCalendarView
//
//  Created by Min Kim on 7/23/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarView.h"
#import "MNCalendarViewLayout.h"
#import "MNCalendarViewDayCell.h"
#import "MNCalendarViewWeekdayCell.h"
#import "MNCalendarHeaderView.h"
#import "MNFastDateEnumeration.h"
#import "NSDate+MNAdditions.h"

@interface MNCalendarView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,strong,readwrite) UICollectionView *collectionView;
@property(nonatomic,strong,readwrite) UICollectionViewFlowLayout *layout;

@property(nonatomic, assign) BOOL inversed;


@property(nonatomic,strong,readwrite) NSArray *monthDates;
@property(nonatomic,strong,readwrite) NSArray *weekdaySymbols;
@property(nonatomic,assign,readwrite) NSUInteger daysInWeek;

@property(nonatomic,strong,readwrite) NSDateFormatter *monthFormatter;

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date;
- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date;

- (BOOL)dateEnabled:(NSDate *)date;
- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)applyConstraints;

@end

@implementation MNCalendarView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame referenceDate:nil daysBefore:-1 daysAfter:-1];
}

// designated initializer
// - daysBefore and daysAfter are relative to referenceDate for determining from and to dates.
// - referenceDate defaults to today.
// - referenceDate is so named because it's a point of reference for determining from/to dates; it's not necessarily selected or today's date.
// - daysBefore and daysAfter can be set to -1 to use default values for fromDate and toDate; i.e. from today to 4 years from today
- (id)initWithFrame:(CGRect)frame referenceDate:(NSDate *)referenceDate daysBefore:(int)daysBefore daysAfter:(int)daysAfter
{
    if (self = [super initWithFrame:frame]) {
        
        self.calendar           = NSCalendar.currentCalendar;

        // default to today's date
        if (!referenceDate) {
            referenceDate = [NSDate date];
        }
        self.fromDate = (daysBefore < 0 ? [referenceDate mn_beginningOfDay:self.calendar] : [referenceDate dateByAddingTimeInterval:daysBefore * MN_DAY * -1]);
        self.toDate = [referenceDate dateByAddingTimeInterval:(daysAfter < 0 ? 4 * MN_YEAR : daysAfter * MN_DAY)];

        self.daysInWeek         = 7;
        
        self.headerViewClass    = MNCalendarHeaderView.class;
        self.weekdayCellClass   = MNCalendarViewWeekdayCell.class;
        self.dayCellClass       = MNCalendarViewDayCell.class;
        
        _separatorColor         = [UIColor colorWithRed:.85f green:.85f blue:.85f alpha:1.f];
        
        [self addSubview:self.collectionView];
        [self applyConstraints];
        self.headerTitleColor = [UIColor blackColor];
        self.headerFont = [UIFont systemFontOfSize:16.f];
        self.weekdayFont = [UIFont systemFontOfSize:12.f];
        self.dayFont = [UIFont systemFontOfSize:14.f];
        self.todayFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        self.tapEnabled = YES;
        
    }
    return self;
}

- (void)setHeaderTitleColor:(UIColor *)headerTitleColor
{
    [self setHeaderTitleColor:headerTitleColor reloadData:YES];
}

- (void)setHeaderTitleColor:(UIColor *)headerTitleColor reloadData:(BOOL)reloadData
{
    _headerTitleColor = headerTitleColor;
    if (reloadData) {
        [self reloadData];
    }
}

- (UICollectionView *)collectionView
{
    if (nil == _collectionView) {
        MNCalendarViewLayout *layout = [[MNCalendarViewLayout alloc] init];
        
        _collectionView =
        [[UICollectionView alloc] initWithFrame:CGRectZero
                           collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor colorWithRed:.96f green:.96f blue:.96f alpha:1.f];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        //      [(UICollectionViewFlowLayout *)_collectionView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        //        [self.collectionView setPagingEnabled:YES];
        
        [_collectionView registerClass:self.dayCellClass
            forCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier];
        
        [_collectionView registerClass:self.weekdayCellClass
            forCellWithReuseIdentifier:MNCalendarViewWeekdayCellIdentifier];
        
        [_collectionView registerClass:self.headerViewClass
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:MNCalendarHeaderViewIdentifier];
    }
    return _collectionView;
}

- (void)setPagingEnableSetting:(BOOL)pagingEnableSetting
{
    _pagingEnableSetting = pagingEnableSetting;
    [(MNCalendarViewLayout *)self.collectionView.collectionViewLayout setPagingEnable:pagingEnableSetting];
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
}

- (void)setCalendar:(NSCalendar *)calendar
{
    _calendar = calendar;
    
    self.monthFormatter = [[NSDateFormatter alloc] init];
    self.monthFormatter.calendar = calendar;
    [self.monthFormatter setDateFormat:@"MMMM yyyy"];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = [selectedDate mn_beginningOfDay:self.calendar];
}

- (void)setSelectedDateRange:(NSArray *)selectedDateRange
{
    _selectedDateRange = selectedDateRange;
    [self.collectionView reloadData];
}

- (void)reloadData
{
    NSMutableArray *monthDates = @[].mutableCopy;
    MNFastDateEnumeration *enumeration = [[MNFastDateEnumeration alloc] initWithFromDate:[self.fromDate firstDateOfMonthWithCalendar:self.calendar]
                                                                                  toDate:[self.toDate lastDateOfMonthWithCalendar:self.calendar]
                                                                                calendar:self.calendar
                                                                                    unit:NSMonthCalendarUnit];

    for (NSDate *date in enumeration) {
        [monthDates addObject:date];
    }
    
    self.monthDates = monthDates;
    if ( self.inversed ) {
        self.monthDates = [[monthDates reverseObjectEnumerator] allObjects];
    }
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = self.calendar;
    
    self.weekdaySymbols = formatter.shortWeekdaySymbols;
    
    [self.collectionView reloadData];
}

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date
{
    return [[date firstDateOfMonthWithCalendar:self.calendar] firstDateOfWeekWithCalendar:self.calendar];
}

- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date
{
    return [[date lastDateOfMonthWithCalendar:self.calendar] lastDateOfWeekWithCalendar:self.calendar];
}

- (void)applyConstraints
{
    NSDictionary *views = @{@"collectionView" : self.collectionView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

- (BOOL)dateEnabled:(NSDate *)date
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
        return [self.delegate calendarView:self shouldSelectDate:date];
    }
    return YES;
}

- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_tapEnabled) {
        [self.collectionView reloadData];
        return NO;
    }
    MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL enabled = cell.enabled;
    
    if ([cell isKindOfClass:MNCalendarViewDayCell.class] && enabled) {
        MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;
        
        enabled = [self dateEnabled:dayCell.date];
    }
    
    return enabled;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    if (!date || [date compare:_fromDate] == NSOrderedAscending || [date compare:_toDate] == NSOrderedDescending) {
        return nil;
    }
    
    unsigned units = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
    
    NSDateComponents *fromDateComp = [self.calendar components:units fromDate:_fromDate];
    NSDateComponents *toDateComp   = [self.calendar components:units fromDate:date];
    
    NSInteger yearDiff  = toDateComp.year - fromDateComp.year;
    NSInteger monthDiff = toDateComp.month - fromDateComp.month;
    NSInteger monthDay  = toDateComp.day;
    
    [toDateComp setDay:1];
    toDateComp = [self.calendar components:units fromDate:[self.calendar dateFromComponents:toDateComp]];
    
    NSInteger section = (yearDiff * 12) + monthDiff;
    NSInteger row = self.daysInWeek + [toDateComp weekday] + monthDay - 2;
    
    return [NSIndexPath indexPathForItem:row inSection:section];
}

- (void)scrollToMonthForDate:(NSDate *)date {
    [self scrollToMonthForDate:date animated:YES];
}

// positions the month header at the top of the view
- (void)scrollToMonthForDate:(NSDate *)date animated:(BOOL)animated {
    // from http://stackoverflow.com/questions/16246240/programmatically-scroll-to-a-supplementary-view-within-uicollectionview

    NSIndexPath *indexPath = [self indexPathForDate:date]; // indexPath of your header, only section is relevant
    if (!indexPath) {
        return;
    }

    CGFloat offsetY = [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath].frame.origin.y;

    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, offsetY - self.collectionView.contentInset.top) animated:animated];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    NSIndexPath *indexPath = [self indexPathForDate:date];
    if (!indexPath) {
        return;
    }
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:animated];
}

- (void)scrollToDate:(NSDate *)date
{
    [self scrollToDate:date animated:YES];
}

- (void)selectDate:(NSDate *)date animated:(BOOL)animated
{
    NSIndexPath *indexPath = [self indexPathForDate:date];
    if (!indexPath) {
        return;
    }
    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:animated
                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.monthDates.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    MNCalendarHeaderView *headerView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:MNCalendarHeaderViewIdentifier
                                              forIndexPath:indexPath];
    [headerView setTitleColor:self.headerTitleColor];
    headerView.backgroundColor = self.collectionView.backgroundColor;
    headerView.titleLabel.text = [self.monthFormatter stringFromDate:self.monthDates[indexPath.section]];
    headerView.titleLabel.font = self.headerFont;
    
    return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDate *monthDate = self.monthDates[section];
    
    NSDateComponents *components = [self.calendar components:NSDayCalendarUnit
                                                    fromDate:[self firstVisibleDateOfMonth:monthDate]
                                                      toDate:[self lastVisibleDateOfMonth:monthDate]
                                                     options:0];
    
    return self.daysInWeek + components.day + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item < self.daysInWeek) {
        MNCalendarViewWeekdayCell *cell    = [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewWeekdayCellIdentifier
                                                                                    forIndexPath:indexPath];

        NSInteger adjustedIndexOfDayInWeek = (indexPath.item + self.calendar.firstWeekday - 1) % self.daysInWeek;
        cell.titleLabel.text               = self.weekdaySymbols[adjustedIndexOfDayInWeek];
        cell.backgroundColor               = self.collectionView.backgroundColor;
        cell.separatorColor                = self.separatorColor;
        cell.titleLabel.textColor          = self.headerTitleColor;
        cell.titleLabel.font               = self.weekdayFont;

        return cell;
    }
    MNCalendarViewDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier forIndexPath:indexPath];
    cell.separatorColor         = self.separatorColor;
    if (self.enabledDayTextColor) {
        cell.enabledTextColor = self.enabledDayTextColor;
    }
    if (self.disabledDayTextColor) {
        cell.disabledTextColor = self.disabledDayTextColor;
    }
    if (self.enabledDayBackgroundColor) {
        cell.enabledBackgroundColor = self.enabledDayBackgroundColor;
    }
    if (self.disabledDayBackgroundColor) {
        cell.disabledBackgroundColor = self.disabledDayBackgroundColor;
    }
    if ( self.todayBackgroundColor ) {
        cell.selectedBackgroundView.backgroundColor = self.todayBackgroundColor;
    }
    cell.titleLabel.font        = self.dayFont;
    NSDate *monthDate           = self.monthDates[indexPath.section];
    NSDate *firstDateInMonth    = [self firstVisibleDateOfMonth:monthDate];
    NSUInteger day              = indexPath.item - self.daysInWeek;
    
    NSDateComponents *components = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:firstDateInMonth];
    components.day += day;
    
    NSDate *date = [self.calendar dateFromComponents:components];
    [cell setDate:date
            month:monthDate
         calendar:self.calendar];
    [cell setEnabled:[self dateEnabled:date]];
    
    
    if (self.selectedDate && cell.enabled) {
        if (self.selectedDateRange.count < 2) {
            [cell setSelected:[date isEqualToDate:self.selectedDate]];
            if (self.selectedDayBackgroundColor) {
                [cell.selectedBackgroundView setBackgroundColor:self.selectedDayBackgroundColor];
            }
        }
        else {
            [cell.selectedBackgroundView setBackgroundColor:_inRangeDateBackgroundColor];
            [cell setSelected:[NSDate date:date isBetweenDate:self.selectedDateRange[0] andDate:self.selectedDateRange[1]]];
        }
        
        if ([date timeIntervalSinceDate:_selectedDateRange[0]] == 0) {
            [cell.selectedBackgroundView setBackgroundColor:_beginDateBackgroundColor];
        }
        else if ([date timeIntervalSinceDate:_selectedDateRange[1]] == 0){
            [cell.selectedBackgroundView setBackgroundColor:_endateDateBackgroundColor];
        }
        
        
    }
    
    if (!cell.backgroundView) {
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, cell.frame.size.width-2, cell.frame.size.height-2)];
    }
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    if (0 < interval && interval < MN_DAY && ![cell isOtherMonthDate]) {
        NSDictionary *stringAttributes = @{ NSFontAttributeName : self.todayFont
                                            //,NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                            };
        cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:cell.titleLabel.text attributes:stringAttributes];
        cell.titleLabel.textColor      = [UIColor whiteColor];
        
        cell.backgroundView.backgroundColor = self.todayBackgroundColor ? self.todayBackgroundColor : [UIColor colorWithRed:0.09 green:0.06 blue:0.21 alpha:1.0];
    }
    
    [cell hideIfOtherMonthDate];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self canSelectItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self canSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_tapEnabled) {
        return;
    }
    MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:MNCalendarViewDayCell.class] && cell.enabled) {
        MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;
        
        self.selectedDate = dayCell.date;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
            [self.delegate calendarView:self didSelectDate:dayCell.date];
        }
        
        [self.collectionView reloadData];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width      = self.bounds.size.width;
    CGFloat itemWidth  = roundf(width / self.daysInWeek);
    CGFloat itemHeight = indexPath.item < self.daysInWeek ? 30.f : itemWidth;
    
    NSUInteger weekday = indexPath.item % self.daysInWeek;
    
    if (weekday == self.daysInWeek - 1) {
        itemWidth = width - (itemWidth * (self.daysInWeek - 1));
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

@end
