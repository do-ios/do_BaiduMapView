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
        [self setBackgroundColor:[UIColor clearColor]];
        _textInfoDict = textInfoDict;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_annotationImageView) {
        [_annotationImageView removeFromSuperview];
        _annotationImageView = nil;
    }
    if (_markerTextLabel) {
        [_annotationImageView removeFromSuperview];
        _markerTextLabel = nil;
    }
    _annotationImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _annotationImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_annotationImageView];
    [self addSubview:self.markerTextLabel];
}

#pragma  mark -lazy
- (UILabel *)markerTextLabel {
    if (_markerTextLabel == nil) {
        if (_textInfoDict != nil && _textInfoDict.allValues.count > 0) {
            _markerTextLabel = [[UILabel alloc] init];
            _markerTextLabel.text = _textInfoDict[@"text"];
            _markerTextLabel.font = _textInfoDict[@"textFont"];
            _markerTextLabel.textColor = _textInfoDict[@"textFontColor"];
            _markerTextLabel.backgroundColor = _textInfoDict[@"bgColor"];
            _markerTextLabel.layer.masksToBounds = true;
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
            float textHeight = _markerTextLabel.frame.size.height;
            float textWidth = _markerTextLabel.frame.size.width;
            float radius = ((NSNumber*)_textInfoDict[@"radius"]).floatValue;
            radius = textHeight < textWidth ? (radius > textHeight/2 ? textHeight/2 : radius) : (radius > textWidth/2 ? textWidth/2 :radius);
            _markerTextLabel.layer.cornerRadius = radius;
            return _markerTextLabel;
            
        }else {
            return [[UILabel alloc] init];
        }
    }
    return _markerTextLabel;
}

// 以图片下边沿中点为参考点添加的textMarker
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
                    x = self.bounds.size.width / 2.0;
                    y = self.bounds.size.height;
                    break;
                }
                case MarkerTextAlignYBottom: { // 左对齐 下对齐
                    x = self.bounds.size.width / 2.0;
                    y = self.bounds.size.height - height;
                    break;
                }
                case MarkerTextAlignYCenter: { // 左对齐 垂直居中对齐
                    x = self.bounds.size.width / 2.0;
                    y = self.bounds.size.height - height / 2.0;
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
                    x = self.bounds.size.width / 2.0 - width;
                    y = self.bounds.size.height;
                    break;
                }
                case MarkerTextAlignYBottom: { // 右对齐 下对齐
                    x = self.bounds.size.width / 2.0 - width;
                    y = self.bounds.size.height - height;
                    
                    break;
                }
                case MarkerTextAlignYCenter: { // 右对齐 垂直居中对齐
                    x = self.bounds.size.width / 2.0 - width;
                    y = self.bounds.size.height - height / 2.0;
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
                    y = self.bounds.size.height;
                    break;
                }
                case MarkerTextAlignYBottom: { // 水平居中对齐  下对齐
                    x = (self.bounds.size.width - width) / 2;
                    y = self.bounds.size.height - height;
                    break;
                }
                case MarkerTextAlignYCenter: { // 水平居中对齐 垂直居中对齐
                    x = (self.bounds.size.width - width) / 2;
                    y = self.bounds.size.height - height / 2;
                    
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
