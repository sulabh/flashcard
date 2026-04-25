# 🚀 Google Play Store Upload Guide

This guide walks you through the process of uploading your signed Android App Bundle (`.aab`) files to the Google Play Console for distribution.

---

## 📌 Prerequisites
Before you begin, ensure you have:
1. A **Google Play Developer Account** (requires a one-time $25 registration fee).
2. Your generated and signed `.aab` files:
   - Free flavor: `build/app/outputs/bundle/freeRelease/app-free-release.aab`
   - Paid flavor: `build/app/outputs/bundle/paidRelease/app-paid-release.aab`

> [!IMPORTANT]
> Because the Free and Paid flavors have different Application IDs (`com.flashcardfree.app` and `com.flashcard.app`), **you must create them as two separate apps** in the Google Play Console.

---

## 🛠 Step 1: Create a New App in Play Console
1. Log in to the [Google Play Console](https://play.google.com/console).
2. Click on **All apps** in the left menu, then click the **Create app** button in the top right.
3. Fill in the required details:
   - **App name:** (e.g., "Flashcard App Free" or "Flashcard App Premium")
   - **Default language:** Select your primary language.
   - **App or game:** Select **App**.
   - **Free or paid:** Select **Free** (for the free flavor) or **Paid** (for the paid flavor).
4. Accept the Developer Program Policies and US export laws, then click **Create app**.

---

## ⚙️ Step 2: Complete the Initial App Setup
Before you can publish your app, you must complete the tasks in the **Dashboard** under the "Set up your app" section. This includes:
- **Set privacy policy:** Provide a link to your privacy policy.
- **App access:** Specify if parts of your app are restricted.
- **Ads:** Declare if your app contains ads (Yes for the Free version, No for the Paid version).
- **Content rating:** Fill out the questionnaire to receive a rating.
- **Target audience and content:** Specify your target age group.
- **News apps:** State whether your app is a news app.
- **COVID-19 contact tracing:** State your app's status.
- **Data safety:** Complete the data safety questionnaire (declare what data your app collects and shares).
- **Select an app category and provide contact details.**
- **Set up your store listing:** Upload your app icon, feature graphic, screenshots, and write your short and full descriptions.

---

## 📦 Step 3: Create a Release and Upload the `.aab`
You can upload your app to a testing track (Internal, Closed, or Open testing) or directly to Production. We recommend starting with **Internal Testing**.

1. In the left menu, scroll down to the **Release** section.
2. Select **Testing > Internal testing** (or **Production** if you are ready to publish).
3. Click the **Create new release** button.

### Google Play App Signing
When you create your first release, Google Play will ask you about App Signing.
- **Opt-in to Google Play App Signing** (Recommended). This allows Google to manage your app's signing key securely. The key you created earlier acts as your "Upload Key".

### Upload the App Bundle
1. In the **App bundles** section, click **Upload** or drag and drop your `.aab` file:
   - E.g., `app-free-release.aab`
2. Wait for the upload and processing to finish. Google will verify the signature and the package name.
3. **Release details:**
   - **Release name:** Usually auto-filled based on your version name (e.g., `1.0.0`).
   - **Release notes:** Add a description of what is new in this release for your users.

---

## 🚀 Step 4: Review and Rollout
1. Click **Save** at the bottom of the page.
2. Click **Review release**.
3. You may see some **Warnings** (yellow). These are usually okay to ignore for testing. If you see **Errors** (red), you must fix them before proceeding.
4. Click **Start rollout to Internal testing** (or Production).
5. Click **Rollout** on the confirmation dialog.

---

## 🔄 Repeat for the Second Flavor
Once you have successfully uploaded the first flavor (e.g., Free), go back to **All apps** (Step 1) and repeat the entire process to create a second, separate app for your Paid flavor, uploading the `app-paid-release.aab` file.

> [!TIP]
> Make sure to clearly differentiate the App Names, Icons, and Descriptions so users know which version they are downloading!
