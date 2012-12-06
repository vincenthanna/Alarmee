//
//  itemsListViewController.m
//  Alarmee
//
//  Created by 김 연희 on 12. 2. 28..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import "vh1981AppDelegate.h"
#import "itemsListViewController.h"
#import "itemViewController.h"
#import "Item.h"
#import "db_access.h"
#import "Schedule.h"

@implementation itemsListViewController
@synthesize _itemListTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [self loadData];
    
    dbStateId = 0;
    
    NSString* str = [NSString stringWithString:NSLocalizedString(@"List", nil)];
    [self setTitle:str];
    
    _itemListTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    _itemListTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _itemListTableView.delegate = self;
    _itemListTableView.dataSource = self;
    [_itemListTableView reloadData];
    
    self.view = _itemListTableView;
    
    _itemViewController = [[itemViewController alloc]init];
    _preferenceViewController = [[PreferenceViewController alloc]init];
    
    // navigationController 상단 좌측버튼 구성(prev)
    {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"Add", nil)
                                     style:UIBarButtonItemStyleDone target:self action:@selector(addEntityViewOpen)];
        [self.navigationItem setLeftBarButtonItem:leftItem];
    }
    
    // navigationController 상단 우측 버튼 구성(next)
    {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]
                                      initWithTitle:NSLocalizedString(@"Preference", nil)
                                      style:UIBarButtonItemStyleDone target:self action:@selector(preferenceViewOpen)];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:@"reloadItemList" object:nil];
}

-(void)loadData {
    DBAccessHelper *dbHelper = ((vh1981AppDelegate *)[[UIApplication sharedApplication] delegate]).dbHelper;

    _itemsArray = [dbHelper getAllItems];
    
    // badge number를 갱신한다.
    int badgeNumber = 0;
    for (Item* item in _itemsArray) {
        if (item.scheduledCount > 0) {
            badgeNumber++;
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
    
    // item 목록 갱신.
    [_itemListTableView reloadData];
   
    /*
    // db 상태가 변경됬을때만 local notification을 갱신한다.
    if (dbStateId != dbHelper.stateId) {
        [Schedule scheduleAll:_itemsArray];
        dbStateId = dbHelper.stateId;
    }
     */
}

- (void)addEntityViewOpen
{
    [_itemViewController loadData:[[Item alloc]init]];
    [_itemViewController setOperatingMode:ItemViewMode_New];
    [self.navigationController pushViewController:_itemViewController animated:YES];

}

- (void)preferenceViewOpen
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration: 0.7];
    [self.navigationController pushViewController: _preferenceViewController animated:NO]; 
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO]; 
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemsArray count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    Region *region = [regions objectAtIndex:section];
    return [region name];
}
*/

#pragma mark -
#pragma mark Table View Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier_VH1981";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
   
    if (_itemsArray != nil) {
        Item *item = [_itemsArray objectAtIndex:indexPath.row];
        NSString* string = item.title;
        [cell.textLabel setText:string];
        int state = [item getScheduledStatus];
        
        if (state == SCHED_DONE) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (item.status == STAT_ACTIVE) {
            [cell.textLabel setTextColor:[UIColor blackColor]];
        }
        else {            
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
        
        NSLog(@"row[%02d] state=%s", indexPath.row, state==SCHED_DONE ? "SCHED_DONE" : "SCHED_WAITING");
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Item* item = [_itemsArray objectAtIndex:indexPath.row];
    DBAccessHelper *dbHelper = ((vh1981AppDelegate *)[[UIApplication sharedApplication] delegate]).dbHelper;
    
    if ([item getScheduledStatus] == SCHED_DONE) { // 다음 스케줄 시간을 업데이트 해야 한다.
        [Schedule schedule:item];
        [dbHelper addNewItem:item isExists:1];
    }
    
    // itemView로 이동한다.
    [_itemViewController loadData:[_itemsArray objectAtIndex:indexPath.row]];
    [_itemViewController setOperatingMode:ItemViewMode_Apply];
    [self.navigationController pushViewController:_itemViewController animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    [tableView beginUpdates];    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Do whatever data deletion you need to do...
        // Delete the row from the data source

        DBAccessHelper *dbHelper = ((vh1981AppDelegate *)[[UIApplication sharedApplication] delegate]).dbHelper;
        if ([dbHelper deleteItem:[_itemsArray objectAtIndex:indexPath.row]] != TRUE) {
            NSLog(@"[%s]%d Error!", __func__,__LINE__);
        }
        [_itemsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:YES];      
    }       
    [tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)update:(NSNotification *)notification
{
    NSLog(@"[%s]%d item notification", __FUNCTION__,__LINE__);
//    DBAccessHelper *dbHelper = ((vh1981AppDelegate *)[[UIApplication sharedApplication] delegate]).dbHelper;
//    _itemsArray = [dbHelper getAllItems];
    [_itemListTableView reloadData];
}

@end
