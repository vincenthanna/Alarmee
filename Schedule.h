//
//  Schedule.h
//  Alarmee
//
//  Created by 연희 김 on 12. 8. 6..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Schedule : NSObject
{
    NSMutableArray *_items;
}

-(NSDate*)recommend:(Item*)item _dateNow:(NSDate*)dateNow;
-(void)schedule;

@property (nonatomic, retain)NSMutableArray *_items;

@end
