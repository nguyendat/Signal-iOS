//  Created by Michael Kirk on 9/21/16.
//  Copyright © 2016 Open Whisper Systems. All rights reserved.

#import "OWSContactInfoTableViewController.h"
#import "FingerprintViewController.h"
#import <SignalServiceKit/OWSFingerprint.h>
#import <SignalServiceKit/TSStorageManager.h>
#import <SignalServiceKit/TSStorageManager+IdentityKeyStore.h>
#import <SignalServiceKit/TSStorageManager+keyingMaterial.h>
#import <SignalServiceKit/TSThread.h>
#import <25519/Curve25519.h>

@interface OWSContactInfoTableViewController ()

@property (nonatomic) TSThread *thread;
@property (nonatomic) NSString *contactName;

@property (nonatomic) TSStorageManager *storageManager;

@end

@implementation OWSContactInfoTableViewController

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return self;
    }

    _storageManager = [TSStorageManager sharedManager];

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }

    _storageManager = [TSStorageManager sharedManager];

    return self;
}

- (void)configureWithThread:(TSThread *)thread
                fingerprint:(OWSFingerprint *)fingerprint
                contactName:(NSString *)contactName
{
    self.thread = thread;
    self.contactName = contactName;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[FingerprintViewController class]]) {

        NSString *theirSignalId = self.thread.contactIdentifier;
        NSData *theirIdentityKey = [self.storageManager identityKeyForRecipientId:theirSignalId];
        NSString *mySignalId = [self.storageManager localNumber];
        NSData *myIdentityKey = [self.storageManager identityKeyPair].publicKey;
        OWSFingerprint *fingerprint = [OWSFingerprint fingerprintWithMyStableId:mySignalId
                                                                  myIdentityKey:myIdentityKey
                                                                  theirStableId:theirSignalId
                                                               theirIdentityKey:theirIdentityKey];

        FingerprintViewController *controller = (FingerprintViewController *)segue.destinationViewController;
        [controller configureWithThread:self.thread fingerprint:fingerprint contactName:self.contactName];
    }
}


@end
