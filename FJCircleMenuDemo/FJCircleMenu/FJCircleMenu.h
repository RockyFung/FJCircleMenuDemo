//
//  FJCircleMenu.h
//  FJCircleMenuDemo
//
//  Created by 冯剑 on 2021/3/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


// 子视图在圆环上的位置
typedef enum : NSUInteger {
    FJCircleMenuTypeTop,
    FJCircleMenuTypeBottom
} FJCircleMenuType;

@class FJCircleMenu;

@protocol FJCircleMenuDelegate <NSObject>
// 返回选中的中间view
- (void)camberMenuSelectedCenterSubView:(UIView *)centerView index:(NSInteger)index;

@end

@interface FJCircleMenu : UIView
@property(nonatomic, weak) id<FJCircleMenuDelegate> delegate;
/**
 初始化方法
 
 @param radius 外圆半径
 @param type 子视图位置
 @param centerPoint 外圆中心点
 @param outsideCirCleImage 外圆图片
 @param insideCirCleImage 内圆图片
 @param circleMargin 外圆和内圆距离
 @return self
 */
- (instancetype)initWithRadius:(CGFloat)radius andCenterPoint:(CGPoint)centerPoint type:(FJCircleMenuType)type andOutsideCirCleImage:(UIImage *)outsideCirCleImage andInsideCircleImage:(UIImage *)insideCirCleImage andInsideCircleMargin:(CGFloat)circleMargin;


/**
 添加子视图
 
 @param viewArray 子视图数组
 @param count 屏幕静止时要显示的子视图个数
 @param centerIndex 默认选中下标
 */
- (void)addSubViewWithSubViewArray:(NSArray *)viewArray withShowBtnCount:(int)count centerIndex:(NSInteger)centerIndex;


- (void)changeSubviewToCenter:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
