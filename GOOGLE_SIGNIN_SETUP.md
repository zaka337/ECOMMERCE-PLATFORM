# Google Sign-In Setup Guide

## Error: "The OAuth client was not found" / "invalid_client"

This error occurs because the Google Sign-In Web Client ID is not configured. Follow these steps to fix it:

## Step-by-Step Setup

### 1. Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **satti-ecom**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Toggle **Enable** to ON
6. Enter your **Project support email** (your email)
7. Click **Save**

### 2. Configure Web App (if not already done)

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Make sure you have a **Web app** registered
4. If not, click **Add app** → **Web** (</> icon)
5. Register your app with a nickname (e.g., "airdepart-web")
6. Copy the Firebase configuration (you already have this in `firebase_options.dart`)

### 3. Add Authorized Domains

1. Still in **Authentication** → **Sign-in method** → **Google**
2. Scroll down to **Authorized domains**
3. Make sure these domains are listed:
   - `localhost` (for local development)
   - Your production domain (if you have one)
   - `satti-ecom.firebaseapp.com` (Firebase hosting domain)

### 4. Get the Web Client ID

1. In **Authentication** → **Sign-in method** → **Google**
2. Scroll to **Web SDK configuration** section
3. You should see **Web client ID** (it looks like: `711521421896-xxxxxxxxxxxxx.apps.googleusercontent.com`)
4. **Copy this Web client ID**

### 5. Update Your Code

#### Option A: Update the constant in `lib/screens/auth_screen.dart`

Find this line near the top of the file:
```dart
const String? _googleSignInWebClientId = null; // TODO: Add your Web Client ID here
```

Replace `null` with your Web Client ID:
```dart
const String? _googleSignInWebClientId = '711521421896-xxxxxxxxxxxxx.apps.googleusercontent.com';
```

#### Option B: Update `web/index.html`

Find this line:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID_HERE">
```

Replace `YOUR_WEB_CLIENT_ID_HERE` with your Web Client ID:
```html
<meta name="google-signin-client_id" content="711521421896-xxxxxxxxxxxxx.apps.googleusercontent.com">
```

**Important:** You need to update BOTH places (the Dart code AND the HTML meta tag) with the same Web Client ID.

### 6. Restart Your App

After making these changes:
1. Stop your Flutter app
2. Run `flutter clean` (optional but recommended)
3. Run `flutter pub get`
4. Restart your app

## Troubleshooting

### If you don't see "Web SDK configuration" section:

1. Make sure Google Sign-In provider is **Enabled**
2. Make sure you have a **Web app** registered in Firebase
3. Try refreshing the Firebase Console page
4. Wait a few minutes - sometimes it takes time for the OAuth client to be created

### If you still get "invalid_client" error:

1. Double-check that the Client ID matches exactly (no extra spaces)
2. Make sure you're using the **Web client ID**, not the Android or iOS client ID
3. Verify that `localhost` is in your authorized domains
4. Try clearing your browser cache and cookies

### Alternative: Get Client ID from Google Cloud Console

If you can't find it in Firebase Console:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: **satti-ecom**
3. Go to **APIs & Services** → **Credentials**
4. Look for **OAuth 2.0 Client IDs**
5. Find the one with type **Web client** (or create one if it doesn't exist)
6. Copy the **Client ID**

## Need Help?

- Firebase Documentation: https://firebase.google.com/docs/auth/web/google-signin
- Flutter Google Sign-In: https://pub.dev/packages/google_sign_in

