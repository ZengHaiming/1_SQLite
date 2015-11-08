//
//  Player.h
//  1_SQLite
//
//  Created by Zheng on 15/9/25.
//  Copyright © 2015年 Qingwu Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property(nonatomic, assign) int playerID;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) float height;
@property(nonatomic, assign) NSInteger number;
@property(nonatomic, copy) NSString *team;

@end
