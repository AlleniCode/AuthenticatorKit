//
//  AuthenticatorKit.m
//  AuthenticatorKit
//
//  Created by Mac on 2020/1/9.
//  Copyright © 2020 Onchain. All rights reserved.
//

#import "AuthenticatorKit.h"
#import <AFNetworking/AFNetworking.h>

NSNotificationName const ResultFromAuthenticatorNotification = @"ResultFromAuthenticatorNotification";

typedef NS_OPTIONS(NSUInteger, RequestType) {
    RequestTypeGET,
    RequestTypePOST
};


@interface AuthenticatorKit ()

@property (nonatomic, strong) NSString *appId;

@end

@implementation AuthenticatorKit

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static AuthenticatorKit *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [AuthenticatorKit shareInstance];
}

- (void)setUrlSchemes:(NSString *)urlSchemes {
    if (urlSchemes && urlSchemes.length > 0) {
        _urlSchemes = urlSchemes;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultFromAuthenticator:) name:ResultFromAuthenticatorNotification object:nil];
    }
}

- (void)resultFromAuthenticator:(NSNotification *)notification {
    NSLog(@"%@", notification.object);
    NSDictionary *dic = (NSDictionary *)notification.object;
    if (self.delegate && [self.delegate respondsToSelector:@selector(receiveResultFromAuthenticator:)]) {
        NSString *method = dic[@"method"];
        if ([method isEqualToString:@"OntProtocolLogin"]) {
            [self getDecentralizedLoginStatusCallback:^(NSInteger status, NSError *error) {
                NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                [mDic setValue:@(status) forKey:@"loginStatus"];
                [self.delegate receiveResultFromAuthenticator:mDic];
            }];
        } else if ([method isEqualToString:@"OntProtocolLoginByOwner"]) {
            
        } else {
           [self.delegate receiveResultFromAuthenticator:dic];
        }
    }
}

+ (void)requestWithType:(RequestType)type URLString:(NSString *)URLString headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters result:(void (^)(id data, NSError *error))result {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Headers
    for (NSString *key in [headers allKeys]) {
        [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    // Failure
    void (^handleFailure)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error.description);
        result(nil, error);
    };
    // Success
    void (^handleSuccess)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        result(responseObject, nil);
    };
    // Method
    if (type == RequestTypePOST) {
        [manager POST:URLString parameters:parameters progress:nil success:handleSuccess failure:handleFailure];
    } else {
        [manager GET:URLString parameters:parameters progress:nil success:handleSuccess failure:handleFailure];
    }
}

+ (NSString *)getMethodWithType:(ActionType)type {
    switch (type) {
        case ActionTypeDecentralizedRegister:
            return @"OntProtocolRegister";
        case ActionTypeDecentralizedLogin:
            return @"OntProtocolLogin";
        case ActionTypeGetClaim:
            return @"OntProtocolGetClaim";
        case ActionTypeAuthorizeClaim:
            return @"OntProtocolAuthorizeClaim";
        case ActionTypeCentralizedAddOwner:
            return @"OntProtocolAddOwner";
        case ActionTypeCentralizedLoginByOwner:
            return @"OntProtocolLoginByOwner";
            
        default:return @"";
    }
}

+ (void)openAuthenticatorWithType:(ActionType)type qrCode:(NSDictionary *)qrCode callback:(void (^)(BOOL success, NSError *error))callback {
    NSString *method = [AuthenticatorKit getMethodWithType:type];
    
    NSDictionary *params = @{@"urlSchemes": @"authenticatordemo",
                             @"qrCode": qrCode,
                             @"method": method
    };
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
    if (!error) {
        NSString *encodeStr = [data base64EncodedStringWithOptions:0];
        NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"ontologyauthenticator://params?params=%@", encodeStr]];
        if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
            [[UIApplication sharedApplication] openURL:appURL options:@{} completionHandler:^(BOOL success) {
                callback(success, nil);
            }];
        } else {
            callback(NO, nil);
        }
    } else {
        callback(NO, error);
    }
}

- (void)decentralizedRegisterWithUserName:(NSString *)userName callback:(void (^)(BOOL success, NSError *error))callback {
    NSString *url = @"https://prod.microservice.ont.io/addon-server/api/v1/account/register";
    NSDictionary *params = @{@"userName": userName};
    
    [AuthenticatorKit requestWithType:RequestTypePOST URLString:url headers:@{} parameters:params result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSDictionary *qrCode = result[@"result"][@"qrcode"];
                [AuthenticatorKit openAuthenticatorWithType:ActionTypeDecentralizedRegister qrCode:qrCode callback:^(BOOL success, NSError *error) {
                    callback(success, error);
                }];
            } else {
                callback(NO, nil);
            }
        } else {
            callback(NO, error);
        }
    }];
}


/// 查询登录状态
- (void)getDecentralizedLoginStatusCallback:(void (^)(NSInteger status, NSError *error))callback {
    NSString *url = [NSString stringWithFormat:@"https://prod.microservice.ont.io/addon-server/api/v1/account/login/result/%@", self.appId];
    
    [AuthenticatorKit requestWithType:RequestTypeGET URLString:url headers:@{} parameters:@{} result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSInteger status = [result[@"result"][@"result"] integerValue];
                callback(status, nil);
            } else {
                callback(-1, nil);
            }
        } else {
            callback(-1, error);
        }
    }];
}


- (void)handelURL:(NSURL *)url {
    if (url && [url.scheme isEqualToString:self.urlSchemes]) {
        NSArray *array = [url.query componentsSeparatedByString:@"params="];
        if (array.count > 0) {
            NSString *actionBody = array.lastObject;
            NSData *data = [[NSData alloc] initWithBase64EncodedString:actionBody options:0];
            NSError *error = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (!error && [json isKindOfClass:[NSDictionary class]]) {
                NSLog(@"%@", json);
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"ONTAuthCallbackNotification" object:json];
                
                NSDictionary *dic = (NSDictionary *)json;
                if (self.delegate && [self.delegate respondsToSelector:@selector(receiveResultFromAuthenticator:)]) {
                    NSString *method = dic[@"method"];
                    if ([method isEqualToString:@"OntProtocolLogin"]) {
                        [self getDecentralizedLoginStatusCallback:^(NSInteger status, NSError *error) {
                            NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                            [mDic setValue:@(status) forKey:@"loginStatus"];
                            [self.delegate receiveResultFromAuthenticator:mDic];
                        }];
                    } else if ([method isEqualToString:@"OntProtocolLoginByOwner"]) {
                        
                    } else {
                       [self.delegate receiveResultFromAuthenticator:dic];
                    }
                }
            }
        }
    }
}

@end
