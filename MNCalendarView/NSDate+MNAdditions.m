//
//  NSDate+MNAdditions.m
//  MNCalendarView
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "NSDate+MNAdditions.h"

@implementation NSDate (MNAdditions)

- (instancetype)mn_firstDateOfMonth:(NSCalendar *)calendar {
    if (nil == calendar) {
        calendar = [NSCalendar currentCalendar];
    }
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    
    [components setDay:1];
    
    return [calendar dateFromComponents:components];
}

- (instancetype)mn_lastDateOfMonth:(NSCalendar *)calendar {
    if (nil == calendar) {
        calendar = [NSCalendar currentCalendar];
    }
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    [components setDay:0];
    [components setMonth:components.month + 1];
    
    return [calendar dateFromComponents:components];
}

- (instancetype)mn_beginningOfDay:(NSCalendar *)calendar {
    if (nil == calendar) {
        calendar = [NSCalendar currentCalendar];
    }
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    [components setHour:0];
    
    return [calendar dateFromComponents:components];
}

- (instancetype)mn_dateWithDay:(NSUInteger)day calendar:(NSCalendar *)calendar {
    if (nil == calendar) {
        calendar = [NSCalendar currentCalendar];
    }
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    
    [components setDay:day];
    
    return [calendar dateFromComponents:components];
}

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    NSComparisonResult beginDateComparison =[date compare:beginDate];
    NSComparisonResult endDateComparison =[date compare:endDate];
    
    if (beginDateComparison == NSOrderedSame)
        return YES;
    if (endDateComparison == NSOrderedSame)
        return YES;
    
    if (beginDateComparison == NSOrderedAscending)
    	return NO;
    
    if (endDateComparison == NSOrderedDescending)
    	return NO;
    
    return YES;
}

- (instancetype)firstDateOfWeekWithCalendar:(NSCalendar *)calendar
{

    NSDate *startOfWeek;
    [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfWeek interval:NULL forDate:self];
    return startOfWeek;

}

- (instancetype)firstDateOfMonthWithCalendar:(NSCalendar *)calendar
{

    NSDate *startOfMonth;
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&startOfMonth interval:NULL forDate:self];
    return startOfMonth;

}

- (instancetype)lastDateOfWeekWithCalendar:(NSCalendar *)calendar
{
    NSDateComponents * oneWeek = [[NSDateComponents alloc] init];
    [oneWeek setWeekOfYear:1];
    return [[calendar dateByAddingComponents:oneWeek toDate:[self firstDateOfWeekWithCalendar:calendar] options:0] dateByAddingTimeInterval:-1];

}

- (instancetype)lastDateOfMonthWithCalendar:(NSCalendar *)calendar
{

    NSRange days = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return [[self firstDateOfMonthWithCalendar:calendar] dateByAddingTimeInterval:(days.length * 24 * 60 * 60) - 1];
    
}

@end
