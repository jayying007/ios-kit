//
//  ViewController.m
//  Audio
//
//  Created by janezhuang on 2021/12/3.
//

#import "ViewController.h"
#import "UIView+Frame.h"
#import "AudioRecorder.h"
#import "RecordListViewController.h"

@interface ViewController () <AudioRecorderDelegate>
@property (nonatomic) UIButton *startBtn;
@property (nonatomic) UIButton *stopBtn;
@property (nonatomic) UIButton *listBtn;
@property (nonatomic) UILabel *tipLabel;

@property (nonatomic) AudioRecorder *recorder;
@property (nonatomic) NSMutableData *recordData;

@property (nonatomic) NSFileManager *fileManager;
@property (nonatomic) NSString *recordFileName;
@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.startBtn];
    [self.view addSubview:self.stopBtn];
    [self.view addSubview:self.listBtn];
    [self.view addSubview:self.tipLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"录音";
}

- (UIButton *)startBtn {
    if (_startBtn == nil) {
        _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _startBtn.centerX = self.view.centerX;
        _startBtn.bottom = self.view.height - 80;
        _startBtn.backgroundColor = UIColor.lightGrayColor;
        [_startBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UIButton *)stopBtn {
    if (_stopBtn == nil) {
        _stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _stopBtn.x = 50;
        _stopBtn.centerY = self.startBtn.centerY;
        _stopBtn.backgroundColor = UIColor.redColor;
        [_stopBtn addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopBtn;
}

- (UIButton *)listBtn {
    if (_listBtn == nil) {
        _listBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _listBtn.right = self.view.right - 50;
        _listBtn.centerY = self.startBtn.centerY;
        _listBtn.backgroundColor = UIColor.grayColor;
        [_listBtn addTarget:self action:@selector(jumpToRecordList) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listBtn;
}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, self.view.width - 60, self.view.height / 2)];
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = [UIFont systemFontOfSize:18];
        _tipLabel.textColor = UIColor.blackColor;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (AudioRecorder *)recorder {
    if (_recorder == nil) {
        _recorder = [[AudioRecorder alloc] init];
        _recorder.delegate = self;
        _recordData = [NSMutableData data];
    }
    return _recorder;
}
#pragma mark - Event
- (void)startRecord {
    self.tipLabel.text = @"开始录音";
    self.recordFileName = [NSString stringWithFormat:@"%.f.pcm", [[NSDate date] timeIntervalSince1970]];
    [self.recorder start];
}

- (void)stopRecord {
    self.tipLabel.text = @"停止录音";
    [self.recorder stop];
    
    NSArray *documentsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentsArr.firstObject;
    NSString *folderPath = [documentPath stringByAppendingPathComponent:@"Audio"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"初次创建文件夹");
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:self.recordFileName];
    [self.recordData writeToFile:filePath atomically:YES];
    NSLog(@"write to file %@ bytes", self.recordData.length);
    self.recordData = [NSMutableData data];
}

- (void)jumpToRecordList {
    RecordListViewController *vc = [[RecordListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - AudioRecorderDelegate
- (void)audioRecorder:(AudioRecorder *)recorder didReceiveData:(NSData *)data {
    NSLog(@"receive data length: %lu", data.length);
    [self.recordData appendData:data];
}
@end
