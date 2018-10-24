package org.godotengine.godot;

import com.google.android.gms.ads.*;


import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.net.URL;
import java.net.MalformedURLException;

import android.app.Activity;
// import android.widget.FrameLayout;
// import android.view.ViewGroup.LayoutParams;
import android.provider.Settings;
import android.graphics.Color;
import android.util.Log;
import android.os.Bundle;
import java.util.Locale;
import android.view.Gravity;
import android.view.View;
import android.graphics.Point;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;
import com.google.ads.mediation.admob.AdMobAdapter;

import com.unity3d.ads.metadata.MetaData;

import com.google.ads.consent.*;


public class GodotAdMob extends Godot.SingletonBase
{

	private Activity activity = null; // The main activity of the game
	private int instance_id = 0;

	// private AdView adView = null; // Banner view

	private boolean isReal = false; // Store if is real or not
	private boolean isLoading = false;

	// private FrameLayout layout = null; // Store the layout
	// private FrameLayout.LayoutParams adParams = null; // Store the layout params

	private RewardedVideoAd rewardedVideoAd = null; // Rewarded Video object
	private ConsentForm form = null;

	/* Init
	 * ********************************************************************** */

	/**
	 * Prepare for work with AdMob
	 * @param boolean isReal Tell if the enviroment is for real or test
	 */
	public void init(boolean isReal, int instance_id)
	{
		this.isReal = isReal;
		this.instance_id = instance_id;

		Log.d("godot", "AdMob: init");
	}


	private boolean isRequestLocationInEeaOrUnknown() {
		return ConsentInformation.getInstance(activity).isRequestLocationInEeaOrUnknown();
	}


	private String getConsentStatus(ConsentStatus consentStatus) {
		String status = "unknown";
		if (consentStatus == ConsentStatus.PERSONALIZED) {
			Log.w("godotAdmob", "consentStatus is personalized");
			return "personalized";
		} else if (consentStatus == ConsentStatus.NON_PERSONALIZED) {
			Log.w("godotAdmob", "consentStatus is non personalized");
			return "non_personalized";
		} else if (consentStatus == ConsentStatus.UNKNOWN) {
			Log.w("godotAdmob", "consentStatus is unknown");
			return "unknown";
		}
		Log.w("godotAdmob", "consentStatus is none of the 3!");
		return "unknown";
	}


