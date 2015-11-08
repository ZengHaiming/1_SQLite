//
//  DatabaseManager.m
//  1_SQLite
//
//  Created by Zheng on 15/9/25.
//  Copyright © 2015年 Qingwu Zheng. All rights reserved.
//

#import "DatabaseManager.h"

#import "Player.h"

sqlite3 *sqlite = nil;

@implementation DatabaseManager
static DatabaseManager *instance = nil;

+ (instancetype)sharedManager {

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[DatabaseManager alloc] init];
    [instance copyDBFileToSandbox];
  });
  return instance;
}

//复制数据库文件到沙盒路径
- (void)copyDBFileToSandbox {

  NSString *atPath =
      [[NSBundle mainBundle] pathForResource:@"mydatabase" ofType:@"sqlite"];

  NSString *toPath = [self dbFileName];

  //如果文件不存在，才复制文件
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:toPath]) {
    return;
  }

  //复制文件
  [fileManager copyItemAtPath:atPath toPath:toPath error:NULL];
}

//数据库文件路径
- (NSString *)dbFileName {
  return
      [NSHomeDirectory() stringByAppendingString:@"/Documents/playerdb.sqlite"];
}

// 1.增加数据
- (BOOL)addPlayer:(Player *)player {

  NSString *filename = [self dbFileName];
  //(1)打开数据库
  int openResult = sqlite3_open([filename UTF8String], &sqlite);
  if (openResult != SQLITE_OK) {
    NSLog(@"打开数据库失败");

    sqlite3_close(sqlite);

    return NO;
  }

  //(2)准备SQL语句

  //  NSString *statement = [NSString stringWithFormat:@"INSERT INTO Player (id,
  //  name) VALUES (%ld, \'%@\')", player.playerID, player.name];
  //参数绑定
  NSString *statement = @"INSERT INTO Player (id, name) VALUES (?, ?)";

  //先准备SQL语句
  //准备好的语句
  sqlite3_stmt *stmt = nil;

  /*
   准备SQL函数
   SQLITE_API int SQLITE_STDCALL sqlite3_prepare_v2(
    sqlite3 *db,            处理数据库的句柄
    const char *zSql,       SQL语句
    int nByte,              编译之后的代码的最大长度 -1表示不限制长度
    sqlite3_stmt **ppStmt,  准备好的语句
    const char **pzTail     尾巴（指向字符串最后的一个指针）
   );
   */
  sqlite3_prepare_v2(sqlite, [statement UTF8String], -1, &stmt, NULL);

  //再做参数绑定
  //第二个参数表示要绑定的是第几个参数， 第三个参数是要绑定的值
  sqlite3_bind_int(stmt, 1, player.playerID);
  sqlite3_bind_text(stmt, 2, [player.name UTF8String], -1, NULL);
  //最后的函数指针，绑定过程中调用的函数

  //(3)执行语句
  int stepResult = sqlite3_step(stmt);
  if (stepResult != SQLITE_DONE && stepResult != SQLITE_OK) {
    NSLog(@"语句执行失败");

    sqlite3_finalize(stmt);

    sqlite3_close(sqlite);

    return NO;
  }

  //(4)完结SQL语句
  sqlite3_finalize(stmt);

  //(5)关闭连接
  sqlite3_close(sqlite);

  return YES;
}

// 4.查询数据
- (NSArray *)queryAllPlayers {

  NSMutableArray *array = [NSMutableArray array];

  NSString *filename = [self dbFileName];

  //(1)打开数据库
  int openResult = sqlite3_open([filename UTF8String], &sqlite);
  if (openResult != SQLITE_OK) {
    NSLog(@"打开数据库失败");
    sqlite3_close(sqlite);
    return nil;
  }

  //(2)准备
  NSString *statement = @"SELECT * FROM Player";

  sqlite3_stmt *stmt = nil;

  sqlite3_prepare_v2(sqlite, [statement UTF8String], -1, &stmt, NULL);

  //(3)执行
  int stepResult = sqlite3_step(stmt);
  // SQLITE_ROW //每查询出一条数据，返回一个row
  while (stepResult == SQLITE_ROW) {
    //一条数据 --> Player --> Array
    int playerID = sqlite3_column_int(stmt, 0); //第二参数表示第几列
    const char *name = (const char *)sqlite3_column_text(stmt, 1);
    float height = sqlite3_column_double(stmt, 2);

    Player *p = [[Player alloc] init];
    p.playerID = playerID;
    p.name = [NSString stringWithUTF8String:name];
    p.height = height;

    [array addObject:p];

    stepResult = sqlite3_step(stmt);
  }
  //如果没有查询出的数据，stepResult=101 SQLITE_DONE

  //(4)完结
  sqlite3_finalize(stmt);

  //(5)关闭
  sqlite3_close(sqlite);

  return array;
}

