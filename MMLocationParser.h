//
//  MMLocationParser.h
//  MMScanApp
//
//  Created by gyh on 2021/2/25.
//  Copyright © 2021 gyh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *
 * 如果输入为:  上海市浦东新区金科路2000号
 * 则输出：
 * province = 上海市
 * city         = 上海市
 * area       = 浦东新区
 * town      = nil
 * street     = 金科路2000号1006室
 * name     = 金科路2000号1006室
 * results   = [上海市, 浦东新区, 金科路2000号1006室]
 
 * 如果输入为:  安徽省黄山市歙县桂林镇竦口村188号
 * 则输出：
 * province = 安徽省
 * city         = 黄山市
 * area       = 歙县
 * town      = 桂林镇
 * street     = 竦口村188号
 * name     = 桂林镇竦口村188号
 * results   = [安徽省, 黄山市, 歙县, 桂林镇, 竦口村188号]
 *
 */
@interface MMLocationParser : NSObject

@property (nonatomic, readonly) NSString *province; //省、自治区、直辖市、特别行政区

@property (nonatomic, readonly) NSString *city;     //市、自治州、地区、行政单位

@property (nonatomic, readonly) NSString *area;     //区、县、旗、海域、岛

@property (nonatomic, readonly) NSString *town;     //乡、镇

@property (nonatomic, readonly) NSString *street;   //街道信息以及楼号、门牌号等

@property (nonatomic, readonly) NSString *name;     //乡镇 + 街道信息以及楼号、门牌号等

@property (nonatomic, readonly) NSArray  *results;  //列表的形式的返回 @[省, 市, 区(县), (镇), 街道]

/// 类构造方法
/// @param location 地址字符串 eg: 上海市浦东新区金科路2000号
+ (instancetype)parserWithLoation:(NSString *)location;

/// 构造方法
/// @param location 地址字符串 eg: 上海市浦东新区金科路2000号
- (instancetype)initWithLoation:(NSString *)location;


/// 批量解析
/// @param locations 地址列表
+ (NSArray<MMLocationParser *> *)parseList:(NSArray *)locations;

@end

NS_ASSUME_NONNULL_END
