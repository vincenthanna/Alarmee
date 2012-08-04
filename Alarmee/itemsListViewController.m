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
#import "ItemAddViewController.h"
#import "Item.h"
#import "db_access.h"

@implementation itemsListViewController

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
    
    NSString* str = [NSString stringWithFormat:@"%d Items", [_itemsArray count]];
    [self setTitle:str];
    
    _itemListTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    
    _itemListTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _itemListTableView.delegate = self;
    _itemListTableView.dataSource = self;
    [_itemListTableView reloadData];
    
    self.view = _itemListTableView;
    
    _itemViewController = [[itemViewController alloc]init];
    _itemAddViewController = [[ItemAddViewController alloc]init];
    
    
    // navigationController 상단 좌측버튼 구성(prev)
    {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Add"
                                     style:UIBarButtonItemStyleDone target:self action:@selector(addEntityViewOpen)];
        [self.navigationItem setLeftBarButtonItem:leftItem];
    }
    
    // navigationController 상단 우측 버튼 구성(next)
    {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editEntityViewOpen)];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
}

- (BOOL)isViewLoaded {
    [self loadData];
    return [super isViewLoaded];
}

-(void)loadData {
    _itemsArray = [self getAllItems];
    [_itemListTableView reloadData];
}

- (void)addEntityViewOpen
{
    [self.navigationController pushViewController:_itemAddViewController animated:YES];
}

- (void)editEntityViewOpen
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier_VH1981";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
   
    if (_itemsArray != nil) {
        Item *item = [_itemsArray objectAtIndex:indexPath.row];
        NSString* string = item.title;
        cell.textLabel.text = string;
    }
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // make new view & push
    [_itemViewController loadData:[_itemsArray objectAtIndex:indexPath.row]];
    [_itemViewController setOperatingMode:ItemViewMode_Apply];
    [self.navigationController pushViewController:_itemViewController animated:YES];
}

-(NSMutableArray*)getAllItems
{
    NSMutableArray *itemsArray = nil;   
    
    // open db    
    sqlite3 *database = NULL;
    DBAccessHelper *dbHelper = [[DBAccessHelper alloc] init];
    NSString *filePath = [dbHelper getDBFilePath];
    if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"[%s]%d db open fail!", __func__,__LINE__);
    }
    else {            
        sqlite3_stmt *selectStatement;            
        NSMutableString *selectSql = [[NSMutableString alloc]initWithFormat:@"SELECT * FROM %s", DB_TABLENAME];
        //NSLog(@"selectSql = %s", [selectSql UTF8String]);
        if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
            
            itemsArray = [[NSMutableArray alloc]init];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyyMMddHHmmss"]; // 시간이 이런 형식으로 저장되어 있다.
            NSString* timeString;
            NSDate* date;
            
            // while문을 돌면서 각 레코드의 데이터를 받아서 출력한다.
            while (sqlite3_step(selectStatement)==SQLITE_ROW) {
                
                Item* item = [[Item alloc]init];
                
                item.id = sqlite3_column_int(selectStatement, 0);
                item.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 1) ];
                item.todo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 2) ];
                
                timeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 3) ];
                date = [Item str2Date:timeString];
                item.adddate = date;
                
                timeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 4) ];
                date = [Item str2Date:timeString];
                item.duedate = date;
                
                item.repeat = sqlite3_column_int(selectStatement, 5);
                
                [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                /*
                NSLog(@"Items : id=%d title=%@ todo=%@ adddate=%@ duedate=%@ repeat=%d",
                      item.id, item.title, item.todo, 
                      [dateFormatter stringFromDate:item.adddate],
                      [dateFormatter stringFromDate:item.duedate],
                      item.repeat);
                 */
                
                [itemsArray addObject:item];
            }
        }
        else {
            NSLog(@"[%s]%d error!", __FUNCTION__, __LINE__);
        }
    }
    
    if (database != NULL) {
        //db close
        sqlite3_close(database);
        database = NULL;
    }    
    return itemsArray;    
}

@end
