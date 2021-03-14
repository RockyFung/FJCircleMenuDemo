//
//  ViewController.m
//  FJCircleMenuDemo
//
//  Created by 冯剑 on 2021/3/14.
//

#import "ViewController.h"
#import "FJCircleMenu.h"
@interface ViewController ()<FJCircleMenuDelegate>
@property(nonatomic, strong) FJCircleMenu *camberView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
     输入半径、圆心、外圆图片、内圆图片、外圆与内圆距离
     
     半径要 > 屏幕宽度的一半
     */

    FJCircleMenu *view = [[FJCircleMenu alloc]initWithRadius:500 andCenterPoint:CGPointMake(self.view.frame.size.width / 2, 800) type:FJCircleMenuTypeTop andOutsideCirCleImage:[UIImage imageNamed:@"color1"] andInsideCircleImage:[UIImage imageNamed:@"color2"] andInsideCircleMargin:80];
    view.delegate = self;
    ///添加子视图数组与界面静止时子视图个数
    [view addSubViewWithSubViewArray:[self btnArrayCreat] withShowBtnCount:5 centerIndex:2];
    self.camberView = view;
    [self.view addSubview:view];
}

///按钮数组
- (NSArray *)btnArrayCreat{
    
    NSMutableArray *btnArray = [NSMutableArray array];
    
    for (int i = 0; i < 7; i++) {
        UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        
        button.backgroundColor=[UIColor yellowColor];
        button.layer.cornerRadius= 60/2;
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"第%d个",i + 1] forState:UIControlStateNormal];
        button.tag=100+i;
        [btnArray addObject:button];
        [button addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return btnArray;
}

- (void)clickButtonAction:(UIButton *)btn{
    [self.camberView changeSubviewToCenter:btn];
    
}

#pragma mark - HXCamberMenuDelegate
- (void)camberMenuSelectedCenterSubView:(UIView *)centerView index:(NSInteger)index{
    NSLog(@"中间view %@-第%ld个",centerView,index);
//    centerView.transform = CGAffineTransformMakeScale(1.2, 1.2);
}


@end
