//
//  doLogEngine.h
//  doText
//
//  Created by Doviceone on 15/4/7.
//  Copyright (c) 2015年 Doviceone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "doILogEngine.h"

@interface doLogEngine : NSObject<doILogEngine,UITableViewDataSource,UITableViewDelegate>

-(void)WriteDebug:(NSString *)_content;
-(void)WriteError:(NSException *)_err :(NSString *)_desc, ...;

@property(nonatomic, strong)UITableView *printView;
@end
