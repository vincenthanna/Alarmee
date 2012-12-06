//
//  AlarmeeTests.m
//  AlarmeeTests
//
//  Created by 김 연희 on 12. 2. 26..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import "AlarmeeTests.h"
#import "Item.h"
#import "Schedule.h"

@implementation AlarmeeTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSchedule
{   
    Item *item;
    //통지시간 정하기 
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = 
        NSYearCalendarUnit | 
        NSMonthCalendarUnit | 
        NSDayCalendarUnit |
        NSHourCalendarUnit |
        NSMinuteCalendarUnit |
        NSWeekCalendarUnit |
        NSWeekdayCalendarUnit |
        NSWeekdayOrdinalCalendarUnit |
        NSSecondCalendarUnit;
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc]init];
    NSDateComponents* dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDate *date, *now;
    
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 14;
    dateComponents.hour = 8;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    now = [[calendar dateFromComponents:dateComponents] copy];
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 14;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_DAY;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.day != 15 || dateComponents.month != 8 || dateComponents.hour != 7) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 13;
    dateComponents.hour = 8;
    dateComponents.minute = 30;
    dateComponents.second = 0;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_NONE;
    
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    if (date != nil) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item]; 
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 13;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_WEEK;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.day != 20 || dateComponents.month != 8 || dateComponents.hour != 7) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 12;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_MONTH;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.month != 9 || dateComponents.day != 12) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];
    
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 16;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_MONTH;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.month != 8 || dateComponents.day != 16 ||dateComponents.hour != 7) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];
    
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 31;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_MONTH;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.month != 8 || dateComponents.day != 31 ||dateComponents.hour != 7) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];

}

-(void)testExample2
{

    Item *item;
    //통지시간 정하기 
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = 
    NSYearCalendarUnit | 
    NSMonthCalendarUnit | 
    NSDayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSWeekCalendarUnit |
    NSWeekdayCalendarUnit |
    NSWeekdayOrdinalCalendarUnit |
    NSSecondCalendarUnit;
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc]init];
    NSDateComponents* dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDate *date, *now;
    
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 31;
    dateComponents.hour = 20;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    now = [[calendar dateFromComponents:dateComponents] copy];

    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 8;
    dateComponents.day = 31;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_MONTH;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.day != 30 || dateComponents.month != 9 || dateComponents.hour != 7) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];    
}

-(void)testExample3
{
    Item *item;
    //통지시간 정하기 
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = 
    NSYearCalendarUnit | 
    NSMonthCalendarUnit | 
    NSDayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSWeekCalendarUnit |
    NSWeekdayCalendarUnit |
    NSWeekdayOrdinalCalendarUnit |
    NSSecondCalendarUnit;
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc]init];
    NSDateComponents* dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDate *date, *now;
    
    dateComponents.year = 2012;
    dateComponents.month = 12;
    dateComponents.day = 31;
    dateComponents.hour = 20;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    now = [[calendar dateFromComponents:dateComponents] copy];
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 12;
    dateComponents.day = 31;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_MONTH;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.day != 31 || dateComponents.month != 1 || dateComponents.hour != 7 || dateComponents.year != 2013) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 12;
    dateComponents.day = 31;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_WEEK;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.weekday != 2 || dateComponents.year != 2013 || dateComponents.day != 7 || dateComponents.month != 1) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];
}


-(void)testExample4
{
    Item *item;
    //통지시간 정하기 
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = 
    NSYearCalendarUnit | 
    NSMonthCalendarUnit | 
    NSDayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSWeekCalendarUnit |
    NSWeekdayCalendarUnit |
    NSWeekdayOrdinalCalendarUnit |
    NSSecondCalendarUnit;
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc]init];
    NSDateComponents* dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDate *date, *now;
    
    dateComponents.year = 2012;
    dateComponents.month = 1;
    dateComponents.day = 31;
    dateComponents.hour = 20;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    now = [[calendar dateFromComponents:dateComponents] copy];
    
    item = [[Item alloc]init];
    item.title = @"A";
    dateComponents.year = 2012;
    dateComponents.month = 1;
    dateComponents.day = 31;
    dateComponents.hour = 7;
    dateComponents.minute = 30;
    dateComponents.second = 10;
    date = [calendar dateFromComponents:dateComponents];
    item.duedate = [date copy];
    item.repeat = REPEAT_MONTH;
    //recommend test:
    date = [Schedule recommend:item _dateNow:now];
    dateComponents = [calendar components:unitFlags fromDate:date];
    if (dateComponents.day != 29 || dateComponents.month != 2 || dateComponents.hour != 7 || dateComponents.year != 2012) {
        STFail(@"[%s]%d recommend fail!", __func__,__LINE__);
    }
    [itemsArray addObject:item];
}
@end
