#include "godotAdmob.h"
#import "app_delegate.h"

#import <GoogleMobileAds/GADMobileAds.h>
#import <UnityAds/UADSMetaData.h>
#import <PersonalizedAdConsent/PersonalizedAdConsent.h>


#if VERSION_MAJOR == 3
#define CLASS_DB ClassDB
#else
#define CLASS_DB ObjectTypeDB
#endif


GodotAdmob::GodotAdmob() {
    initialized = false;
}

GodotAdmob::~GodotAdmob() {
    instance = NULL;
}

void GodotAdmob::init(bool isReal, int instanceId, String _lang) {
    if (initialized) {
        NSLog(@"GodotAdmob Module already initialized");
        return;
    }
    NSLog(@"Initialising GodotAdmob Module");
    initialized = true;
    instance = this;
    lang = _lang

    [GADMobileAds configureWithApplicationID:@"ca-app-pub-1160358939410189~8221472002"];

    //UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    //[gdprConsentMetaData set:@"gdpr.consent" value:@YES];
    //[gdprConsentMetaData commit];

    rewarded = [AdmobRewarded alloc];
    [rewarded initialize:isReal :instanceId];
}


@implementation ViewController
void viewDidLoad() {
    [super viewDidLoad];

    [PACConsentInformation.sharedInstance
        requestConsentInfoUpdateForPublisherIdentifiers:@[ @"pub-1160358939410189" ]
        completionHandler:^(NSError *_Nullable error) {
            if (error) {
                NSLog(@"Some error loading the view (Consent)");
            } else {
                showConsentForm();
            }
        }
    ];
}

void GodotAdmob::showConsentForm() {
    NSURL *privacyURL = [NSURL URLWithString:@"https://www.your.com/privacyurl"];
    form = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:privacyURL];
    form.shouldOfferPersonalizedAds = YES;
    form.shouldOfferNonPersonalizedAds = YES;
    form.shouldOfferAdFree = YES;

    [form loadWithCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"Load complete. Error: %@", error);
        if (error) {
            NSLog(@"Some error loading the form (Consent)");
        } else {
            [form presentFromViewController:self
                dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
                if (error) {
                    NSLog(@"Some error showing the form (Consent)");
                } else if (userPrefersAdFree) {
                    NSLog(@"Prefers ad free (Consent)");
                } else {
                    // Check the user's consent choice.
                    PACConsentStatus *status = PACConsentInformation.sharedInstance.consentStatus;
                }
            }];
        }
    }];
}


void GodotAdmob::loadRewardedVideo(const String &rewardedId) {
    //init
    if (!initialized) {
        NSLog(@"GodotAdmob Module not initialized");
        return;
    }
    
    NSString *idStr = [NSString stringWithCString:rewardedId.utf8().get_data() encoding: NSUTF8StringEncoding];
    [rewarded loadRewardedVideo: idStr];
    
}

void GodotAdmob::showRewardedVideo() {
    //show
    if (!initialized) {
        NSLog(@"GodotAdmob Module not initialized");
        return;
    }
    
    [rewarded showRewardedVideo];
}



void GodotAdmob::_bind_methods() {
    CLASS_DB::bind_method("init",&GodotAdmob::init);
    CLASS_DB::bind_method("loadRewardedVideo",&GodotAdmob::loadRewardedVideo);
    CLASS_DB::bind_method("showRewardedVideo",&GodotAdmob::showRewardedVideo);
}
