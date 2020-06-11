//
//  SRAudioPlayTool.h
//  SRAVFoundation
//
//  Created by 周家民 on 2020/6/10.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SRMacro.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SRAudioPlayError)(NSError * _Nullable error);

typedef void(^SRAudioPlayCompletion)(void);

@interface SRAudioPlayTool : NSObject

SRSingletonDef

/// 是否根据距离传感器自动切换播放模式（听筒/扬声器）,默认NO
@property (nonatomic, assign) BOOL autoSwitchPlayMode;

/// 暂停所有音频播放
- (void)pause;

/// 停止所有音频播放
- (void)stop;

/// 从暂停位置继续播放所有音频
- (void)continuePlay;

/// 生成AVAudioPlayer实例，包含部分预设值
/// @param url 本地音频路径
/// @param error 错误对象的指针
- (AVAudioPlayer *)generateAudioPlayer:(NSURL *)url error:(NSError **)error;

/// 播放本地文件路径url的音频，默认播放一次
/// @param url 本地音频路径
/// @param errorCallback 如果播放出错，会调用此回调
/// @param completion 音频播放完成后会调用此回调
- (void)playWithUrl:(NSURL *)url errorCallback:(nullable SRAudioPlayError)errorCallback completion:(nullable SRAudioPlayCompletion)completion;

/// 播放本地文件路径url的音频，并设置循环次数，如果loopCount小于0则表示无限循环，0为播放一次
/// @param url 本地音频路径
/// @param loopCount 循环次数
/// @param errorCallback 如果播放出错，会调用此回调
/// @param completion 音频播放完成后会调用此回调
- (void)playWithUrl:(NSURL *)url loopCount:(NSInteger)loopCount errorCallback:(nullable SRAudioPlayError)errorCallback completion:(nullable SRAudioPlayCompletion)completion;

@end

NS_ASSUME_NONNULL_END
