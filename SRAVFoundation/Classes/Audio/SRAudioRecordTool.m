//
//  SRAudioRecordTool.m
//  SRAVFoundation
//
//  Created by 周家民 on 2020/6/10.
//

#import "SRAudioRecordTool.h"

@interface SRAudioRecordTool () <AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@property (nonatomic, strong) NSDictionary *settings;

@property (nonatomic, copy) NSString *tempFilePath;

@property (nonatomic, strong) NSString *cacheDirectoryPath;

@property (nonatomic, copy) SRAudioRecordCompletion recordCompletion;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SRAudioRecordTool

SRSingletonImpl

- (instancetype)init {
    if (self = [super init]) {
        _fileFormat = kAudioFormatMPEG4AAC;
        _audioQuality = AVAudioQualityMedium;
        _bitDepth = 16;
    }
    return self;
}

#pragma mark - getter
SRLazyProperty(NSString *, cacheDirectoryPath, [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"/sraudio/"])

- (double)sampleRate {
    if (_sampleRate < 1) {
        _sampleRate = 44100.0f;
    }
    return _sampleRate;
}

- (NSDictionary *)settings {
    return @{
        AVFormatIDKey: @(self.fileFormat),
        AVSampleRateKey: @(self.sampleRate),
        AVEncoderBitDepthHintKey: @(self.bitDepth),
        AVNumberOfChannelsKey: @(1),
        AVEncoderAudioQualityKey: @(self.audioQuality)
    };
}

- (NSString *)tempFilePath {
    if (!_tempFilePath) {
        _tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"audioTemp.caf"];
    }
    return _tempFilePath;
}

- (NSInteger)bitDepth {
    return MAX(1, MIN(32, _bitDepth));
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyyMMddhhmmss";
    }
    return _dateFormatter;
}

#pragma mark - custom
- (void)pause {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
    }
}

- (void)continueRecord {
    if (self.audioRecorder && !self.audioRecorder.isRecording) {
        [self.audioRecorder record];
    }
}

- (void)startRecordWithErrorCallback:(void (^)(NSError * _Nullable))errorCallback {
    if (self.audioRecorder && self.audioRecorder.isRecording) {
        [self stopRecordWithCmpletion:^(NSString * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }];
        self.audioRecorder = nil;
    }
    NSURL *url = [NSURL fileURLWithPath:self.tempFilePath];
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    if (error) {
        if (errorCallback) {
            errorCallback(error);
        }
        return;
    }
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.settings error:&error];
    if (error) {
        if (errorCallback) {
            errorCallback(error);
        }
        return;
    }
    self.audioRecorder.delegate = self;
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder record];
}

- (void)stopRecordWithCmpletion:(SRAudioRecordCompletion)completion {
    self.recordCompletion = completion;
    [self.audioRecorder stop];
}

- (NSString *)generateFileName {
    return [NSString stringWithFormat:@"%@.caf", [self.dateFormatter stringFromDate:[NSDate date]]];
}

- (void)cleanCache {
    [[NSFileManager defaultManager] removeItemAtPath:self.cacheDirectoryPath error:nil];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self.recordCompletion) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.cacheDirectoryPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        NSString *tempFilePath = self.tempFilePath;
        NSString *destFilePath = [self.cacheDirectoryPath stringByAppendingPathComponent:[self generateFileName]];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:tempFilePath toPath:destFilePath error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
        self.recordCompletion(destFilePath, error);
    }
    self.audioRecorder = nil;
}

@end
