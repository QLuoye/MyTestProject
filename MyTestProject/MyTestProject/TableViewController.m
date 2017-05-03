//
//  TableViewController.m
//  MyTestProject
//
//  Created by TTT on 2017/5/2.
//  Copyright © 2017年 TTT. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"

#import <FMDB.h>
#import <sqlite3.h>

@interface Student : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;

@end

@implementation Student


@end

@interface TableViewController ()

@property (nonatomic, strong) NSMutableArray *arr;

@property (nonatomic, strong) NSString *filePath;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"List";
    
    // Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBtnClick:)];//:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addBtnClick:)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, addButtonItem];
//    _arr = [[NSMutableArray alloc] initWithArray:@[@1, @2, @3, @4, @5, @6, @7, @8]];
    
    [self createDBTable];
    
//    [self insertDB:@"张三" age:20];
//    [self insertDB:@"李四" age:21];
    
//    [self queryDB:@"SELECT * FROM t_student;" value:nil];
    _arr = [[self queryDB:@"SELECT * FROM t_student WHERE age>=?" value:@[@1]] mutableCopy];
    [self.tableView reloadData];
}

-(void)addBtnClick:(UIBarButtonItem *)barItem
{
    NSUInteger age = arc4random() % 99 + 1;
    NSArray *randomList = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    NSMutableString *stirng = [[NSMutableString alloc] init];
    for (int i = 0; i < 4; i++) {
        [stirng appendString:randomList[arc4random()%randomList.count]];
    }
    
    [self insertDB:stirng age:age];
    _arr = [[self queryDB:@"select * from t_student" value:nil] mutableCopy];
    [self.tableView reloadData];
    
//    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
//    [self.navigationController pushViewController:vc animated:YES];
}

-(void)createDBTable
{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _filePath = [doc stringByAppendingPathComponent:@"test.sqlite"];
    NSLog(@"%@", _filePath);
    
    FMDatabase *db = [FMDatabase databaseWithPath:_filePath];
    if ([db open]) {
        
//        BOOL result = [db executeUpdate:@"DROP TABLE IF EXISTS t_student"];
//        if (result) {
//            NSLog(@"删除表成功");
//        }
        
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student(id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL)"];
        if (!result) {
            NSLog(@"建表失败!!");
        }
        [db close];
    }
}

-(void)insertDB:(NSString *)name age:(NSUInteger)age
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_filePath];
    __block BOOL result = true;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSError *error = nil;
//        BOOL result;// = [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);", name, @(age)];
        result &= [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);" values:@[name, @(age)] error:&error];
//        result &= [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);" values:@[name, @(24)] error:&error];
//        result &= [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);" values:@[name, @(11)] error:&error];
//        result &= [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);" values:@[name, @(30)] error:&error];
        if (!result && error) {
            NSLog(@"数据插入失败 %@", error);
            *rollback = YES;
            return ;
        }
    }];
   
}

-(NSArray *)queryDB:(NSString *)sql value:(NSArray *)value
{
    FMDatabase *db = [FMDatabase databaseWithPath:_filePath];
    if ([db open]) {
        NSError *error = nil;
        FMResultSet *result = [db executeQuery:sql values:value error:&error];
        NSMutableArray *arr = [NSMutableArray array];
        while ([result next]) {
            Student *student = [[Student alloc] init];
    
            student.index = [result intForColumn:@"id"];
            student.name = [result stringForColumn:@"name"];
            student.age = [result intForColumn:@"age"];
            [arr addObject:student];
        }
        
        [db close];
        
        if (arr && !error) {
            return arr;
        }
        return nil;
    }
    return nil;
}

-(void)deleteDB:(NSString *)sql value:(NSArray *)values
{
//    FMDatabase *db = [FMDatabase databaseWithPath:_filePath];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_filePath];
    __block BOOL result = true;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSError *error = nil;
        result &= [db executeUpdate:sql values:values error:&error];
        if (result && error) {
            NSLog(@"%@", error);
            *rollback = YES;
            return ;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return _arr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    Student *student = _arr[indexPath.row];
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%ld %@ %ld", student.index, student.name, student.age];
//    cell.de.text = student.name;
//    cell.
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Student *student = _arr[indexPath.row];
//        int index = [resutlSet intForColumn:@"id"];
        [self deleteDB:@"delete from t_student where id=?" value:@[@(student.index)]];
        [_arr removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
//        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
