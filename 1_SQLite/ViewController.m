//
//  ViewController.m
//  1_SQLite
//
//  Created by Zheng on 15/9/25.
//  Copyright © 2015年 Qingwu Zheng. All rights reserved.
//

#import "ViewController.h"

#import <sqlite3.h>

#import "DatabaseManager.h"
#import "Player.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSLog(@"%@", NSHomeDirectory());

  //创建一个数据库文件，添加一个数据表
  //[self createDatabase];

  Player *p1 = [[Player alloc] init];
  p1.playerID = 3;
  p1.name = @"Curry";

  DatabaseManager *manager = [DatabaseManager sharedManager];
  //增加数据
  [manager addPlayer:p1];

  //查询所有数据
  // NSArray *players = [manager queryAllPlayers];

  //查询
  NSArray *player = [manager queryPlayerWithName:@"Yaoming"];

  Player *yaoming = [player lastObject];

  //查询之后删除数据
  //[manager deletePlayer:yaoming];

  //查询之后更新数据
  yaoming.number = 12;
  yaoming.team = @"Rockets";

  [manager updatePlayer:yaoming];
       NSArray* arr=[manager queryAllPlayers];
    NSLog(@"%@",arr);
    NSLog(@"%@",@"这是添加的一行");
    NSLog(@"我查了");
}

- (void)createDatabase {
  NSLog(@"%@", NSHomeDirectory());

  //操作数据库的句柄对象
  sqlite3 *sqlite = nil;

  // 1.数据库文件路径
  NSString *dbPath =
      [NSHomeDirectory() stringByAppendingString:@"/Documents/database.db"];

  // 2.打开数据库（建立和数据库的连接）
  //(1)如果存在，直接打开 （2）如果不存在，先创建，再打开
  /*
   SQLITE_API int SQLITE_STDCALL sqlite3_open(
   const char *filename    数据库文件名（）
   sqlite3 **ppDb          数据库处理句柄
   );
   */
  int result =
      sqlite3_open([dbPath UTF8String], &sqlite); // a Pointer to Pointer
  if (result != SQLITE_OK) {
    NSLog(@"打开数据库失败");
    return;
  }

  // 3.创建表
  // CREATE TABLE Player (id integer PRIMARY KEY UNIQUE,name text NOT
  // NULL,height float DEFAULT 1.80,number integer DEFAULT 0,team text)
  NSString *statement = @"CREATE TABLE Player (id integer PRIMARY KEY "
      @"UNIQUE,name text NOT NULL,height float DEFAULT "
      @"1.80,number integer DEFAULT 0,team text)";
  //准备SQL语句
  //执行SQL语句
  //语句完结
  /*
     SQLITE_API int SQLITE_STDCALL sqlite3_exec(
      sqlite3*,                                  数据库对象
      const char *sql,                           要执行的语句
      int (*callback)(void*,int,char**,char**),  回调函数
      void *,                                    回调函数中的第一个参数
      char **errmsg                              错误信息
    );
   */
  char *error = NULL;
  int execResult =
      sqlite3_exec(sqlite, [statement UTF8String], NULL, NULL, &error);
  if (execResult != SQLITE_OK) {
    NSLog(@"执行创建数据表的语句失败");
  }

  // 4.关闭数据库
  sqlite3_close(sqlite);
}

@end
