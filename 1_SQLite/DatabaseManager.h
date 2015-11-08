//
//  DatabaseManager.h
//  1_SQLite
//
//  Created by Zheng on 15/9/25.
//  Copyright © 2015年 Qingwu Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

@class Player;
@interface DatabaseManager : NSObject

+ (instancetype)sharedManager;

// 1.增加数据
- (BOOL)addPlayer:(Player *)player;

// 2.查询数据
- (NSArray *)queryAllPlayers;

- (NSArray *)queryPlayerWithName:(NSString *)name;

// 3.删除数据
- (BOOL)deletePlayer:(Player *)player;

// 4.修改数据
- (BOOL)updatePlayer:(Player *)player;

@end
