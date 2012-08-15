//
//  Schedule.m
//  Alarmee
//
//  Created by 연희 김 on 12. 8. 6..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import "Schedule.h"
#import "Item.h"

@implementation Schedule

@synthesize _items;

-(NSDate*)recommend:(Item*)item _dateNow:(NSDate*)dateNow
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = 
        NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSWeekCalendarUnit | 
        NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSSecondCalendarUnit;

    switch(item.repeat) {
        case REPEAT_NONE:
            if ([dateNow compare:item.duedate] == NSOrderedAscending) { // duedate가 나중이다.
                return [item.duedate copy];
            }
            else {
                return nil;
            }
            break;
        case REPEAT_DAY: {
            NSDate *now = [dateNow copy];
            NSDateComponents *dueDC = [calendar components:unitFlags fromDate:item.duedate];
            NSDateComponents *nowDC = [calendar components:unitFlags fromDate:now];
            // 시 분 초를 초로 변환
            int duedateSec = dueDC.hour * 3600 + dueDC.minute * 60 + dueDC.second;
            int nowSec = nowDC.hour * 3600 + nowDC.minute * 60 + nowDC.second;
            if (duedateSec < nowSec) { //이미 예약시간을 넘어갔다. 다음날을 제출해야 한다.
                // 다음날 날짜의 스케줄 시간을 제출해야 한다.
                NSTimeInterval nowTime = [now timeIntervalSince1970];
                nowTime += (24 * 3600); // 하루 증가
                now = [[NSDate alloc] initWithTimeIntervalSince1970:nowTime]; // sec->NSDate로 변환
                nowDC = [calendar components:unitFlags fromDate:now]; // NSDate->NSDateComponents로 변환
                [nowDC setHour:dueDC.hour];
                [nowDC setMinute:dueDC.minute];
                [nowDC setSecond:dueDC.second];
                now = [calendar dateFromComponents:nowDC];
                return now;
            }
            else {
                // 현재시간에 시/분/초만 예약시간으로 변경해서 제출한다.
                [nowDC setHour:dueDC.hour];
                [nowDC setMinute:dueDC.minute];
                [nowDC setSecond:dueDC.second];
                now = [calendar dateFromComponents:nowDC];
                return now;
            }
            break;
        }
        case REPEAT_WEEK: {
            NSDate *now = [dateNow copy];
            NSDateComponents *dueDC = [calendar components:unitFlags fromDate:item.duedate];
            NSDateComponents *nowDC = [calendar components:unitFlags fromDate:now];
            
            if (dueDC.weekday != nowDC.weekday) {
                //요일번호가 동일해질 때까지 하루씩 넘김
                while(dueDC.weekday != nowDC.weekday) {
                    NSTimeInterval nowTime = [now timeIntervalSince1970];
                    nowTime += (24 * 3600); // 하루 증가
                    now = [[NSDate alloc] initWithTimeIntervalSince1970:nowTime]; // sec->NSDate로 변환
                    nowDC = [calendar components:unitFlags fromDate:now]; // NSDate->NSDateComponents로 변환
                }
                //이제 요일번호가 같아졌다.(now에 시간이 들어있음)
                nowDC = [calendar components:unitFlags fromDate:now]; // NSDate->NSDateComponents로 변환
                [nowDC setHour:dueDC.hour];
                [nowDC setMinute:dueDC.minute];
                [nowDC setSecond:dueDC.second];
                now = [calendar dateFromComponents:nowDC];
                return now;
            }
            else {
                int duedateSec = dueDC.hour * 3600 + dueDC.minute * 60 + dueDC.second;
                int nowSec = nowDC.hour * 3600 + nowDC.minute * 60 + nowDC.second;
                if (duedateSec > nowSec) { //아직 예정시간을 지나지 않았다면
                    // 시분초만 맞추고 제출
                    nowDC = [calendar components:unitFlags fromDate:now];
                    [nowDC setHour:dueDC.hour];
                    [nowDC setMinute:dueDC.minute];
                    [nowDC setSecond:dueDC.second];
                    now = [calendar dateFromComponents:nowDC];
                    return now;
                }
                else {
                    
                    // 하루를 더한다.(요일번호가 달라짐)
                    NSTimeInterval nowTime = [now timeIntervalSince1970];
                    nowTime += (24 * 3600); // 하루 증가
                    now = [[NSDate alloc] initWithTimeIntervalSince1970:nowTime]; // sec->NSDate로 변환
                    nowDC = [calendar components:unitFlags fromDate:now]; // NSDate->NSDateComponents로 변환
                    
                    //요일번호가 동일해질 때까지 하루씩 넘김
                    while(dueDC.weekday != nowDC.weekday) {
                        NSTimeInterval nowTime = [now timeIntervalSince1970];
                        nowTime += (24 * 3600); // 하루 증가
                        now = [[NSDate alloc] initWithTimeIntervalSince1970:nowTime]; // sec->NSDate로 변환
                        nowDC = [calendar components:unitFlags fromDate:now]; // NSDate->NSDateComponents로 변환
                    }
                    //이제 요일번호가 같아졌다.(now에 시간이 들어있음)
                    nowDC = [calendar components:unitFlags fromDate:now]; // NSDate->NSDateComponents로 변환
                    [nowDC setHour:dueDC.hour];
                    [nowDC setMinute:dueDC.minute];
                    [nowDC setSecond:dueDC.second];
                    now = [calendar dateFromComponents:nowDC];
                    return now;
                }
            }
            break;
        }
        case REPEAT_MONTH: {
            NSDate * now = [dateNow copy];
            NSDateComponents *dueDC = [calendar components:unitFlags fromDate:item.duedate];
            NSDateComponents *nowDC = [calendar components:unitFlags fromDate:now];
            int secDay = 24 * 3600;
            int secHour = 3600;
            int secMinute = 60;

            int duedateSec  = dueDC.day * secDay + dueDC.hour * secHour + dueDC.minute * secMinute + dueDC.second;
            int nowSec      = nowDC.day * secDay + nowDC.hour * secHour + nowDC.minute * secMinute + nowDC.second;

            if (duedateSec > nowSec) { //아직 시간이 남아있다.
                NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:now];
                if (dayRange.length >= dueDC.day) {
                    [nowDC setDay:dueDC.day];
                }
                else {
                    [nowDC setDay:dayRange.length];
                }
                [nowDC setHour:dueDC.hour];
                [nowDC setMinute:dueDC.minute];
                [nowDC setSecond:dueDC.second];
                now = [calendar dateFromComponents:nowDC];
                return now;
            }
            else {
                //다음달로 가야한다.
                if (nowDC.month == 12) {
                    nowDC.month = 1;
                    int nextYear = nowDC.year + 1;
                    nowDC.year = nextYear;
                }
                else {
                    nowDC.month = (nowDC.month + 1);
                }
                
                //다음달이 며칠까지 있는지 알아낸다.
                NSLog(@"%d:%02d:%02d %02d:%02d:%02d", nowDC.year, nowDC.month, nowDC.day,
                      nowDC.hour, nowDC.minute, nowDC.second);
                nowDC.day = 1; //날짜가 크면 rangeOfUnit가 잘못나오는경우가 있으므로 초기화한다.(아래에서 제대로 설정 해준다.)
                now = [calendar dateFromComponents:nowDC];
                NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:now];
                NSLog(@"month=%d max=%d", nowDC.month, dayRange.length);
                if (dayRange.length >= dueDC.day) {
                    [nowDC setDay:dueDC.day];
                }
                else {
                    [nowDC setDay:dayRange.length];
                }
                
                [nowDC setHour:dueDC.hour];
                [nowDC setMinute:dueDC.minute];
                [nowDC setSecond:dueDC.second];
                now = [calendar dateFromComponents:nowDC];
                return now;
            }
            break;
        }
        
        default: {
            NSLog(@"not supported yet.");
            break;
        }
    }

    return nil;
}

