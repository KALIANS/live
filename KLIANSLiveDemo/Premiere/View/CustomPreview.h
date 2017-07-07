//
//  CustomPreview.h
//  LiveStreamingDemo
//
//  Created by reborn on 16/11/21.
//  Copyright © 2016年 reborn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol customPreviewDelegate <NSObject>

-(void)closeLive;

@end

@interface CustomPreview : UIView

@property(nonatomic,strong)id<customPreviewDelegate>cusDelegate;

@end
