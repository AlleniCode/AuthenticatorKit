//
//  ViewController.m
//  AuthenticatorKitDemo
//
//  Created by Mac on 2020/1/10.
//  Copyright © 2020 Onchain. All rights reserved.
//

#import "ViewController.h"
#import <AuthenticatorKit/AuthenticatorKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ViewController ()<AuthenticatorKitDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *decentralizedRegisterOntid;
@property (nonatomic, strong) NSString *decentralizedLoginOntid;

@property (nonatomic, strong) NSString *centralizedRegisterUsername;
@property (nonatomic, strong) NSString *centralizedRegisterPassword;
@property (nonatomic, strong) NSString *centralizedRegisterOntid;

@property (nonatomic, strong) NSString *centralizedLoginUsername;
@property (nonatomic, strong) NSString *centralizedLoginPassword;
@property (nonatomic, strong) NSString *centralizedLoginOntid;

@property (nonatomic, strong) NSString *addOwnerOntid;
@property (nonatomic, strong) NSString *loginOwnerOntid;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[UIView new]];
    
    [[AuthenticatorKit shareInstance] setDelegate:self];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = [self getTitleWithType:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self actionWithType:indexPath.row];
}


- (NSString *)getTitleWithType:(ActionType)type {
    switch (type) {
        case ActionTypeDecentralizedRegister: {
            if (self.decentralizedRegisterOntid) {
                return [NSString stringWithFormat:@"Decentralized registration(%@)", self.decentralizedRegisterOntid];
            } else {
                return @"Decentralized registration";
            }
        }
        case ActionTypeDecentralizedLogin: {
            if (self.decentralizedLoginOntid) {
                return [NSString stringWithFormat:@"Decentralized login(%@)", self.decentralizedLoginOntid];
            } else {
                return @"Decentralized login";
            }
        }
        case ActionTypeApplyClaim:
            return @"Apply Claim";
        case ActionTypeGetClaim:
            return @"Get Claim";
        case ActionTypeAuthorizeClaim:
            return @"Authorize Claim";
        case ActionTypeCentralizedRegister: {
            if (self.centralizedRegisterUsername && self.centralizedRegisterOntid) {
                return [NSString stringWithFormat:@"Centralized registration(%@-%@)", self.centralizedRegisterUsername, self.centralizedRegisterOntid];
            } else {
                return @"Centralized registration";
            }
        }
        case ActionTypeCentralizedLogin: {
            if (self.centralizedLoginUsername && self.centralizedLoginOntid) {
                return [NSString stringWithFormat:@"Centralized login(%@-%@)", self.centralizedLoginUsername, self.centralizedLoginOntid];
            } else {
                return @"Centralized login";
            }
        }
        case ActionTypeCentralizedAddOwner: {
            if (self.addOwnerOntid) {
                return [NSString stringWithFormat:@"Centralized add owner(%@)", self.addOwnerOntid];
            } else {
                return @"Centralized add Owner";
            }
        }
        case ActionTypeCentralizedLoginByOwner: {
            if (self.loginOwnerOntid) {
                return [NSString stringWithFormat:@"Centralized login by Owner(%@)", self.loginOwnerOntid];
            } else {
                return @"Centralized login by Owner";
            }
        }
            
        default:return @"";
    }
}

