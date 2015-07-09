//
//  doIOHelper.h
//  DoCore
//
//  Created by 刘吟 on 14/12/3.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "doSourceFile.h"
#import "doIApp.h"

@interface doIOHelper : NSObject
#pragma mark -
+(NSString*) GetLocalFileFullPath:(id<doIApp>) _app :(NSString*) _targetFilePath;
//GetHttpUrlPath获取url的全路径
+(NSString*) GetLocalFileFullPath2:(doSourceFile*) _sourceFile : (NSString*) _targetFilePath;
//GetHttpUrlPath获取url的全路径
+ (NSString*) GetHttpUrlPath :(NSString*) _targetFilePath;
+ (NSString*) GetUTF8String:(NSData*) _src;
+ (NSString*) ReadUTF8File:(NSString*) _fileName;
+ (BOOL) ExistFile : (NSString*)  _fileFullName;
+ (BOOL) ExistDirectory : (NSString*)  _dirFullName;
+ (void) CreateDirectory :(NSString*) _directory;
+ (void) WriteAllBytes :(NSString*)_fileFullName :(NSData*) _content;
+(void) WriteAllText :(NSString*)_fileFullName :(NSString*) _content;
+ (NSString*)URLDecodedString:(NSString*)str;
+(void) DirectoryCopy:(NSString*) _srcDir :(NSString*) _targetDir;
+(void) FileCopy:(NSString*) _srcFile :(NSString*)_targetFile;
+(void) EncryptFile:(NSString*) _fileFullName :(NSString*) _fileData;
+ (NSString*) DecryptFile:(NSString*) _fileFullName;
@end
