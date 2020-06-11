//
//  SRViewController.m
//  SRAVFoundation
//
//  Created by zhoujiamin@dgg.net on 06/10/2020.
//  Copyright (c) 2020 zhoujiamin@dgg.net. All rights reserved.
//

#import "SRViewController.h"
#import <SRAVFoundation/SRAVFoundation.h>

@interface SRViewController ()

@property (nonatomic, strong) NSString *filePath;

@end

@implementation SRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp3"];
    [[SRAudioPlayTool shareInstance] setAutoSwitchPlayMode:YES];
//    [[SRAudioPlayTool shareInstance] playWithUrl:url errorCallback:^(NSError * _Nullable error) {
//        NSLog(@"%@", error);
//    } completion:^{
//        NSLog(@"完成");
//    }];
//
//    [[SRAudioRecordTool shareInstance] startRecordWithErrorCallback:^(NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"----%@", error.localizedDescription);
//        }
//    }];
}

- (IBAction)startRecordOnClick:(UIButton *)sender {
    [[SRAudioRecordTool shareInstance] startRecordWithErrorCallback:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"----%@", error.localizedDescription);
        }
    }];
}

- (IBAction)stopRecordOnClick:(UIButton *)sender {
    [[SRAudioRecordTool shareInstance] stopRecordWithCmpletion:^(NSString * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            NSLog(@"-----%@", error.localizedDescription);
        } else {
            self.filePath = filePath;
        }
    }];
}

- (IBAction)playRecordOnClick:(UIButton *)sender {
    [[SRAudioRecordTool shareInstance] cleanCache];
    return;
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    [[SRAudioPlayTool shareInstance] playWithUrl:url errorCallback:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"-----%@", error.localizedDescription);
        }
    } completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
