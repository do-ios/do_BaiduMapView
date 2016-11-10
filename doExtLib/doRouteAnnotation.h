//
//  doRouteAnnotation.h
//  Do_Test
//
//  Created by yz on 16/11/9.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface doRouteAnnotation : BMKPointAnnotation
///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点  6:楼梯、电梯
@property (nonatomic) NSInteger type;
@property (nonatomic) NSInteger degree;

//获取该RouteAnnotation对应的BMKAnnotationView
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview;

@end
