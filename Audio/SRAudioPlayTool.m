//
//  SRAudioPlayTool.m
//  SRAVFoundation
//
//  Created by 周家民 on 2020/6/10.
//

#import "SRAudioPlayTool.h"

@interface SRAudioPlayTool () <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, AVAudioPlayer *> *playerDict;

@property (nonatomic, strong) NSMutableDictionary<NSString *, SRAudioPlayCompletion> *completionDict;

@end

@implementation SRAudioPlayTool

SRSingletonImpl;

#pragma mark - getter
SRLazyProperty(NSMutableDictionary *, playerDict, [NSMutableDictionary dictionary])
SRLazyProperty(NSMutableDictionary *, completionDict, [NSMutableDictionary dictionary])

#pragma mark - setter
- (void)setAutoSwitchPlayMode:(BOOL)autoSwitchPlayMode {
    _autoSwitchPlayMode = autoSwitchPlayMode;
    if (autoSwitchPlayMode) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorProximityMotionStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)sensorProximityMotionStateChange:(NSNotification *)noti {
    if ([[UIDevice currentDevice] proximityState]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark - custom
- (void)pause {
    for (AVAudioPlayer *audioPlayer in self.playerDict.allValues) {
        if (audioPlayer.isPlaying) {
            [audioPlayer pause];
        }
    }
}

- (void)stop {
    for (AVAudioPlayer *audioPlayer in self.playerDict.allValues) {
        [audioPlayer stop];
        audioPlayer.currentTime = 0.0f;
    }
}

- (void)continuePlay {
    for (AVAudioPlayer *audioPlayer in self.playerDict.allValues) {
        [audioPlayer prepareToPlay];
    }
    for (AVAudioPlayer *audioPlayer in self.playerDict.allValues) {
        [audioPlayer play];
    }
}

- (AVAudioPlayer *)generateAudioPlayer:(NSURL *)url error:(NSError *__autoreleasing  _Nullable *)error {
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:error];
    if (audioPlayer && !*error) {
        [audioPlayer prepareToPlay];
    }
    return audioPlayer;
}

- (void)playWithUrl:(NSURL *)url errorCallback:(SRAudioPlayError)errorCallback completion:(SRAudioPlayCompletion)completion {
    [self playWithUrl:url loopCount:1 errorCallback:errorCallback completion:completion];
}

- (void)playWithUrl:(NSURL *)url loopCount:(NSInteger)loopCount errorCallback:(SRAudioPlayError)errorCallback completion:(SRAudioPlayCompletion)completion {
    if ([AVAudioSession sharedInstance].category != AVAudioSessionCategoryPlayAndRecord && !self.autoSwitchPlayMode) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    NSError *error;
    AVAudioPlayer *player = [self generateAudioPlayer:url error:&error];
    if (error) {
        if (errorCallback) {
            errorCallback(error);
        }
    } else {
        player.delegate = self;
        player.numberOfLoops = MAX(-1, loopCount);
        NSString *key = [self randomStr:8];
        [self.playerDict setValue:player forKey:key];
        [self.completionDict setValue:completion forKey:key];
        [player play];
    }
}


/// 生成大小写字母、数字组成的随机字符串
/// @param length 长度
- (NSString *)randomStr:(NSInteger)length {
    char ch[length];
    for (int index=0; index < length; index++) {
        int num = arc4random_uniform(75)+48;
        if (num > 57 && num < 65) {
            num = num % 57 + 48;
        }
        else if (num > 90 && num < 97) {
            num = num%90+65;
        }
        ch[index] = num;
    }
    return [[NSString alloc] initWithBytes:ch length:length encoding:NSUTF8StringEncoding];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if ([self.playerDict.allValues containsObject:player] && player.currentTime == player.duration) {
        NSString *removeKey = nil;
        for (NSString *key in self.playerDict.allKeys) {
            if (player == self.playerDict[key]) {
                removeKey = key;
                break;
            }
        }
        if (removeKey.length > 0) {
            SRAudioPlayCompletion completion = [self.completionDict valueForKey:removeKey];
            if (completion) {
                completion();
            }
            [self.playerDict setValue:nil forKey:removeKey];
        }
    }
}

@end
