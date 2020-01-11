//
//  AuthenticatorKit.m
//  AuthenticatorKit
//
//  Created by Mac on 2020/1/9.
//  Copyright © 2020 Onchain. All rights reserved.
//

#import "AuthenticatorKit.h"
#import <AFNetworking/AFNetworking.h>


typedef NS_OPTIONS(NSUInteger, RequestType) {
    RequestTypeGET,
    RequestTypePOST
};


@interface AuthenticatorKit ()

@property (nonatomic, strong) NSString *decentralizedLoginAppId;
@property (nonatomic, strong) NSString *centralizedLoginAppId;

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
    
    NSDictionary *params = @{@"urlSchemes": [AuthenticatorKit shareInstance].urlSchemes,
                             @"qrCode": qrCode,
                             @"method": method
    };
    NSLog(@"%@", params);
    
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

/// Decentralized registration
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

/// Decentralized login
- (void)decentralizedLoginCallback:(void (^)(BOOL success, NSError *error))callback {
    NSString *url = @"https://prod.microservice.ont.io/addon-server/api/v1/account/login";
    
    [AuthenticatorKit requestWithType:RequestTypePOST URLString:url headers:@{} parameters:@{} result:^(id data, NSError *error) {
        if (!error) {
            NSDictionary *result = (NSDictionary *)data;
            NSDictionary *qrCode = result[@"result"][@"qrcode"];
            self.decentralizedLoginAppId = result[@"result"][@"appId"];
            [AuthenticatorKit openAuthenticatorWithType:ActionTypeDecentralizedLogin qrCode:qrCode callback:^(BOOL success, NSError *error) {
                callback(success, error);
            }];
        } else {
            callback(NO, error);
        }
    }];
}

/// Get decentralized login status
- (void)getDecentralizedLoginStatusCallback:(void (^)(NSInteger status, NSError *error))callback {
    NSString *url = [NSString stringWithFormat:@"https://prod.microservice.ont.io/addon-server/api/v1/account/login/result/%@", self.decentralizedLoginAppId];
    
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

/// Apply Claim
- (void)applyClaimWithOntid:(NSString *)ontid name:(NSString *)name age:(NSInteger)age callback:(void (^)(BOOL success, NSError *error))callback {
    NSString *url = @"http://18.141.44.15:7879/api/v1/ta/claim";
    NSDictionary *params = @{@"name": name,
                             @"age": @(age),
                             @"answer": @(YES),
                             @"ontid": ontid,
    };
    
    [AuthenticatorKit requestWithType:RequestTypePOST URLString:url headers:@{} parameters:params result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSString *success = result[@"result"];
                if ([success isEqualToString:@"SUCCESS"]) {
                    callback(YES, nil);
                } else {
                    callback(NO, nil);
                }
            } else {
                callback(NO, nil);
            }
        } else {
            callback(NO, error);
        }
    }];
}

/// Get Claim
- (void)getClaimCallback:(void (^)(BOOL success, NSError *error))callback {
    NSString *url = @"http://18.141.44.15:7879/api/v1/ta/claim";
    
    [AuthenticatorKit requestWithType:RequestTypeGET URLString:url headers:@{} parameters:@{} result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSDictionary *qrCode = result[@"result"];
                [AuthenticatorKit openAuthenticatorWithType:ActionTypeGetClaim qrCode:qrCode callback:^(BOOL success, NSError *error) {
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

/// Authorize Claim
- (void)authorizeClaimCallback:(void (^)(BOOL success, NSError *error))callback {
    NSString *url = @"http://18.141.44.15:7878/api/v1/app/claim";
    
    [AuthenticatorKit requestWithType:RequestTypePOST URLString:url headers:@{} parameters:@{} result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSDictionary *qrCode = result[@"result"];
                [AuthenticatorKit openAuthenticatorWithType:ActionTypeAuthorizeClaim qrCode:qrCode callback:^(BOOL success, NSError *error) {
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

/// Centralized registration
- (void)centralizedRegisterWithUserName:(NSString *)userName password:(NSString *)password callback:(void (^)(BOOL success, NSString *ontid, NSError *error))callback {
    NSString *url = @"http://18.141.44.15:7878/api/v2/app/register";
    NSDictionary *params = @{@"userName": userName,
                             @"password": password
    };
    
    [AuthenticatorKit requestWithType:RequestTypePOST URLString:url headers:@{} parameters:params result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSString *ontid = result[@"result"][@"ontid"];
                callback(YES, ontid, error);
            } else {
                callback(NO, nil, nil);
            }
        } else {
            callback(NO, nil, error);
        }
    }];
}

/// Centralized login
- (void)centralizedLoginWithUserName:(NSString *)userName password:(NSString *)password callback:(void (^)(BOOL success, NSString *ontid, NSError *error))callback {
    NSString *url = @"http://18.141.44.15:7878/api/v2/app/login";
    NSDictionary *params = @{@"userName": userName,
                             @"password": password
    };
    
    [AuthenticatorKit requestWithType:RequestTypePOST URLString:url headers:@{} parameters:params result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSString *ontid = result[@"result"][@"ontid"];
                callback(YES, ontid, error);
            } else {
                callback(NO, nil, nil);
            }
        } else {
            callback(NO, nil, error);
        }
    }];
}

/// Centralized add Owner
- (void)centralizedAddOwnerWithOntid:(NSString *)ontid callback:(void (^)(BOOL success, NSError *error))callback {
    NSString *url = [NSString stringWithFormat:@"http://18.141.44.15:7878/api/v2/app/add-owner/%@", ontid];
    
    [AuthenticatorKit requestWithType:RequestTypePOST URLString:url headers:@{} parameters:@{} result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSDictionary *qrCode = result[@"result"];
                [AuthenticatorKit openAuthenticatorWithType:ActionTypeCentralizedAddOwner qrCode:qrCode callback:^(BOOL success, NSError *error) {
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

/// Centralized login by Owner
- (void)centralizedLoginByOwnerCallback:(void (^)(BOOL success, NSError *error))callback {
    NSString *url = @"http://18.141.44.15:7878/api/v2/app/login/owner";
    
    [AuthenticatorKit requestWithType:RequestTypePOST URLString:url headers:@{} parameters:@{} result:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = (NSDictionary *)data;
                NSDictionary *qrCode = result[@"result"][@"qrCode"];
                self.centralizedLoginAppId = result[@"result"][@"id"];
                [AuthenticatorKit openAuthenticatorWithType:ActionTypeCentralizedLoginByOwner qrCode:qrCode callback:^(BOOL success, NSError *error) {
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

/// Get centralized login status
- (void)getCentralizedLoginStatusCallback:(void (^)(NSInteger status, NSError *error))callback {
    NSString *url = [NSString stringWithFormat:@"http://18.141.44.15:7878/api/v2/app/login/result/%@", self.centralizedLoginAppId];
    
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
                        [self getCentralizedLoginStatusCallback:^(NSInteger status, NSError * _Nonnull error) {
                            NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                            [mDic setValue:@(status) forKey:@"loginStatus"];
                            [self.delegate receiveResultFromAuthenticator:mDic];
                        }];
                    } else {
                       [self.delegate receiveResultFromAuthenticator:dic];
                    }
                }
            }
        }
    }
}

@end