- (NSArray *)queryPlayerWithName:(NSString *)name {
  NSMutableArray *array = [NSMutableArray array];

  NSString *filename = [self dbFileName];

  //(1)打开数据库
  int openResult = sqlite3_open([filename UTF8String], &sqlite);
  if (openResult != SQLITE_OK) {
    NSLog(@"打开数据库失败");
    sqlite3_close(sqlite);
    return nil;
  }

  //(2)准备
  NSString *statement = @"SELECT * FROM Player WHERE name = ?";

  sqlite3_stmt *stmt = nil;

  sqlite3_prepare_v2(sqlite, [statement UTF8String], -1, &stmt, NULL);

  // bind
  sqlite3_bind_text(stmt, 1, [name UTF8String], -1, NULL);

  //(3)执行
  int stepResult = sqlite3_step(stmt);
  // SQLITE_ROW //每查询出一条数据，返回一个row
  while (stepResult == SQLITE_ROW) {
    //一条数据 --> Player --> Array
    int playerID = sqlite3_column_int(stmt, 0); //第二参数表示第几列
    const char *name = (const char *)sqlite3_column_text(stmt, 1);
    float height = sqlite3_column_double(stmt, 2);
    int64_t number = sqlite3_column_int64(stmt, 3);
    const char *team = (const char *)sqlite3_column_text(stmt, 4);

    Player *p = [[Player alloc] init];
    p.playerID = playerID;
    p.name = [NSString stringWithUTF8String:name];
    p.height = height;
    p.number = number;
      if (team) {
          
          p.team = [NSString stringWithUTF8String:team];
      }

    [array addObject:p];

    stepResult = sqlite3_step(stmt);
  }
  //如果没有查询出的数据，stepResult = 101 SQLITE_DONE

  //(4)完结
  sqlite3_finalize(stmt);

  //(5)关闭
  sqlite3_close(sqlite);

  return array;
}

// 3.删除数据
- (BOOL)deletePlayer:(Player *)player {
  NSString *filename = [self dbFileName];
  //(1)打开数据库
  int openResult = sqlite3_open([filename UTF8String], &sqlite);
  if (openResult != SQLITE_OK) {
    NSLog(@"打开数据库失败");
    sqlite3_close(sqlite);
    return NO;
  }

  //(2)准备SQL语句
  NSString *statement = @"DELETE FROM Player WHERE id = ?";
  sqlite3_stmt *stmt = nil;
  sqlite3_prepare_v2(sqlite, [statement UTF8String], -1, &stmt, NULL);

  //参数绑定
  sqlite3_bind_int(stmt, 1, player.playerID);

  //(3)执行语句
  int stepResult = sqlite3_step(stmt);
  if (stepResult != SQLITE_DONE && stepResult != SQLITE_OK) {
    NSLog(@"语句执行失败");
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    return NO;
  }

  //(4)完结SQL语句
  sqlite3_finalize(stmt);

  //(5)关闭连接
  sqlite3_close(sqlite);

  return YES;
}

// 4.修改数据
- (BOOL)updatePlayer:(Player *)player {

  NSString *filename = [self dbFileName];

  //(1)打开数据库
  int openResult = sqlite3_open([filename UTF8String], &sqlite);
  if (openResult != SQLITE_OK) {
    NSLog(@"打开数据库失败");
    sqlite3_close(sqlite);
    return NO;
  }

  //(2)准备SQL语句
  //参数绑定
  NSString *statement = @"UPDATE Player SET name = ?, height = ?, number = ?,team = ? WHERE id = ?";
  sqlite3_stmt *stmt = nil;
  sqlite3_prepare_v2(sqlite, [statement UTF8String], -1, &stmt, NULL);

  //绑定参数
  sqlite3_bind_text(stmt, 1, [player.name UTF8String], -1, NULL);
  sqlite3_bind_double(stmt, 2, player.height);
  sqlite3_bind_int64(stmt, 3, player.number);
  sqlite3_bind_text(stmt, 4, [player.team UTF8String], -1, NULL);
  sqlite3_bind_int(stmt, 5, player.playerID);

  //(3)执行语句
  int stepResult = sqlite3_step(stmt);
  if (stepResult != SQLITE_DONE && stepResult != SQLITE_OK) {
    NSLog(@"语句执行失败");
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    return NO;
  }

  //(4)完结SQL语句
  sqlite3_finalize(stmt);

  //(5)关闭连接
  sqlite3_close(sqlite);

  return YES;
}

@end
