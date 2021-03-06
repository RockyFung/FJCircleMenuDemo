//
//  FJCircleMenu.m
//  FJCircleMenuDemo
//
//  Created by 冯剑 on 2021/3/14.
//
import "FJCircleMenu.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define KedgeGap 10 // 到屏幕边的距离
#define KOffsetCount 2 // 偏移几个item的距离
@interface FJCircleMenu()
///外圆
@property (nonatomic, weak) UIImageView *circleView;
///内圆
@property (nonatomic, weak) UIImageView *insertView;
///内圆外圆距离
@property (nonatomic, assign) CGFloat circleMargin;

@property (nonatomic, assign) CGFloat moveNum;
///移动值
@property (nonatomic, assign) CGFloat moveX;
///移动结束
@property (nonatomic, assign, getter=isEndMove) BOOL endMove;
///外圆半径
@property (nonatomic, assign) CGFloat radius;
///subViewX
@property (nonatomic, assign) CGFloat subViewX;
///子视图数组
@property (nonatomic, strong) NSArray *subViewArray;
///滑动手势
@property (nonatomic, strong) UIPanGestureRecognizer *pgr;
///界面中保持按钮的个数
@property (nonatomic, assign) int showBtnCount;
//第一触碰点
@property (nonatomic, assign) CGPoint beginPoint;
//第二触碰点
@property (nonatomic, assign) CGPoint movePoint;

@property(nonatomic, assign) FJCircleMenuType type;

@property(nonatomic, strong) UIView *centerView;
// 两个item的圆心距离
@property(nonatomic, assign) CGFloat itemDistance;
@end

@implementation FJCircleMenu


#pragma mark -- 初始化

- (instancetype)initWithRadius:(CGFloat)radius andCenterPoint:(CGPoint)centerPoint type:(FJCircleMenuType)type andOutsideCirCleImage:(UIImage *)outsideCirCleImage andInsideCircleImage:(UIImage *)insideCirCleImage andInsideCircleMargin:(CGFloat)circleMargin{
    self = [super initWithFrame:CGRectMake(centerPoint.x - radius, centerPoint.y - radius, radius * 2, radius * 2)];
    
    if(self){
        self.type = type;
        ///记录半径
        self.radius = radius;
        ///记录距离
        self.circleMargin = circleMargin;
        ///外圆
        UIImageView *outsideCircle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
        
        [self addSubview:outsideCircle];
        
        self.circleView = outsideCircle;
        
        if (outsideCirCleImage) {
            outsideCircle.image = outsideCirCleImage;
        }
        
        outsideCircle.backgroundColor = [UIColor clearColor];
        
        outsideCircle.layer.cornerRadius = radius;
        
        outsideCircle.layer.masksToBounds = YES;
        
        outsideCircle.userInteractionEnabled=YES;
        
        ///内圆
        UIImageView *insertView = [[UIImageView alloc] initWithFrame:CGRectMake(0 + circleMargin, 0 + circleMargin, radius * 2 - circleMargin * 2, radius * 2 - circleMargin * 2)];
        
//        NSLog(@"%f-%f-%f-%f",insertView.frame.origin.x,insertView.frame.origin.y,insertView.frame.size.width,insertView.frame.size.height);
        
        self.insertView = insertView;
        
        [self addSubview:insertView];
        
        insertView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:137.0/255.0 blue:237.0/255.0 alpha:1];
        
        if (insideCirCleImage) {
            insertView.image = insideCirCleImage;
        }
        
        insertView.backgroundColor = [UIColor clearColor];
        
        insertView.layer.cornerRadius = radius - circleMargin;
        
        insertView.layer.masksToBounds = YES;
        
//        self.insertView.userInteractionEnabled=YES;
        
        self.subViewX = centerPoint.x - radius;
    }
    
    return self;
}

