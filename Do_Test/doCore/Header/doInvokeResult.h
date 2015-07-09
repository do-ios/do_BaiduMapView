//
//  doInvokeResult.h
//  DoCore
//
//  Created by 刘吟 on 14/11/16.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface doInvokeResult : NSObject
{
@private
    NSMutableDictionary * currentResult;
}
-(id) init:(NSString*) _sender;

#pragma mark -
- (void) SetResultText: (NSString *) _value;
- (void) SetResultNode: (NSDictionary *) _value;
- (void) SetResultInteger: (int) _value;
- (void) SetResultFloat: (double) _value;
- (void) SetResultArray: (NSMutableArray *) _value;
- (void) SetResultBoolean: (BOOL) _value;
- (void) SetResultValue: (id) _value;
- (void) SetCallbackName: (NSString *) _callbackName;
- (void) SetError: (NSString *) _message;
- (void) SetException: (NSException *)_err;
- (NSString *)GetResult;
- (void) SetEventData: (NSString *) _value;
@end