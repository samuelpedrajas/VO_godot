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
    lang = _lang;
    obj = ObjectDB::get_instance(instanceId);

    [GADMobileAds configureWithApplicationID:@"ca-app-pub-1160358939410189~8221472002"];

    //UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    //[gdprConsentMetaData set:@"gdpr.consent" value:@YES];
    //[gdprConsentMetaData commit];

    rewarded = [AdmobRewarded alloc];
    [rewarded initialize:isReal :instanceId];
}


String getConsentStatus(PACConsentStatus consentStatus) {
    String status = "unknown";
    if (consentStatus == PACConsentStatusPersonalized) {
        NSLog(@"consentStatus is personalized");
        status = "personalized";
    } else if (consentStatus == PACConsentStatusNonPersonalized) {
        NSLog(@"consentStatus is non personalized");
        status = "non_personalized";
    } else if (consentStatus == PACConsentStatusUnknown) {
        NSLog(@"consentStatus is unkown");
        status = "unknown";
    } else {
        NSLog(@"consentStatus is none of the 3!");
    }
    return status;
}


void GodotAdmob::requestConsent() {
    [PACConsentInformation.sharedInstance
        requestConsentInfoUpdateForPublisherIdentifiers:@[ @"pub-1160358939410189" ]
        completionHandler:^(NSError *_Nullable error) {
            if (error) {
                NSLog(@"Some error requesting consent");
                obj->call_deferred("_on_consent_failed_to_update", "error while requesting consent");
            } else {
                PACConsentStatus consentStatus =
                    PACConsentInformation.sharedInstance.consentStatus;
                String status = getConsentStatus(consentStatus);
                obj->call_deferred("_on_consent_info_updated", status);
            }
        }
    ];
}


void GodotAdmob::loadConsentForm() {
    NSURL *privacyURL = NULL;
    NSString *ns_lang = [[NSString alloc] initWithUTF8String:lang.utf8().get_data()];
    if ([ns_lang isEqualToString:@"es"])
        privacyURL = [NSURL URLWithString:@"https://veganodysseythegame.com/es/privacy-policy"];
    else {
        privacyURL = [NSURL URLWithString:@"https://veganodysseythegame.com/privacy-policy"];
    }

    form = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:privacyURL];
    form.shouldOfferPersonalizedAds = YES;
    form.shouldOfferNonPersonalizedAds = YES;
    form.shouldOfferAdFree = YES;

    [form loadWithCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"Load complete. Error: %@", error);
        if (error) {
            NSLog(@"Some error loading the form (Consent)");
            obj->call_deferred("_on_consent_form_error", "error while loading the consent request");
        } else {
            obj->call_deferred("_on_consent_form_loaded");
        }
    }];
}


void GodotAdmob::showConsentForm() {
    ViewController *root_controller = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    [form presentFromViewController:root_controller
        dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
        if (error) {
            NSLog(@"Some error showing the form (Consent)");

            obj->call_deferred("_on_consent_form_error", "error while showing consent form");
        } else {
            PACConsentStatus consentStatus =
                PACConsentInformation.sharedInstance.consentStatus;
            String status = getConsentStatus(consentStatus);

            obj->call_deferred("_on_consent_form_closed", status, userPrefersAdFree);
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
    CLASS_DB::bind_method("requestConsent",&GodotAdmob::requestConsent);
    CLASS_DB::bind_method("loadConsentForm",&GodotAdmob::loadConsentForm);
    CLASS_DB::bind_method("showConsentForm",&GodotAdmob::showConsentForm);
}