-(void)schedule
{
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
    
    
    Item* scheduledItem = nil;
    NSDate* scheduleDate = nil;
    NSDate* date;
    
    NSLog(@"item count=%d", [_items count]);
    
    for (Item* item in _items) {
        NSDate *dateNow = [[NSDate alloc]init];
        date = [self recommend:item _dateNow:dateNow];
        {
            NSDateComponents *dueDateComponents = [calendar components:unitFlags fromDate:item.duedate];
            NSDateComponents *scheduledDateComponents = [calendar components:unitFlags fromDate:date];
            
            NSLog(@"dueDate=%d:%02d:%02d %02d:%02d:%02d scheduledDate=%d:%02d:%02d %02d:%02d:%02d",
                  dueDateComponents.year, dueDateComponents.month, dueDateComponents.day,
                  dueDateComponents.hour, dueDateComponents.minute, dueDateComponents.second,
                  scheduledDateComponents.year, scheduledDateComponents.month, scheduledDateComponents.day,
                  scheduledDateComponents.hour, scheduledDateComponents.minute, scheduledDateComponents.second);
        }
        if (date != nil) {
            if (scheduledItem == nil) {
                scheduleDate = date;
                scheduledItem = item;
            }
            else {
                if ([scheduleDate compare:date] == NSOrderedDescending) {
                    scheduleDate = date;
                    scheduledItem = item;
                }
            }
        }
    }
    
    NSDateComponents* dateComponents = [calendar components:unitFlags fromDate:scheduleDate];
    NSLog(@"scheduled date : %d:%02d:%02d %02d:%02d:%02d",
          dateComponents.year, dateComponents.month, dateComponents.day,
          dateComponents.hour, dateComponents.minute, dateComponents.second);
    
    if (scheduledItem != nil) {
        UILocalNotification *localNotif = [[UILocalNotification alloc]init];
        if (localNotif != nil) {
            //통지시간 
            localNotif.fireDate = scheduleDate;
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            
            //Payload
            localNotif.alertBody = [NSString stringWithFormat:@"%@", scheduledItem.title];
            localNotif.alertAction = @"상세보기";
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.applicationIconBadgeNumber = 1;
            
            //Custom Data
            NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"mypage" forKey:@"page"];
            localNotif.userInfo = infoDict;
            
            //Local Notification 등록
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
            
        }
    }
}

@end
