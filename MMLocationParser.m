//
//  MMLocationParser.m
//  MMScanApp
//
//  Created by gyh on 2021/2/25.
//  Copyright © 2021 gyh. All rights reserved.
//

#import "MMLocationParser.h"

@interface MMLocationParser()

@property (nonatomic, copy) NSString *location;  //传入的内容

@property (nonatomic, copy) NSString *province;  //省、自治区、直辖市、特别行政区

@property (nonatomic, copy) NSString *city;      //市、自治州、地区、行政单位

@property (nonatomic, copy) NSString *area;      //区、县、旗、海域、岛

@property (nonatomic, copy) NSString *town;      //乡、镇

@property (nonatomic, copy) NSString *street;    //街道信息以及楼号、门牌号等

@property (nonatomic, copy) NSString *name;     //乡镇 + 街道信息以及楼号、门牌号等

@property (nonatomic, strong) NSArray *results;   //列表的形式的返回 @[省, 市, 区(县), 乡(镇), 街道]

@end

@implementation MMLocationParser

/// 类构造方法
/// @param location 地址字符串 eg: 上海市浦东新区金科路2000号
+ (instancetype)parserWithLoation:(NSString *)location {
    MMLocationParser *parser = [[MMLocationParser alloc] initWithLoation:location];
    return parser;
}

/// 构造方法
/// @param location 地址字符串 eg: 上海市浦东新区金科路2000号
- (instancetype)initWithLoation:(NSString *)location {
    self = [super init];
    if (self) {
        self.location = location;
        self.results  = [self executeParserList];
        self.province = [self parserProvince];
        self.city     = [self parserCity];
        self.area     = [self parserArea];
        self.town     = [self parserTown];
        self.street   = [self parserStreet];
        self.name     = [self.town?:@"" stringByAppendingString:self.street?:@""];
    }
    return self;
}


/// 解析省份
- (NSString *)parserProvince {
    NSString *pattern = @"^.*?省|.*?自治区|.*?行政区|.*?市";
    return [self matchWithPattern:pattern];
}


/// 解析城市
- (NSString *)parserCity {
    NSString *pattern = @"^.*?市|.*?自治州|.*?地区|.*?行政单位";
    NSString *result = [self matchWithPattern:pattern];
    if (![result isEqualToString:[self province]]) {
        result = [result stringByReplacingOccurrencesOfString:[self province] withString:@""];
    }
    return result;
}

/// 解析区县
- (NSString *)parserArea {
    //区分 -> [自治区、 行政区 ] => [区]，所以还是多次匹配 `.*?区` ，取最后一条
    NSString *pattern = @"^.*?区|.*?区|.*?县|.*?旗|.*?海域|.*?岛";
    NSString *result = [self matchWithPattern:pattern];
    if ([self province] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self province] withString:@""];
    }
    if ([self city] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self city] withString:@""];
    }
    
    return result;
}

/// 解析乡镇
- (NSString *)parserTown {
    NSString *pattern = @"^.*?镇|.*?乡";
    NSString *result = [self matchWithPattern:pattern];
    if ([self province] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self province] withString:@""];
    }
    if ([self city] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self city] withString:@""];
    }
    
    if ([self area] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self area] withString:@""];
    }
    
    return result;
}

/// 解析街道
- (NSString *)parserStreet {
    NSString *result = self.location;
    if ([self province] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self province] withString:@""];
    }
    if ([self city] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self city] withString:@""];
    }
    if ([self area] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self area] withString:@""];
    }
    
    if ([self town] != nil) {
        result = [result stringByReplacingOccurrencesOfString:[self town] withString:@""];
    }
    
    return result;
}

/// 正则表达式一次匹配
/// @param pattern 正则表达式String
- (NSString *)matchWithPattern:(NSString *)pattern {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options: NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regex matchesInString:self.location options:0 range:NSMakeRange(0, self.location.length)];
    if (results.count > 0) {
        NSTextCheckingResult *result = results.lastObject;
        //一次匹配难以区分 -> [自治区、 行政区 ] => [区]，所以还是多次匹配，取最后一条
//        NSTextCheckingResult *result = [regex firstMatchInString:self.location options:0 range:NSMakeRange(0, self.location.length)];
        if (result) {
            if (result.range.length > 0) {
                return [self.location substringWithRange:result.range];
            }
        }
    }
    return nil;
}


/// 解析列表
- (NSArray *)executeParserList {
    NSString *pattern = @"^(.*?省|.*?自治区|.*?行政区|.*?市)|(.*?市|.*?自治州|.*?地区|.*?行政单位)|(.*?区|.*?县|.*?旗|.*?海域|.*?岛|.*?镇)|.*";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options: NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:self.location options:0 range:NSMakeRange(0, self.location.length)];
    
    if (result.count) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i<result.count; i++) {
            NSTextCheckingResult *res = result[i];
            if (res.range.length > 0) {
                NSString *matchStr = [self.location substringWithRange:res.range];
                [array addObject:matchStr];
            }
        }
        
        return array.mutableCopy;
    } else {
        NSLog(@"error == %@",error.description);
    }
    return nil;
}


+ (NSArray<MMLocationParser *> *)parseList:(NSArray *)locations {
    NSMutableArray *parsers = [NSMutableArray array];
    for (NSString *location in locations) {
        [parsers addObject:[MMLocationParser parserWithLoation:location]];
    }
    return parsers.mutableCopy;
}

@end