	public void requestConsent() {
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				ConsentInformation consentInformation = ConsentInformation.getInstance(activity);

				// test!!!!!!!!!!!!!
				//consentInformation.addTestDevice("2A5096EECA8734236D655A85D1B05BA3");

				String[] publisherIds = {"pub-1160358939410189"};
				consentInformation.requestConsentInfoUpdate(publisherIds, new ConsentInfoUpdateListener() {
					@Override
					public void onConsentInfoUpdated(ConsentStatus consentStatus) {
						String status = getConsentStatus(consentStatus);
						GodotLib.calldeferred(instance_id, "_on_consent_info_updated", new Object[] { status });
					}

					@Override
					public void onFailedToUpdateConsentInfo(String errorDescription) {
						Log.w("godotAdmob", "Consent error");
						GodotLib.calldeferred(instance_id, "_on_consent_error", new Object[] { errorDescription });
					}
				});
			}
		});
	}


	public void setConsent(final boolean personalized_ads) {
		Log.w("godotAdmob", "Setting consent...");
		if (personalized_ads) {
			MetaData gdprMetaData = new MetaData(activity);
			gdprMetaData.set("gdpr.consent", true);
			gdprMetaData.commit();
			ConsentInformation.getInstance(activity)
				.setConsentStatus(ConsentStatus.PERSONALIZED);

		} else {
			MetaData gdprMetaData = new MetaData(activity);
			gdprMetaData.set("gdpr.consent", false);
			gdprMetaData.commit();
			ConsentInformation.getInstance(activity)
				.setConsentStatus(ConsentStatus.NON_PERSONALIZED);

		}

	}


	public void loadConsentForm(final String lang) {
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				URL privacyUrl = null;
				try {
					if (lang.equals("es")) {
						privacyUrl = new URL("https://veganodysseythegame.com/es/privacy-policy/");
					} else {
						privacyUrl = new URL("https://veganodysseythegame.com/privacy-policy/");
					}
				} catch (MalformedURLException e) {
					e.printStackTrace();
				}

				form = new ConsentForm.Builder(activity, privacyUrl)
					.withListener(new ConsentFormListener() {
						@Override
						public void onConsentFormLoaded() {
							Log.w("godotAdmob", "Consent Form Loaded!!");
							GodotLib.calldeferred(instance_id, "_on_consent_form_loaded", new Object[] { });
						}

						@Override
						public void onConsentFormOpened() {
							Log.w("godotAdmob", "Consent Form Opened!!");
						}

						@Override
						public void onConsentFormClosed(
						ConsentStatus consentStatus, Boolean userPrefersAdFree) {
							Log.w("godotAdmob", "Consent Form Closed");
							String status = getConsentStatus(consentStatus);
							GodotLib.calldeferred(instance_id, "_on_consent_form_closed", new Object[] { status, userPrefersAdFree });
						}

						@Override
						public void onConsentFormError(String errorDescription) {
							Log.w("godotAdmob", errorDescription);
							GodotLib.calldeferred(instance_id, "_on_consent_error", new Object[] { errorDescription });
						}
					})
					.withPersonalizedAdsOption()
					.withNonPersonalizedAdsOption()
					.withAdFreeOption()
					.build();
				form.load();
			}
		});
	}


	public void showConsentForm() {
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				if (form != null) {
					form.show();
				}
			}
		});

	}


	/* Rewarded Video
	 * ********************************************************************** */
	private void initRewardedVideo()
	{
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				MobileAds.initialize(activity, "ca-app-pub-1160358939410189~9637939928");

				rewardedVideoAd = MobileAds.getRewardedVideoAdInstance(activity);
				rewardedVideoAd.setRewardedVideoAdListener(new RewardedVideoAdListener()
				{
					@Override
					public void onRewardedVideoAdClosed() {
						Log.w("godot", "AdMob: onRewardedVideoAdClosed");
						GodotLib.calldeferred(instance_id, "_on_rewarded_video_ad_closed", new Object[] { });
					}

					@Override
					public void onRewardedVideoAdFailedToLoad(int errorCode) {
						isLoading = false;
						Log.w("godot", "AdMob: onRewardedVideoAdFailedToLoad. errorCode: " + errorCode);
						GodotLib.calldeferred(instance_id, "_on_rewarded_video_ad_failed_to_load", new Object[] { errorCode });
					}

					@Override
					public void onRewardedVideoAdLoaded() {
						Log.w("godot", "AdMob: onRewardedVideoAdLoaded");
						GodotLib.calldeferred(instance_id, "_on_rewarded_video_ad_loaded", new Object[] { });
					}

					@Override
					public void onRewarded(RewardItem reward) {
						Log.w("godot", "AdMob: " + String.format(" onRewarded! currency: %s amount: %d", reward.getType(),
								reward.getAmount()));
						GodotLib.calldeferred(instance_id, "_on_rewarded", new Object[] { reward.getType(), reward.getAmount() });
					}

					@Override
					public void onRewardedVideoCompleted() {
						Log.w("godot", "AdMob: onRewardedVideoCompleted");
						// GodotLib.calldeferred(instance_id, "_on_rewarded_video_completed", new Object[] { });
					}

					@Override
					public void onRewardedVideoAdLeftApplication() {
						Log.w("godot", "AdMob: onRewardedVideoAdLeftApplication");
						// GodotLib.calldeferred(instance_id, "_on_rewarded_video_ad_left_application", new Object[] { });
					}

					@Override
					public void onRewardedVideoStarted() {
						Log.w("godot", "AdMob: onRewardedVideoStarted");
						// GodotLib.calldeferred(instance_id, "_on_rewarded_video_started", new Object[] { });
					}

					@Override
					public void onRewardedVideoAdOpened() {
						Log.w("godot", "AdMob: onRewardedVideoAdOpened");
						// GodotLib.calldeferred(instance_id, "_on_rewarded_video_ad_opened", new Object[] { });
					}
				});

			}
		});

	}

	/**
	 * Load a Rewarded Video
	 * @param String id AdMod Rewarded video ID
	 */
	public void loadRewardedVideo(final String id, final boolean personalized_ads) {
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				if (rewardedVideoAd == null) {
					initRewardedVideo();
				}

				if (!rewardedVideoAd.isLoaded() && !isLoading) {
					isLoading = true;
					AdRequest.Builder adBuilder = new AdRequest.Builder();

					adBuilder.tagForChildDirectedTreatment(true);
					if (!isReal) {
						Log.w("godot", "AdMob: requesting not real ad");
						adBuilder.addTestDevice("2A5096EECA8734236D655A85D1B05BA3");
						adBuilder.addTestDevice(AdRequest.DEVICE_ID_EMULATOR);
						adBuilder.addTestDevice(getAdmobDeviceId());
					}
					if (!personalized_ads) {
						Log.w("godot", "AdMob: requesting non personalized ad");
						Bundle extras = new Bundle();
						extras.putString("npa", "1");

						rewardedVideoAd.loadAd(id,
							adBuilder.addNetworkExtrasBundle(
								AdMobAdapter.class, extras
							).build()
						);
					} else {
						Log.w("godot", "AdMob: requesting personalized ad");
						rewardedVideoAd.loadAd(id, adBuilder.build());
					}
				}
			}
		});
	}

	/**
	 * Show a Rewarded Video
	 */
	public void showRewardedVideo() {
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				if (rewardedVideoAd.isLoaded()) {
					isLoading = false;
					rewardedVideoAd.show();
				}
			}
		});
	}


	/* Utils
	 * ********************************************************************** */

	/**
	 * Generate MD5 for the deviceID
	 * @param String s The string to generate de MD5
	 * @return String The MD5 generated
	 */
	private String md5(final String s)
	{
		try {
			// Create MD5 Hash
			MessageDigest digest = MessageDigest.getInstance("MD5");
			digest.update(s.getBytes());
			byte messageDigest[] = digest.digest();

			// Create Hex String
			StringBuffer hexString = new StringBuffer();
			for (int i=0; i<messageDigest.length; i++) {
				String h = Integer.toHexString(0xFF & messageDigest[i]);
				while (h.length() < 2) h = "0" + h;
				hexString.append(h);
			}
			return hexString.toString();
		} catch(NoSuchAlgorithmException e) {
			//Logger.logStackTrace(TAG,e);
		}
		return "";
	}

	/**
	 * Get the Device ID for AdMob
	 * @return String Device ID
	 */
	private String getAdmobDeviceId()
	{
		String android_id = Settings.Secure.getString(activity.getContentResolver(), Settings.Secure.ANDROID_ID);
		String deviceId = md5(android_id).toUpperCase(Locale.US);
		return deviceId;
	}

	/* Definitions
	 * ********************************************************************** */

	/**
	 * Initilization Singleton
	 * @param Activity The main activity
	 */
 	static public Godot.SingletonBase initialize(Activity activity)
 	{
 		return new GodotAdMob(activity);
 	}

	/**
	 * Constructor
	 * @param Activity Main activity
	 */
	public GodotAdMob(Activity p_activity) {
		registerClass("AdMob", new String[] {
			"init", "loadRewardedVideo", "showRewardedVideo",
			"requestConsent", "loadConsentForm", "showConsentForm",
			"isRequestLocationInEeaOrUnknown", "setConsent"
		});
		activity = p_activity;
	}
}
