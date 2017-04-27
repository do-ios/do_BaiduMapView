//
//  MyAnimatedAnnotationView.m
//  IphoneMapSdkDemo
//
//  Created by wzy on 14-11-27.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "MyAnimatedAnnotationView.h"
//alignX: left(左对齐) right(右对齐) center(水平居中对齐)
typedef NS_ENUM(NSInteger, MarkerTextAlignX) {
    MarkerTextAlignXLeft, // left(左对齐)
    MarkerTextAlignXRight, // right(右对齐)
    MarkerTextAlignXCenter // center(水平居中对齐)
};
//alignY: top(上对齐) bottom(下对齐)  center(垂直居中对齐)
typedef NS_ENUM(NSInteger, MarkerTextAlignY) {
    MarkerTextAlignYTop, // top(上对齐)
    MarkerTextAlignYBottom, // bottom(下对齐)
    MarkerTextAlignYCenter // center(垂直居中对齐)
};
@interface MyAnimatedAnnotationView()
@property (nonatomic, strong) NSDictionary *textInfoDict;
@property (nonatomic, strong) UILabel *markerTextLabel;
@end

@implementation MyAnimatedAnnotationView

@synthesize annotationImageView = _annotationImageView;
@synthesize annotationImages = _annotationImages;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier textInfoDict:(NSDictionary *)textInfoDict {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        //        [self setBounds:CGRectMake(0.f, 0.f, 30.f, 30.f)];
        [self setBounds:CGRectMake(0.f, 0.f, 32.f, 32.f)];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _annotationImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _annotationImageView.contentMode = UIViewContentModeScaleAspectFill;
        _annotationImageView.clipsToBounds = true;
        _textInfoDict = textInfoDict;
        
        [self addSubview:_annotationImageView];
        [self addSubview:self.markerTextLabel];
        self.layer.masksToBounds = false;
    }
    return self;
}


- (void)setAnnotationImages:(NSMutableArray *)images {
    _annotationImages = images;
    [self updateImageView];
}

- (void)updateImageView {
    if ([_annotationImageView isAnimating]) {
        [_annotationImageView stopAnimating];
    }
    
    
    _annotationImageView.animationImages = _annotationImages;
    _annotationImageView.animationDuration = 0.5 * [_annotationImages count];
    _annotationImageView.animationRepeatCount = 0;
    [_annotationImageView startAnimating];
}

#pragma  mark -lazy
- (UILabel *)markerTextLabel {
    if (_markerTextLabel == nil) {
        if (_textInfoDict != nil && _textInfoDict.allValues.count > 0) {
            _markerTextLabel = [[UILabel alloc] init];
            _markerTextLabel.text = _textInfoDict[@"text"];
            _markerTextLabel.font = _textInfoDict[@"textFont"];
            _markerTextLabel.textColor = _textInfoDict[@"textFontColor"];
            _markerTextLabel.textAlignment = NSTextAlignmentCenter;
            
            // 对齐方式
            NSString *alignX = _textInfoDict[@"alignX"];
            NSString *alignY = _textInfoDict[@"alignY"];
            
            MarkerTextAlignX markerTextAlignX = MarkerTextAlignXCenter;
            if ([alignX isEqualToString:@"left"]) {
                markerTextAlignX = MarkerTextAlignXLeft;
            }else if ([alignX isEqualToString:@"right"]) {
                markerTextAlignX = MarkerTextAlignXRight;
            }else if ([alignX isEqualToString:@"center"]){
                markerTextAlignX = MarkerTextAlignXCenter;
            }
            MarkerTextAlignY markerTextAlignY = MarkerTextAlignYCenter;
            if ([alignY isEqualToString:@"top"]) {
                markerTextAlignY = MarkerTextAlignYTop;
            }else if ([alignY isEqualToString:@"bottom"]) {
                markerTextAlignY = MarkerTextAlignYBottom;
            }else if ([alignY isEqualToString:@"center"]) {
                markerTextAlignY = MarkerTextAlignYCenter;
            }
            [_markerTextLabel sizeToFit];
            CGSize fontSize = _markerTextLabel.frame.size;
            _markerTextLabel.frame = [self markerTextFrameWithAlignX:markerTextAlignX alignY:markerTextAlignY fontSize:fontSize];
            return _markerTextLabel;
            
        }else {
            return [[UILabel alloc] init];
        }
    }
    return _markerTextLabel;
}

- (CGRect)markerTextFrameWithAlignX:(MarkerTextAlignX)alignX alignY:(MarkerTextAlignY)alignY fontSize:(CGSize)fontSize {
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat width = fontSize.width;
    CGFloat height = fontSize.height;
    
    // left(左对齐) right(右对齐) center(水平居中对齐) alignX
    // top(上对齐) bottom(下对齐)  center(垂直居中对齐) alignY
    switch (alignX) {
        case MarkerTextAlignXLeft:{
            switch (alignY) {
                case MarkerTextAlignYTop: { // 左对齐 上对齐
                    x = self.bounds.size.width;
                    y = 0;
                    break;
                }
                case MarkerTextAlignYBottom: { // 左对齐 下对齐
                    x = self.bounds.size.width;
                    y = self.bounds.size.height - height;
                    break;
                }
                case MarkerTextAlignYCenter: { // 左对齐 垂直居中对齐
                    x = self.bounds.size.width;
                    y = (self.bounds.size.height - height) / 2.0;
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case MarkerTextAlignXRight:{
            switch (alignY) {
                case MarkerTextAlignYTop: { // 右对齐  上对齐
                    x = - self.bounds.size.width;
                    y = 0;
                    break;
                }
                case MarkerTextAlignYBottom: { // 右对齐 下对齐
                    x = - self.bounds.size.width;
                    y = self.bounds.size.height - height;
                    
                    break;
                }
                case MarkerTextAlignYCenter: { // 右对齐 垂直居中对齐
                    x = - self.bounds.size.width;
                    y = (self.bounds.size.height - height) / 2.0;
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case MarkerTextAlignXCenter:{
            switch (alignY) {
                case MarkerTextAlignYTop: { // 水平居中对齐 上对齐
                    x = (self.bounds.size.width - width) / 2;
                    y = 0;
                    break;
                }
                case MarkerTextAlignYBottom: { // 水平居中对齐  下对齐
                    x = (self.bounds.size.width - width) / 2;
                    y = self.bounds.size.height - height;
                    
                    break;
                }
                case MarkerTextAlignYCenter: { // 水平居中对齐 垂直居中对齐
                    x = (self.bounds.size.width - width) / 2;
                    y = (self.bounds.size.height - height) / 2.0;
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return CGRectMake(x, y, width, height);
}


@end
