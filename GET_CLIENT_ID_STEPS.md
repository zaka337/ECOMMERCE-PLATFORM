# 🔥 STEP-BY-STEP: Get Google Sign-In Web Client ID

## What I Need From You:
**The Web Client ID** - It looks like: `711521421896-xxxxxxxxxxxxx.apps.googleusercontent.com`

---

## Method 1: From Firebase Console (EASIEST)

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com/
2. **Sign in** with your Google account

### Step 2: Select Your Project
1. Click on your project: **satti-ecom**
2. If you don't see it, make sure you're signed in with the correct account

### Step 3: Go to Authentication
1. In the left sidebar, click **"Authentication"** (or the 🔐 icon)
2. Click on the **"Sign-in method"** tab at the top

### Step 4: Enable Google Sign-In (if not already enabled)
1. Find **"Google"** in the list of providers
2. Click on **"Google"**
3. Toggle the **"Enable"** switch to **ON** (blue)
4. Enter your **Project support email** (your email address)
5. Click **"Save"**

### Step 5: Get the Web Client ID
1. Still on the Google provider page
2. Scroll down to find **"Web SDK configuration"** section
3. Look for **"Web client ID"**
4. You should see something like: `711521421896-xxxxxxxxxxxxx.apps.googleusercontent.com`
5. **Click the copy icon** next to it (or select and copy the text)

**If you DON'T see "Web SDK configuration" section:**
- Make sure Google Sign-In is **Enabled** (Step 4)
- Make sure you have a **Web app** registered (see Method 2 below)
- Try refreshing the page
- Wait 1-2 minutes and refresh again

---

## Method 2: From Google Cloud Console (ALTERNATIVE)

### Step 1: Open Google Cloud Console
1. Go to: https://console.cloud.google.com/
2. **Sign in** with the same Google account you use for Firebase

### Step 2: Select Your Project
1. At the top, click the project dropdown
2. Select: **satti-ecom** (or search for it)

### Step 3: Go to Credentials
1. In the left sidebar, click **"APIs & Services"**
2. Click **"Credentials"**

### Step 4: Find or Create OAuth Client ID
1. Look for **"OAuth 2.0 Client IDs"** section
2. You should see clients listed (Web client, Android client, iOS client)
3. Find the one with type **"Web client"** or **"Web application"**
4. Click on it to see details
5. Copy the **"Client ID"** (it looks like: `711521421896-xxxxxxxxxxxxx.apps.googleusercontent.com`)

**If you DON'T see a Web client:**
1. Click **"+ CREATE CREDENTIALS"** at the top
2. Select **"OAuth client ID"**
3. If prompted, configure OAuth consent screen first (follow the prompts)
4. For **Application type**, select **"Web application"**
5. Give it a name like: "satti-ecom-web"
6. Under **Authorized JavaScript origins**, add:
   - `http://localhost`
   - `http://localhost:3000`
   - `http://localhost:5000`
   - `http://localhost:8080`
   - Your production domain (if you have one)
7. Click **"Create"**
8. Copy the **Client ID** that appears

---

## Method 3: Check if Web App is Registered in Firebase

If you can't find the Web Client ID, you might need to register your web app:

### Step 1: Go to Project Settings
1. In Firebase Console, click the **gear icon** ⚙️ next to "Project Overview"
2. Click **"Project settings"**

### Step 2: Check Your Apps
1. Scroll down to **"Your apps"** section
2. Look for a **Web app** (it has a `</>` icon)
3. If you see one, note the **App ID** (it's in the format: `1:711521421896:web:xxxxx`)

### Step 3: Add Web App (if not present)
1. If you DON'T see a Web app, click **"Add app"**
2. Click the **Web icon** `</>`
3. Register your app:
   - App nickname: `airdepart-web` (or any name)
   - **Don't check** "Also set up Firebase Hosting" (unless you want it)
4. Click **"Register app"**
5. You'll see Firebase config - you can copy it but **you don't need it** (we already have it)
6. Click **"Continue to console"**

### Step 4: Go Back to Authentication
1. Go back to **Authentication** → **Sign-in method** → **Google**
2. Now you should see the **"Web SDK configuration"** section
3. Copy the **Web client ID**

---

## Once You Have the Client ID:

**Send me the Client ID** and I'll update your code immediately!

It should look like: `711521421896-xxxxxxxxxxxxx.apps.googleusercontent.com`

---

## Quick Checklist:

- [ ] Signed into Firebase Console
- [ ] Selected project "satti-ecom"
- [ ] Went to Authentication → Sign-in method
- [ ] Enabled Google Sign-In provider
- [ ] Found "Web SDK configuration" section
- [ ] Copied the "Web client ID"
- [ ] Ready to paste it here!

---

## Still Can't Find It?

Tell me:
1. What do you see when you go to Authentication → Sign-in method → Google?
2. Do you see "Web SDK configuration" section?
3. What's the exact error or message you see?

I'll help you troubleshoot further!

