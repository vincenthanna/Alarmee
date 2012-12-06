//
//  itemsListViewController.h
//  Alarmee
//
//  Created by 김 연희 on 12. 2. 28..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

    
#import <UIKit/UIKit.h>
#import "itemViewController.h"
#import "PreferenceViewController.h"

/* 메인 창, 아이템들을 listView로 보여준다. */
@interface itemsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView* _itemListTableView;
    itemViewController* _itemViewController;
    PreferenceViewController* _preferenceViewController;
    NSMutableArray *_itemsArray;
    int dbStateId;
}

@property (nonatomic,retain) UITableView* _itemListTableView;

-(void)update:(NSNotification *)notification;

@end
