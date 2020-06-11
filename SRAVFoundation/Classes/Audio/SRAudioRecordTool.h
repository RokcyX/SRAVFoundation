//
//  SRAudioRecordTool.h
//  SRAVFoundation
//
//  Created by 周家民 on 2020/6/10.
//

#import <Foundation/Foundation.h>
#import "SRMacro.h"
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^SRAudioRecordCompletion)(NSString * _Nullable filePath, NSError * _Nullable error);

@interface SRAudioRecordTool : NSObject

SRSingletonDef

/// 采样率，默认44.1kHz
@property (nonatomic, assign) double sampleRate;

/// 文件格式，默认aac
@property (nonatomic, assign) AudioFormatID fileFormat;

/// 位元深度，取值范围（1~32），默认16
@property (nonatomic, assign) NSInteger bitDepth;

/// 音频质量，默认AVAudioQualityMedium
@property (nonatomic, assign) AVAudioQuality audioQuality;

/// 暂停录制
- (void)pause;

/// 继续录制
- (void)continueRecord;

/// 开始录制音频，如果已经在录制状态，会丢弃调上一次录制重新开始
/// @param errorCallback 错误回调
- (void)startRecordWithErrorCallback:(nullable void(^)(NSError * _Nullable error))errorCallback;

/// 停止音频录制，完成回调会返回录制完成音频文件
/// @param completion 完成回调
- (void)stopRecordWithCmpletion:(nullable SRAudioRecordCompletion)completion;

/// 清除缓存
- (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
