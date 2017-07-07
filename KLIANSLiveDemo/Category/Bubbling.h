//
//  Bubbling.h
//  KLIANSLiveDemo
//
//  Created by KLIANS on 2017/3/26.
//  Copyright © 2017年 KLIAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bubbling : NSObject<CAAnimationDelegate>
/**
 *  根据图片随机分配颜色
 *
 *  @param image baseImage
 */
- (void)bubbingImage:(UIImage *)image View:(UIView *)view;

/**
 *  多张图片中随机出现
 *
 *  @param images 图片数据
 */
- (void)bubbingImages:(NSArray *)images View:(UIView *)view;
@end