#pragma mark -- 添加子视图
- (void)addSubViewWithSubViewArray:(NSArray *)viewArray withShowBtnCount:(int)count centerIndex:(NSInteger)centerIndex{
    if (viewArray.count == 0) {
        return;
    }
    
    self.subViewArray = viewArray;
    self.showBtnCount = count;
    
    for (NSInteger i=0; i<self.subViewArray.count; i++) {
        UIButton *button=self.subViewArray[i];
        
        [self.circleView addSubview:button];
    }
    
    // 两个按钮之间的距离
    UIView *view = viewArray.firstObject;
    self.itemDistance = ((SCREEN_WIDTH - 40 - KedgeGap*2 - view.frame.size.width)/(self.showBtnCount - 1));
    
    [self layoutBtn];
    
    //加转动手势
    UIPanGestureRecognizer *pgr =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(zhuanPgr:)];
    
    self.pgr = pgr;
    
    [self.circleView addGestureRecognizer:pgr];
    
    // 选中下标放大
    if (centerIndex >= 0 && centerIndex < self.subViewArray.count) {
        UIView *view = self.subViewArray[centerIndex];
        [self changeSubviewToCenter:view];
    }
}


//按钮布局
-(void)layoutBtn{
    
    ///中心点
    CGFloat yy = 0.0;
    CGFloat xx = 0.0;
    CGFloat margin = 0.0;
    ///子视图x中点
    UIView *view = self.subViewArray[0];
    CGFloat subCenterX = view.frame.size.width / 2;
    
    for (NSInteger i=0; i<self.subViewArray.count ;i++) {// 178,245
        
        margin = i * self.itemDistance;
        
        xx = KedgeGap + subCenterX + fabs(self.subViewX) + margin + self.moveNum;
        // 已知圆心、半径与x值求y值：（x-a）^2 + (y - b)^2 = r^2。
        // y = sqrt(r^2 - (x-a)^2) + b
        CGFloat r = self.radius - self.circleMargin / 2; // item圆心轨迹半径
        CGFloat a = self.radius; // 圆心x
        CGFloat b = self.radius; // 圆心y
        if (self.type == FJCircleMenuTypeTop) {
            yy = -sqrt(r * r - (xx - a) * (xx - a)) + b;
        }else{
            yy = sqrt(r * r - (xx - a) * (xx - a)) + b;
        }
        UIButton *button=[self.subViewArray objectAtIndex:i];
        if (xx >= self.radius - r && xx <= self.radius + r) {
            
//            NSLog(@"~~~~~~~%@",button);
            if (self.isEndMove) {
                [UIView animateWithDuration:0.3 animations:^{
                    button.center=CGPointMake(xx , yy);
                }];
            } else{
                button.center=CGPointMake(xx , yy);
            }
        }
        
        // 距离公式 l = sqrt((x1-x2)^2 + (y1-y2)^2)
        // 角度公式 圆心角度数 n = 2 arcsin(l/2r)
        // 中间圆的圆心（a, b-r）
        CGFloat l = sqrt(( a- xx)*(a - xx) + (b - r - yy)*(b - r - yy)); // 各点到中间圆的弧长
        CGFloat n = 0;
        if (self.type == FJCircleMenuTypeTop) {
            n =  2 * asin(l / (2 * r)); // 根据弧长和半径求角度
            if (xx < a) {
                n = -n;
            }
            if (fabs(n) >= 0) {
//                button.transform = CGAffineTransformMakeRotation(n);
            }
            
        }else{
            n = - 2 * asin(l / (2 * r)); // 根据弧长和半径求角度
            if (xx < a) {
                n = -n;
            }
            if (fabs(n) >= 0) {
                button.transform = CGAffineTransformMakeRotation(M_PI - n);
            }
            
        }

        NSLog(@"%ld-%f - %f - %f",i,l,n,xx);
        
    }
}

