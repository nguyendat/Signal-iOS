//  Created by Michael Kirk on 9/21/16.
//  Copyright © 2016 Open Whisper Systems. All rights reserved.

#import "OWSContactInfoTableViewController.h"
#import "FingerprintViewController.h"
#import <25519/Curve25519.h>
#import <SignalServiceKit/OWSFingerprint.h>
#import <SignalServiceKit/TSStorageManager+IdentityKeyStore.h>
#import <SignalServiceKit/TSStorageManager+keyingMaterial.h>
#import <SignalServiceKit/TSStorageManager.h>
#import <SignalServiceKit/TSThread.h>

@interface OWSContactInfoTableViewController ()

@property (strong, nonatomic) IBOutlet UITableViewCell *verifyPrivacyCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *toggleDisappearingMessagesCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *configureDisappearingMessagesCell;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *signalIdLabel;

@property (nonatomic) TSThread *thread;
@property (nonatomic) NSString *contactName;
@property (nonatomic) NSString *signalId;
@property (nonatomic) UIImage *avatarImage;

@property (nonatomic) TSStorageManager *storageManager;

@end

typedef enum {
    OWSContactInfoTableCellIndexPrivacyVerification = 0,
    OWSContactInfoTableCellIndexToggleDisappearingMessages = 1,
    OWSContactInfoTableCellIndexConfigureDisappearingMessages = 2
} OWSContactInfoTableCellIndex ;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toggleDisappearingMessagesCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.configureDisappearingMessagesCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.nameLabel.text = self.contactName;
    self.signalIdLabel.text = self.signalId;
    self.avatar.image = self.avatarImage;
}

- (void)configureWithThread:(TSThread *)thread
                contactName:(NSString *)contactName
                   signalId:(NSString *)signalId
                avatarImage:(UIImage *)avatarImage
{
    self.thread = thread;
    self.contactName = contactName;
    self.signalId = signalId;
    self.avatarImage = avatarImage;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
        return nil;
    }
    return indexPath;
}

@end