- (void)actionWithType:(ActionType)type {
    switch (type) {
        case ActionTypeDecentralizedRegister: {
            [[AuthenticatorKit shareInstance] decentralizedRegisterWithUserName:@"Allen" callback:^(BOOL success, NSError * _Nonnull error) {
                NSLog(@"%d : %@", success, error);
            }];
            break;
        }
        case ActionTypeDecentralizedLogin: {
            [[AuthenticatorKit shareInstance] decentralizedLoginCallback:^(BOOL success, NSError * _Nonnull error) {
                NSLog(@"%d : %@", success, error);
            }];
            break;
        }
        case ActionTypeApplyClaim: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your ontid" message:nil preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alertController) weakAlert = alertController;
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSString *ontid = weakAlert.textFields.firstObject.text;
                NSLog(@"%@", ontid);
                [[AuthenticatorKit shareInstance] applyClaimWithOntid:ontid name:@"Allen" age:18 callback:^(BOOL success, NSError * _Nonnull error) {
                    NSLog(@"%d : %@", success, error);
                    if (success) {
                        [self showText:@"Apply Success"];
                    } else {
                        [self showText:@"Apply Failed"];
                    }
                }];
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Enter the ontid to apply for";
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:doneAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case ActionTypeGetClaim: {
            [[AuthenticatorKit shareInstance] getClaimCallback:^(BOOL success, NSError * _Nonnull error) {
                NSLog(@"%d : %@", success, error);
            }];
            break;
        }
        case ActionTypeAuthorizeClaim: {
            [[AuthenticatorKit shareInstance] authorizeClaimCallback:^(BOOL success, NSError * _Nonnull error) {
                NSLog(@"%d : %@", success, error);
            }];
            break;
        }
        case ActionTypeCentralizedRegister: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Register" message:nil preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alertController) weakAlert = alertController;
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSString *userName = weakAlert.textFields.firstObject.text;
                NSString *password = weakAlert.textFields.lastObject.text;
                NSLog(@"%@: %@", userName, password);
                [[AuthenticatorKit shareInstance] centralizedRegisterWithUserName:userName password:password callback:^(BOOL success, NSString * _Nonnull ontid, NSError * _Nonnull error) {
                    if (success) {
                        self.centralizedRegisterUsername = userName;
                        self.centralizedRegisterOntid = ontid;
                        self.centralizedRegisterPassword = password;
                        [self.tableView reloadData];
                        [self showText:@"Centralized Register Success"];
                    } else {
                        [self showText:@"Centralized Register Failed"];
                    }
                }];
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"UserName";
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Password";
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:doneAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case ActionTypeCentralizedLogin: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login" message:nil preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alertController) weakAlert = alertController;
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSString *userName = weakAlert.textFields.firstObject.text;
                NSString *password = weakAlert.textFields.lastObject.text;
                NSLog(@"%@: %@", userName, password);
                [[AuthenticatorKit shareInstance] centralizedLoginWithUserName:userName password:password callback:^(BOOL success, NSString * _Nonnull ontid, NSError * _Nonnull error) {
                    if (success) {
                        self.centralizedLoginUsername = userName;
                        self.centralizedLoginOntid = ontid;
                        self.centralizedLoginPassword = password;
                        [self.tableView reloadData];
                        [self showText:@"Centralized Login Success"];
                    } else {
                        [self showText:@"Centralized Login Failed"];
                    }
                }];
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"UserName";
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Password";
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:doneAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case ActionTypeCentralizedAddOwner: {
            NSString *ontid = self.centralizedRegisterOntid?:self.centralizedLoginOntid;
            if (!ontid) {
                [self showText:@"Please Register or Login First"];
                return;
            }
            [[AuthenticatorKit shareInstance] centralizedAddOwnerWithOntid:ontid callback:^(BOOL success, NSError * _Nonnull error) {
                NSLog(@"%d : %@", success, error);
            }];
            break;
        }
        case ActionTypeCentralizedLoginByOwner: {
            [[AuthenticatorKit shareInstance] centralizedLoginByOwnerCallback:^(BOOL success, NSError * _Nonnull error) {
                NSLog(@"%d : %@", success, error);
            }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - AuthenticatorKitDelegate
- (void)receiveResultFromAuthenticator:(NSDictionary *)result {
    NSLog(@"%@", result);
    NSString *method = result[@"method"];
    if ([method isEqualToString:@"OntProtocolRegister"]) {
        self.decentralizedRegisterOntid = result[@"ontid"];
        [self showText:@"Register Success"];
    } else if ([method isEqualToString:@"OntProtocolLogin"]) {
        self.decentralizedLoginOntid = result[@"ontid"];
        //[self showText:@"Login Success"];
        NSInteger status = [result[@"loginStatus"] integerValue];
        if (status == 1) {
            [self showText:@"Login Success"];
        } else if (status == 2) {
            [self showText:@"Login Failed"];
        } else {
            [self showText:@"Login Unknow"];
        }
    } else if ([method isEqualToString:@"OntProtocolGetClaim"]) {
        NSLog(@"Claims: %@", result[@"data"]);
        [self showText:@"GetClaim Success"];
    } else if ([method isEqualToString:@"OntProtocolAuthorizeClaim"]) {
        NSLog(@"Claim: %@", result[@"data"]);
        [self showText:@"Authorize Success"];
    } else if ([method isEqualToString:@"OntProtocolAddOwner"]) {
        self.addOwnerOntid = result[@"ontid"];
        [self showText:@"Add Owner Success"];
    } else if ([method isEqualToString:@"OntProtocolLoginByOwner"]) {
        self.loginOwnerOntid = result[@"ontid"];
        //[self showText:@"Login by Owner Success"];
        NSInteger status = [result[@"loginStatus"] integerValue];
        if (status == 1) {
            [self showText:@"Login Success"];
        } else if (status == 2) {
            [self showText:@"Login Failed"];
        } else {
            [self showText:@"Login Unknow"];
        }
    }
    [self.tableView reloadData];
}

- (void)showText:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.label.font = [UIFont systemFontOfSize:14.f];
    
    [hud hideAnimated:YES afterDelay:3.0f];
}

@end
