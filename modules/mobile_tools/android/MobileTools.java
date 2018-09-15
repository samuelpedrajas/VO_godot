package org.godotengine.godot;

import java.io.File;

import android.content.Intent;
import android.app.*;
import android.net.Uri;
import android.content.ContextWrapper;
import android.support.v4.content.FileProvider;
import android.graphics.Point;
import android.util.DisplayMetrics;

import android.util.Log;

public class MobileTools extends Godot.SingletonBase
{

	private static final String TAG = "godot";
	private Activity activity;

	static public Godot.SingletonBase initialize(Activity p_activity)
	{
		return new MobileTools(p_activity);
	}
	
	public MobileTools(Activity p_activity)
	{
		registerClass("MobileTools", new String[]
		{
			"sharePic","shareText", "getDiagonal", "getDiagonalInches", "pixelsPerInch"
		});
		activity = p_activity;
		
	}

	public void shareText(String title, String subject, String text)
	{
		Log.d(TAG, "shareText called");
		Intent sharingIntent = new Intent(android.content.Intent.ACTION_SEND);
		sharingIntent.setType("text/plain");
		sharingIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, subject);
		sharingIntent.putExtra(android.content.Intent.EXTRA_TEXT, text);
		activity.startActivity(Intent.createChooser(sharingIntent, title)); 
	}
	
	public void sharePic(String path, String title, String subject, String text)
	{
		Log.d(TAG, "sharePic called");

		File f = new File(path);

		Uri uri;
		try {
			uri = FileProvider.getUriForFile(activity, activity.getPackageName(), f);
		} catch (IllegalArgumentException e) {
            Log.e(TAG, "The selected file can't be shared: " + path);
			return;
        }

		Intent shareIntent = new Intent(Intent.ACTION_SEND);
		shareIntent.setType("image/*");
		shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
		shareIntent.putExtra(Intent.EXTRA_TEXT, text);
		shareIntent.putExtra(Intent.EXTRA_STREAM, uri);
		shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
		activity.startActivity(Intent.createChooser(shareIntent, title));
	}


	public float getDiagonal() {
		Log.d(TAG, "getDiagonal called");
		Point size = new Point();
		activity.getWindowManager().getDefaultDisplay().getRealSize(size);
		return (float)Math.sqrt(Math.pow(size.x, 2) + Math.pow(size.y, 2));
	}


	public float getDiagonalInches() {
		Log.d(TAG, "getDiagonalInches called");

		DisplayMetrics dm = new DisplayMetrics();
		Point size = new Point();
		activity.getWindowManager().getDefaultDisplay().getMetrics(dm);
		activity.getWindowManager().getDefaultDisplay().getRealSize(size);

		double wi = (double)size.x / (double)dm.xdpi;
		double hi = (double)size.y / (double)dm.ydpi;

		return (float)Math.sqrt(Math.pow(wi, 2) + Math.pow(hi, 2));
	}

	public float pixelsPerInch() {
		DisplayMetrics dm = new DisplayMetrics();
		activity.getWindowManager().getDefaultDisplay().getMetrics(dm);
		return dm.densityDpi;
	}
}
