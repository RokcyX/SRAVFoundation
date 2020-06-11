//
//  SRMacro.h
//  SRAVFoundation
//
//  Created by 周家民 on 2020/6/10.
//

#ifndef SRMacro_h
#define SRMacro_h

#define SRSingletonDef + (instancetype)shareInstance;\
+(instancetype) alloc __attribute__((unavailable("请使用shareInstance")));\
+(instancetype) new __attribute__((unavailable("请使用shareInstance")));\
-(instancetype) copy __attribute__((unavailable("请使用shareInstance")));\
-(instancetype) mutableCopy __attribute__((unavailable("请使用shareInstance")));

#define SRSingletonImpl static id _instance = nil;\
\
+ (instancetype)shareInstance {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [[self alloc] init];\
    });\
    return _instance;\
}

//懒加载属性宏
#define SRLazyProperty(returnClass, propertyName, defaultValue) - (returnClass)propertyName {\
if (!_##propertyName) {\
    _##propertyName = defaultValue;\
}\
    return _##propertyName;\
}

#endif /* SRMacro_h */
