//
//  doLogEngine.m
//  doText
//
//  Created by Doviceone on 15/4/7.
//  Copyright (c) 2015年 Doviceone. All rights reserved.
//

#define COUNT 4

#import "doLogEngine.h"

@implementation doLogEngine {
    NSMutableArray *_textArrays;
}

- (void)WriteDebug:(NSString *)_content {
    [self print:_content :NO];
    NSLog(@"debug%@",_content);
}

- (void)WriteError:(NSException *)_err :(NSString *)_desc, ... {
    NSString *errorStr =[NSString stringWithFormat:@"%@\n%@\n%@",_err.reason,_err.name,_err.userInfo.description];
    if(!_desc) {
        NSLog(@"exception:%@",errorStr);
        return;
    }
    va_list arglist;
    va_start(arglist, _desc);
    NSString *desc = [[NSString alloc] initWithFormat:_desc arguments:arglist];
    va_end(arglist);
    NSString *str = [NSString stringWithFormat:@"%@:%@",errorStr,desc];
    [self print:str :YES];
    NSLog(@"exception:%@",str);
}

- (void)setPrintView:(UITableView *)printView {
    self->_printView = printView;
    printView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _textArrays = [[NSMutableArray alloc] init];
    printView.delegate = self;
    printView.dataSource = self;
}

- (void)print:(NSString *)mess :(BOOL)isTrue {
    NSDate *sendDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
    if(isTrue) {
        [_textArrays addObject:[NSString stringWithFormat:@"Error@  %@  --  %@",[formatter stringFromDate:sendDate],mess]];
    }
    else {
        [_textArrays addObject:[NSString stringWithFormat:@"Debug@  %@  --  %@",[formatter stringFromDate:sendDate],mess]];
    }
    if(_textArrays.count > COUNT+2)
       [_textArrays removeObject:0];
    
    [self.printView reloadData];
    
    [self.printView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_textArrays.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

- (void) WritePerformance: (NSString *) _opt : (int) _time {
    
}

- (void)WriteInfo:(NSString *)_content :(NSString *)_tag {

}


#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.printView.frame.size.height/(COUNT-1);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _textArrays.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.printView.frame.size.width, self.printView.frame.size.height/(COUNT-1))];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.printView.frame.size.width, self.printView.frame.size.height/(COUNT-1))];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        label.backgroundColor = [UIColor clearColor];
        label.tag = COUNT*100;
//        label.font = [UIFont systemFontOfSize:8];
        [cell.contentView addSubview:label];
    }
    UILabel *label = (UILabel *)[cell viewWithTag:COUNT*100];
    NSString *str = _textArrays[indexPath.row];
    label.text = [str componentsSeparatedByString:@"@"][1];
    if([[str componentsSeparatedByString:@"@"][0] isEqualToString:@"Debug"]) {
        label.textColor = [UIColor blueColor];
    }
    else {
        label.textColor = [UIColor redColor];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
@end
