//
//  RecordListViewController.m
//  Audio
//
//  Created by janezhuang on 2021/12/3.
//

#import "RecordListViewController.h"
#import "AudioPlayer.h"
#import "AudioUnitPlayer.h"

@interface RecordListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *recordFiles;
@property (nonatomic) AudioUnitPlayer *player;
@end

@implementation RecordListViewController
- (void)loadView {
    [super loadView];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *documentsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentsArr.firstObject;
    NSString *folderPath = [documentPath stringByAppendingPathComponent:@"Audio"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.recordFiles = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.recordFiles[indexPath.row];
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = self.recordFiles[indexPath.row];
    NSArray *documentsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentsArr.firstObject;
    NSString *folderPath = [documentPath stringByAppendingPathComponent:@"Audio"];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    if (self.player) {
        [self.player stop];
    }
    self.player = [[AudioUnitPlayer alloc] initWithFilePath:filePath];
    [self.player start];
}
@end
