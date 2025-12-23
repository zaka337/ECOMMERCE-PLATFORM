# Enable People API for Google Sign-In

## Error: People API has not been used or is disabled

If you're seeing this error, you need to enable the People API in Google Cloud Console.

## Quick Fix (2 minutes):

### Step 1: Open Google Cloud Console
1. Go to: https://console.cloud.google.com/
2. Make sure you're signed in with the same Google account used for Firebase

### Step 2: Select Your Project
1. At the top, click the project dropdown
2. Select: **satti-ecom** (project ID: 711521421896)

### Step 3: Enable People API
**Option A: Direct Link (Easiest)**
- Click this link: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=711521421896
- Click the **"ENABLE"** button
- Wait 1-2 minutes for it to activate

**Option B: Manual Steps**
1. In Google Cloud Console, go to **"APIs & Services"** → **"Library"**
2. Search for **"People API"**
3. Click on **"People API"**
4. Click **"ENABLE"** button
5. Wait 1-2 minutes for activation

### Step 4: Test Again
After enabling, try Google Sign-In again. The error should be gone!

---

## Alternative Solution (If you don't want to enable People API)

The code has been updated to use only the 'email' scope, which doesn't require the People API. However, you might not get the user's display name from Google Sign-In (it will come from Firebase Auth instead).

If you want full profile information (display name, photo), enable the People API using the steps above.

---

## Why This Happens

Google Sign-In with 'profile' scope requires the People API to fetch user profile information. Firebase projects don't automatically enable all Google APIs - you need to enable them manually in Google Cloud Console.

---

## Need Help?

If you still see errors after enabling:
1. Make sure you're in the correct project (satti-ecom)
2. Wait 2-3 minutes after enabling (API activation takes time)
3. Try refreshing your app
4. Check that the API shows as "Enabled" in Google Cloud Console

