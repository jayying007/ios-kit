//
//  ViewController.m
//  healthkit
//
//  Created by janezhuang on 2021/11/13.
//

#import "MainViewController.h"
#import "StepCountViewController.h"
#import "ActivitySummaryViewController.h"
#import "CustomRingViewController.h"

@interface MainViewController ()
@property (nonatomic) UIButton *stepCountBtn;
@property (nonatomic) UIButton *workoutBtn;
@property (nonatomic) UIButton *activitySummaryBtn;
@property (nonatomic) UIButton *customRingBtn;
@end

@implementation MainViewController

- (void)loadView {
    [super loadView];
    self.stepCountBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 120, 60)];
    self.stepCountBtn.backgroundColor = UIColor.lightGrayColor;
    [self.stepCountBtn setTitle:@"步数" forState:UIControlStateNormal];
    [self.stepCountBtn addTarget:self action:@selector(jumpToStepCount) forControlEvents:UIControlEventTouchUpInside];
    
    self.workoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 250, 120, 60)];
    self.workoutBtn.backgroundColor = UIColor.lightGrayColor;
    [self.workoutBtn setTitle:@"运动项" forState:UIControlStateNormal];
    [self.workoutBtn addTarget:self action:@selector(jumpToWorkout) forControlEvents:UIControlEventTouchUpInside];
    
    self.activitySummaryBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 350, 120, 60)];
    self.activitySummaryBtn.backgroundColor = UIColor.lightGrayColor;
    [self.activitySummaryBtn setTitle:@"运动环" forState:UIControlStateNormal];
    [self.activitySummaryBtn addTarget:self action:@selector(jumpToActivitySummary) forControlEvents:UIControlEventTouchUpInside];
    
    self.customRingBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 450, 120, 60)];
    self.customRingBtn.backgroundColor = UIColor.lightGrayColor;
    [self.customRingBtn setTitle:@"自定义环" forState:UIControlStateNormal];
    [self.customRingBtn addTarget:self action:@selector(jumpToCustomRing) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.stepCountBtn];
    [self.view addSubview:self.workoutBtn];
    [self.view addSubview:self.activitySummaryBtn];
    [self.view addSubview:self.customRingBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)jumpToStepCount {
    StepCountViewController *vc = [[StepCountViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)jumpToWorkout {
    
}

- (void)jumpToActivitySummary {
    ActivitySummaryViewController *vc = [[ActivitySummaryViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)jumpToCustomRing {
    CustomRingViewController *vc = [[CustomRingViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}
@end
