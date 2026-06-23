# Build Information

## Latest Build: June 17, 2026 (Feedback System Complete)

### Build Details
- **APK Location:** `build/app/outputs/flutter-apk/app-release.apk`
- **APK Size:** 55.9MB
- **Build Type:** Release
- **Build Command:** `flutter clean && flutter pub get && flutter build apk --release`
- **Build Duration:** ~65 seconds
- **Status:** ✅ Successful

### New Features in This Build
1. **User Feedback System (Complete)**
   - Users can submit feedback through Profile → Feedback menu
   - 5 feedback types: General, Complaint, Suggestion, Bug Report, Compliment
   - Optional star rating and subject fields
   - Admin dashboard to view and manage all feedback
   - Real-time push notifications to admins on new feedback
   - Filter by status (Pending/Reviewed/Resolved) and type
   - Admin can add responses to feedback

### Files Changed
- `lib/views/screens/main/feedback_screen.dart` (NEW)
- `lib/views/screens/admin/view_feedback_screen.dart` (NEW)
- `lib/views/screens/main/profile_screen.dart` (Updated - added Feedback menu item)
- `lib/main.dart` (Updated - added /feedback route)
- `lib/views/screens/admin/admin_panel_screen.dart` (Updated - added User Feedback button)
- `lib/services/notification_service.dart` (Updated - added showFeedbackNotification method)
- `FEEDBACK_FEATURE.md` (NEW - comprehensive documentation)

---

## Previous Build: June 17, 2026

### Build Details
- **APK Location:** `build/app/outputs/flutter-apk/app-release.apk`
- **APK Size:** 55.6MB
- **Build Type:** Release
- **Build Command:** `flutter clean && flutter pub get && flutter build apk --release`
- **Status:** ✅ Successful

### Features Implemented
1. **Price Formatting Fix**
   - Fixed floating-point precision errors
   - All prices now display with exactly 2 decimal places
   - Created `CurrencyFormatter` utility class
   
2. **Push Notifications**
   - Firebase Cloud Messaging fully configured
   - 8 notification types implemented
   - Test notification screen for admins
   
3. **Revenue Report Filtering**
   - Filter by Day/Month/Year/All Time
   - Previous/Next navigation
   - Beautiful gradient banner
   
4. **Category Management Update**
   - Removed "Display Order" field
   - Alphabetical sorting by name

### Compile Errors Fixed
- ✅ Fixed auth_wrapper.dart const constructor error
- ✅ Removed unused imports from notification_service.dart

---

## Build Commands

### Clean Build
```bash
flutter clean && flutter pub get && flutter build apk --release
```

### Debug Build
```bash
flutter build apk --debug
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

---

## Known Warnings (Non-Critical)
- Gradle native-platform warnings (cosmetic, does not affect functionality)
- 63 packages have newer versions (constrained by current dependencies)

---

## Testing Checklist

### Feedback System:
- [ ] User can access Feedback from Profile screen
- [ ] User can submit feedback with all 5 types
- [ ] Star rating and subject fields are optional
- [ ] Message field validation works
- [ ] Feedback saves to Firestore correctly
- [ ] Admin receives push notification on new feedback
- [ ] Admin can view feedback dashboard
- [ ] Admin can filter feedback by status and type
- [ ] Admin can update feedback status
- [ ] Admin can add responses

### Previous Features:
- [x] Google Sign-In working
- [x] Notification system functional
- [x] Revenue reports with date filters
- [x] Category management (no display order)
- [x] Price formatting (2 decimals)
- [x] Admin panel accessible

---

## Admin Accounts
- `yongbeenm@gmail.com` (Primary Admin)
- `phanuseng124@gmail.com` (Secondary Admin, password: admin123)

---

## Firebase Configuration
- **SHA-1 Fingerprint:** `EE:EF:E5:47:E1:54:1E:7D:12:74:9D:E7:32:F9:F6:64:41:05:75:DA`
- **Google Services:** `android/app/google-services.json` (updated)
- **FCM:** Configured and tested

---

**Last Updated:** June 17, 2026  
**Build Status:** ✅ Ready for Testing