#pragma mark - 转动手势
-(void)zhuanPgr:(UIPanGestureRecognizer *)pgr
{
    
    UIView *subView = self.subViewArray[0];
    
    CGFloat subViewW = subView.frame.size.width;
    
    // 向中间偏移的距离
    CGFloat offset = KOffsetCount * self.itemDistance;
    
    if(pgr.state==UIGestureRecognizerStateBegan){
        
        self.endMove = NO;
        
        self.beginPoint=[pgr locationInView:self];
        
    }else if (pgr.state==UIGestureRecognizerStateChanged){
//        self.centerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.centerView.transform = CGAffineTransformIdentity;
//        self.centerView.transform = CGAffineTransformScale(self.centerView.transform, 1.0, 1.0);
        self.movePoint= [pgr locationInView:self];
        
        // 手指点到开始点的距离
        self.moveX = sqrt(fabs(self.movePoint.x - self.beginPoint.x) * fabs(self.movePoint.x - self.beginPoint.x) + fabs(self.movePoint.y - self.beginPoint.y) * fabs(self.movePoint.y - self.beginPoint.y));
        
        if (self.movePoint.x>self.beginPoint.x) {
            self.moveNum += self.moveX; // 向右移动
        } else{
            self.moveNum -= self.moveX; // 向左移动
        }
        
        // 限制最左边subview的位置
        if (self.moveNum > offset) {
            self.moveNum = offset;
        }
        
        // 限制最右边subview的位置
        if (self.moveNum < - self.itemDistance * (self.subViewArray.count - self.showBtnCount) - offset) {
            self.moveNum = - self.itemDistance * (self.subViewArray.count - self.showBtnCount) - offset;
        }
        
        [self layoutBtn];
        
        self.beginPoint = self.movePoint;
        
    }else if (pgr.state==UIGestureRecognizerStateEnded){
        
        self.endMove = YES;
        
//        NSLog(@"--------%f------%f",self.moveNum,- (SCREEN_WIDTH - 20 - subViewW) / 4);
//        for (int i = 0; i < self.subViewArray.count - self.showBtnCount + 1; i ++) {
        for (int i = 0; i < self.subViewArray.count; i ++) {
            // 找到中间的subview
            for (int i = 0; i < self.subViewArray.count; i ++) {
                if (self.moveNum > subViewW / 2 + KedgeGap - self.itemDistance * (i+1) + offset){
                    self.moveNum = - self.itemDistance * i + offset;
                    UIView *centerView = self.subViewArray[i];
                if (self.delegate && [self.delegate respondsToSelector:@selector(camberMenuSelectedCenterSubView:index:)]) {
                    
                    [self.delegate camberMenuSelectedCenterSubView:centerView index:i];
                }
                
                    self.centerView = centerView;
                    break;
                }
            }
        
            [self layoutBtn];
            
            if (self.centerView) {
                [self transformCenterView:self.centerView];
            }
        }
    }
}

- (void)changeSubviewToCenter:(UIView *)view{
    if (view == self.centerView) {
        return;
    }
    self.centerView.transform = CGAffineTransformIdentity;
    CGFloat offset = KOffsetCount * self.itemDistance;
    NSInteger index = [self.subViewArray indexOfObject:view];
    self.centerView = view;
    self.moveNum = -self.itemDistance * index + offset;
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutBtn];
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(camberMenuSelectedCenterSubView:index:)]) {
            [self.delegate camberMenuSelectedCenterSubView:view index:index];
        }
        [self transformCenterView:view];
    }];
    
    
}

- (void)transformCenterView:(UIView *)view{
    view.transform = CGAffineTransformMakeScale(1.1, 1.1);
//    view.transform = CGAffineTransformScale(view.transform, 1.2, 1.2);
//    view.transform = CGAffineTransformTranslate(view.transform, 0, -10);
}

- (void)cancelSubviewsTransform{
    [self.subViewArray enumerateObjectsUsingBlock:^(UIView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.transform = CGAffineTransformIdentity;
    }];
}

- (NSArray *)subViewArray{
    if (!_subViewArray) {
        _subViewArray = [NSArray array];
    }
    return _subViewArray;
}



@end

