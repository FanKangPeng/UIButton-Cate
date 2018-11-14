//
//  UIButton+Cate.h
//  UIButton
//
//  Created by 樊康鹏 on 2018/11/14.
//  Copyright © 2018年 樊康鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Cate)
#pragma mark -- 按钮倒计时
/**
 *  倒计时
 *
 *  @param timeLine 时间
 *  @param timeColor 时间的字体颜色
 *  @param titleColor 文本的字体颜色
 */
- (void)startTime:(double)timeLine
            title:(NSString *)title
          timeTxt:(NSString *)timeTxt
        timeColor:(UIColor *)timeColor
       titleColor:(UIColor *)titleColor;

#pragma mark -- 扩展属性
/**
 *  为按钮添加点击间隔 eventTimeInterval秒
 */
@property (nonatomic, assign) NSTimeInterval eventTimeInterval;
/**
 *  bool YES 忽略点击事件   NO 允许点击事件
 */
@property (nonatomic, assign) BOOL isIgnoreEvent;
/**
 *按钮点击事件 是否需要网络
 */
@property (nonatomic ,assign) BOOL needNet;
/**
 *按钮点击的提示语
 */
@property (nonatomic ,copy) NSString * alertTxt;

@end

NS_ASSUME_NONNULL_END
