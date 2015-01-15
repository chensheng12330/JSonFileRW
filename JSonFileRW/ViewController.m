//
//  ViewController.m
//  JSonFileRW
//
//  Created by sherwin on 15-1-15.
//  Copyright (c) 2015年 sherwin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self.activity setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - File Read

#define JF_tList (@"tList")
#define JF_cName (@"cName")

#define JF_topicid (@"topicid")
#define JF_alias (@"alias")
#define JF_subnum (@"subnum")
#define JF_img (@"img")
#define JF_cid (@"cid")
#define JF_tname (@"tname")
#define JF_ename (@"ename")
#define JF_tid (@"tid")


#define JF_topicid (@"topicid")
//#define JF_tList (@"")


-(void) jsonRead
{
    NSError *error =nil;
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"txt"]encoding:4 error:&error];
    
    if (jsonString==NULL ||  error!=NULL) {
        
        //SH_Alert(@"aaa");
        
        SHAlert(@"aa");
    }
    
    NSArray *arObj = [jsonString objectFromJSONString];
    
    
    NSMutableString *rssSql  = [NSMutableString string];
    NSMutableString *cateSql = [NSMutableString string];
    
   
    for (NSDictionary *dict  in arObj) {
        NSArray *arRSSObj = dict[JF_tList];
        
        for (NSDictionary *subDict in arRSSObj) {
            NSString *subrssSql = [self ComposRSSSqlForDict:subDict];
            [rssSql appendFormat:@"%@;\r\n",subrssSql];
        }
        
        
        NSString *subcateSql =[self ComposCategorySqlForCName:dict[JF_cName] cID:dict[JF_cid]];
        [cateSql appendFormat:@"%@;\r\n",subcateSql];
    }
    
    
    
    
    //输出
    
    NSString *rssSqlFile  = [SH_LibraryDir stringByAppendingPathComponent:@"rssSql.sql"];
    NSString *cateSqlFile = [SH_LibraryDir stringByAppendingPathComponent:@"cateSql.sql"];
    
    //清空
    [SH_FileMag removeItemAtPath:rssSqlFile  error:nil];
    [SH_FileMag removeItemAtPath:cateSqlFile error:nil];
    
    [rssSql writeToFile:rssSqlFile  atomically:YES encoding:4 error:nil];
    [cateSql writeToFile:cateSqlFile atomically:YES encoding:4 error:nil];
    
    
    NSLog(@"rssSqlFile=> %@",rssSqlFile);
    NSLog(@"cateSqlFile=> %@",cateSqlFile);
    return;
}

/*
 INSERT INTO `inews_category`(`id`, `cid`, `cName`) VALUES ([value-1],[value-2],[value-3])
 */

-(NSString*) ComposCategorySqlForCName:(NSString*) strName cID:(NSString*) strCID
{
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO `inews_category`(`cid`, `cName`) VALUES ('%@','%@')",strCID,strName];
    
    return sql;
}

/*
 INSERT INTO `inews_rss`(`tid`, `docid`, `cid`, `tname`, `ename`, `alias`, `imgsrc`, `ctime`, `ptime`, 'title', `subnum`) VALUES ('a','a','a','a','a','a','a','2009-06-08 23:53:17','2009-06-08 23:53:17','a',0)
 */
-(NSString*) ComposRSSSqlForDict:(NSDictionary*) info
{
    
    NSString *currentDateStr = [_dateFormatter stringFromDate:[NSDate date]];
    
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO `inews_rss`(`tid`, `docid`, `cid`, `tname`, `ename`, `alias`, `imgsrc`, `ctime`, `ptime`, `title`, `subnum`) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@',%@)",
                     info[JF_tid],
                     info[JF_topicid],
                     info[JF_cid],
                     info[JF_tname],
                     info[JF_ename],
                     info[JF_alias],
                     info[JF_img],
                     currentDateStr,
                     currentDateStr,
                     @" ",
                     @"0"
                     ];
    return sql;
}



#pragma mark - SH OnClick
- (IBAction)onGoJsonClick:(id)sender {
    
    [self.activity setHidden:NO];
    [self.activity startAnimating];
    [self.activity setHidesWhenStopped:YES];
    
    [self jsonRead];
    
    [self.activity setHidden:YES];
}
@end
