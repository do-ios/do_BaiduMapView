//
//  doJsonHelper.h
//  DoCore
//
//  Created by 刘吟 on 14/12/3.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "doIListData.h"
@interface doJsonHelper : NSObject
+ (id)GetOneValue: (NSDictionary*) _obj :(NSString*)_name;

+(int) GetInteger:(id) _obj : (int) _defalutValue;
+ (int)GetOneInteger: (NSDictionary*) _obj :(NSString*)_name :(int)_defaultValue;

+(float) GetFloat:(id) _obj : (float) _defalutValue;
+ (float)GetOneFloat: (NSDictionary*) _obj :(NSString*)_name :(float)_defaultValue;

+(NSString*) GetText:(id) _obj : (NSString*) _defalutValue;
+ (NSString*)GetOneText: (NSDictionary*) _obj :(NSString*)_name :(NSString*)_defaultValue;

+(BOOL) GetBoolean:(id) _obj : (BOOL) _defalutValue;
+ (BOOL)GetOneBoolean: (NSDictionary*) _obj :(NSString*)_name :(BOOL)_defaultValue;

+(NSDictionary*)GetNode:(id) _obj;
+ (NSDictionary*)GetOneNode: (NSDictionary*) _obj :(NSString*)_name;

+(NSArray*)GetArray:(id) _obj;
+ (NSArray*)GetOneArray: (NSDictionary*) _obj :(NSString*)_name;

+ (NSString *)ExportToText:(id)theData :(BOOL)_indented;
+(id)LoadDataFromText:(NSString*)_text;

+(id) GetJsonValue:(id) _rootValue : (NSString*) _dataPath;
@end
