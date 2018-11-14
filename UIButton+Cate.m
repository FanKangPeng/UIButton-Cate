//
//  UIButton+Cate.m
//  UIButton
//
//  Created by 樊康鹏 on 2018/11/14.
//  Copyright © 2018年 樊康鹏. All rights reserved.
//

#import "UIButton+Cate.h"
/**导入runtime头文件*/
#import <objc/runtime.h>
/**倒计时*/
static const char *UIControl_eventTimeInterval = "UIControl_eventTimeInterval";
/**点击*/
static const char *UIControl_enventIsIgnoreEvent = "UIControl_enventIsIgnoreEvent";
/**网络*/
static const char *UIControl_envent_neetNet = "UIControl_envent_neetNet";
/**网络*/
static const char *UIControl_envent_alertTxt = "UIControl_envent_alertTxt";
@implementation UIButton (Cate)

/**get*/
- (NSTimeInterval)eventTimeInterval{
    return [objc_getAssociatedObject(self,
                                     UIControl_eventTimeInterval)
            doubleValue];
}
/**set*/
- (void)setEventTimeInterval:(NSTimeInterval)eventTimeInterval{
    objc_setAssociatedObject(self, UIControl_eventTimeInterval,
                             @(eventTimeInterval),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent
{
    objc_setAssociatedObject(self, UIControl_enventIsIgnoreEvent, @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isIgnoreEvent{
    return [objc_getAssociatedObject(self, UIControl_enventIsIgnoreEvent) boolValue];
}
- (void)setNeedNet:(BOOL)needNet{
    objc_setAssociatedObject(self, UIControl_envent_neetNet, @(needNet), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)needNet{
    return [objc_getAssociatedObject(self, UIControl_envent_neetNet) boolValue];
}

- (void)setAlertTxt:(NSString *)alertTxt{
    objc_setAssociatedObject(self, UIControl_envent_alertTxt, alertTxt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isAlertTxt{
    return objc_getAssociatedObject(self, UIControl_envent_alertTxt);
}

+ (void)load
{
    // Method Swizzling
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selA = @selector(sendAction:to:forEvent:);
        SEL selB = @selector(_fkp_sendAction:to:forEvent:);
        Method methodA = class_getInstanceMethod(self,selA);
        Method methodB = class_getInstanceMethod(self, selB);
        
        BOOL isAdd = class_addMethod(self, selA, method_getImplementation(methodB), method_getTypeEncoding(methodB));
        
        if (isAdd) {
            class_replaceMethod(self, selB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
        }else{
            //添加失败了 说明本类中有methodB的实现，此时只需要将methodA和methodB的IMP互换一下即可。
            method_exchangeImplementations(methodA, methodB);
        }
    });
}

- (void)_fkp_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    NSString *ss = [NSString stringWithUTF8String:object_getClassName(self)];
    if (![ss hasPrefix:@"UIButton"]) {//区分系统的相机按钮
        [self _fkp_sendAction:action to:target forEvent:event];
        return;
    }
    if (![self isKindOfClass:[UIButton class]]) {//某些系统的按钮也会调用button的事件，可以通过区分按钮的类型来区别
        [self _fkp_sendAction:action to:target forEvent:event];
        return;
    }
    if (self.needNet) {//开启网络判断
        if (!1) {//网络判断没写
            //如果没网络 提示没a网络
            return;
        }
    }
    self.eventTimeInterval = self.eventTimeInterval == 0 ? 1 : self.eventTimeInterval;
    if (self.isIgnoreEvent){//x允许点击
        if (self.alertTxt.length > 0 ) {
           //提示语
        }
        return;
    }else if (self.eventTimeInterval > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.eventTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setIsIgnoreEvent:NO];
        });
    }
    
    self.isIgnoreEvent = YES;
    // 这里看上去会陷入递归调用死循环，但在运行期此方法是和sendAction:to:forEvent:互换的，相当于执行sendAction:to:forEvent:方法，所以并不会陷入死循环。
    [self _fkp_sendAction:action to:target forEvent:event];
}





- (void)startTime:(double)timeLine
            title:(NSString *)title
          timeTxt:(NSString *)timeTxt
        timeColor:(UIColor *)timeColor
       titleColor:(UIColor *)titleColor{
    // 倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        // 倒计时结束，关闭
        if (timeOut <= 0) {
            dispatch_source_cancel(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //倒计时结束显示的UI文本
                [self setTitle:title forState:UIControlStateNormal];
                [self setTitleColor:timeColor forState:0];
                self.userInteractionEnabled = YES;
            });
            
        }else{
            //            int seconds = timeOut % (int)timeLine;
            NSString * timeStr = [NSString stringWithFormat:@"%ld",timeOut];
            dispatch_async(dispatch_get_main_queue(), ^{
                //倒计时时要显示的文本
                [self setTitle:[NSString stringWithFormat:@"%@%@",timeStr,timeTxt] forState:UIControlStateNormal];
                [self setTitleColor:titleColor forState:0];
                self.userInteractionEnabled = NO;
            });
            
            timeOut--;
        }
    });
    
    dispatch_resume(_timer);
}
@end
