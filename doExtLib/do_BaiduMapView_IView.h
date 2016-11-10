//
//  do_BaiduMapView_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_BaiduMapView_IView <NSObject>

@required
//属性方法
- (void)change_zoomLevel:(NSString *)newValue;
- (void)change_mapType:(NSString *)newValue;

//同步或异步方法
- (void)poiSearch:(NSArray *)parms;
- (void)addMarkers:(NSArray *)parms;
- (void)addOverlay:(NSArray *)parms;
- (void)removeAll:(NSArray *)parms;
- (void)removeMarker:(NSArray *)parms;
- (void)removeOverlay:(NSArray *)parms;
- (void)setCenter:(NSArray *)parms;
- (void)routePlanSearch:(NSArray *)parms;
@end
