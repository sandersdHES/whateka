import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Système de traduction simple basé sur des Maps. Pas de dépendance externe.
/// Utilisation : `S.of(context).homeTagline`
///
/// La langue est lue depuis user_metadata.locale (Supabase) à la connexion,
/// ou depuis SharedPreferences en fallback. Persistante cross-device.

enum AppLocale { fr, en, de }

class _Strings {
  // Marketing / branding
  final String appTagline;
  final String comingSoonTitle;
  final String comingSoonDescription;
  final String maintenanceFollowOn;
  final String maintenanceCodeLabel;
  final String maintenanceCodePlaceholder;
  final String maintenanceValidate;
  final String maintenanceLogout;
  final String successWelcome;
  final String successDescription;

  // Auth
  final String btnLogin;
  final String btnSignup;
  final String btnContinue;
  final String btnSubmit;
  final String btnCancel;
  final String btnSave;
  final String btnUpdate;
  final String btnFinish;
  final String loginTitle;
  final String loginEmailPlaceholder;
  final String loginPasswordPlaceholder;
  final String loginForgotPassword;
  final String loginNoAccount;
  final String signupTitle;
  final String signupNamePlaceholder;
  final String signupConfirmPasswordPlaceholder;
  final String signupHasAccount;
  final String forgotPasswordTitle;
  final String forgotPasswordSendLink;

  // Quiz
  final String quizQ1;
  final String quizQ2;
  final String quizQ3;
  final String quizQ4;
  final String quizQ5;
  final String quizMaxPicks;
  final String quizSolo;
  final String quizCouple;
  final String quizFamily;
  final String quizFriends;
  final String quizCatNature;
  final String quizCatCulture;
  final String quizCatRelax;
  final String quizCatSport;
  final String quizCatGastronomy;
  final String quizCatAdventure;
  final String quizCatFun;
  final String quizCatEvent;
  final String quizOutdoor;
  final String quizIndoor;
  final String quizAny;
  final String quizPriceFree;
  final String quizPriceLow;
  final String quizPriceMid;
  final String quizPriceHigh;
  final String quizPriceVeryHigh;
  final String quizDurationShort;
  final String quizDurationMid;
  final String quizDurationLong;
  final String quizLoading;

  // Map
  final String mapSearchPlaceholder;
  final String mapToggleAll;
  final String mapToggleLive;
  final String mapRecenter;
  final String mapSubmitTooltip;

  // Result IA
  final String resultTitle;
  final String resultSubtitle;
  final String resultViewMap;
  final String resultRetry;

  // Activity card / detail
  final String activityDuration;
  final String activityPrice;
  final String activityCategory;
  final String activityDescription;
  final String activityViewMap;
  final String activityWebsite;
  final String activityFavorite;

  // Bottom nav
  final String navMap;
  final String navQuiz;
  final String navFavorites;
  final String navProfile;

  // Profile
  final String profileTitle;
  final String profileSearches;
  final String profileMeters;
  final String profileLocation;
  final String profileLocationAuto;
  final String profileLocationManual;
  final String profileLocationRadius;
  final String profileLanguage;
  final String profileSignOut;
  final String profileDeleteAccount;
  final String profileDeleteAccountDialogTitle;
  final String profileDeleteAccountDialogBody;
  final String profileDeleteAccountConfirm;
  final String profileDeleteAccountSuccess;
  final String profileDeleteAccountError;

  // Submit activity
  final String submitTitle;
  final String submitName;
  final String submitLocation;
  final String submitDescription;
  final String submitCategories;
  final String submitDuration;
  final String submitPrice;
  final String submitFeatures;
  final String submitPhoto;
  final String submitGeolocate;
  final String submitConfirm;
  final String submitSuccess;

  // Common
  final String yes;
  final String no;
  final String loading;
  final String error;
  final String retry;
  final String close;
  final String search;
  final String save;

  // Features
  final String featureReservation;
  final String featureParking;
  final String featureRestrictedHours;
  final String featureMinParticipants;

  // Profil locations & radius
  final String profileLocationGps;
  final String profileLocationChooseCity;
  final String profileLocationChooseCityLabel;
  final String profileRadius;
  final String profileRadiusInfo;
  final String profileRadiusVaud;
  final String profileRadiusValais;
  final String profileSaveBtn;
  final String profileLocationModeAuto;
  final String profileLocationModeManual;

  // Submit activity additional
  final String submitNamePlaceholder;
  final String submitLocationPlaceholder;
  final String submitDescriptionPlaceholder;
  final String submitActivityUrlLabel;
  final String submitAddPhotos;
  final String submitTakePhoto;
  final String submitOrAddUrl;
  final String submitImageUrlPlaceholder;
  final String submitAdd;

  // AI result
  final String resultSuggestionsLabel;
  final String resultPeriodMorning;
  final String resultPeriodAfternoon;
  final String resultPeriodEvening;
  final String resultPeriodNight;
  final String resultRetake;

  // Empty / error states
  final String emptyNoActivities;
  final String emptyNoActivitiesHint;
  final String emptyNoFavorites;
  final String emptyNoFavoritesHint;
  final String errorOverloadTitle;
  final String errorGeneric;
  final String errorRemovingFavorite;
  final String errorWithDetails; // "Erreur: {0}"
  final String moreActivitiesBtn;
  final String moreIdeasBtn;

  // Login / signup validation
  final String validationRequired;
  final String validationEmailInvalid;
  final String validationMinChars;
  final String validationPasswordsMismatch;

  // Forgot password
  final String forgotPasswordPrompt;
  final String forgotPasswordEmailSent;
  final String forgotPasswordTooManyAttempts;
  final String forgotPasswordUnexpectedError;

  // Update password
  final String updatePasswordTitle;
  final String updatePasswordSubtitle;
  final String updatePasswordNewLabel;
  final String updatePasswordConfirmLabel;
  final String updatePasswordSuccess;
  final String updatePasswordCta;

  // Email verification
  final String verificationTitle;
  final String verificationHeading;
  final String verificationDescription;
  final String verificationBackToLogin;

  // Profile
  final String profileSection;
  final String profileFirstNameLabel;
  final String profileEmailLabel;
  final String profileCharacterLabel;
  final String profileEmailChangeNotice;
  final String profileUpdated;
  final String profileLocationAutoHint;

  // Quiz
  final String quizMaxChoicesError;
  final String quizContextError;
  final String quizBudgetCascadeHint;

  // Map
  // (already covered)

  // Single activity
  final String activityFeedbackPromptTitle;
  final String activityFeedbackPromptBody;
  final String activityFeedbackLater;
  final String activityFeedbackGive;
  final String activityNoUrl;
  final String activityCannotOpenUrl;
  final String activityOpenError;
  final String activityViewOnSite; // deprecated — kept for compat
  final String activitySite;       // deprecated — kept for compat
  final String activityViewSite;   // nouveau label CTA generique

  // Submit activity
  final String submitGeolocating;
  final String submitGeolocateError;
  final String submitNoPlaceFound;
  final String submitGeolocatePrompt;
  final String submitMapPreviewLabel;
  final String submitLatitudeLabel;
  final String submitLongitudeLabel;
  final String submitSeasonsLabel;
  final String submitSocialTagsLabel;
  final String submitTypeLabel;
  final String submitSeasonSpring;
  final String submitSeasonSummer;
  final String submitSeasonAutumn;
  final String submitSeasonWinter;
  final String submitSocialFamily;
  final String submitSocialCouple;
  final String submitSocialFriends;
  final String submitSocialSolo;
  final String submitIndoor;
  final String submitOutdoor;
  final String submitPriceFree;
  final String submitTitleRequired;
  final String submitLocationRequired;
  final String submitCategoryRequired;
  final String submitDescriptionRequired;
  final String submitLatitudeInvalid;
  final String submitLongitudeInvalid;
  final String submitDurationInvalid;
  final String submitSeasonRequired;
  final String submitSocialRequired;
  final String submitIndoorOutdoorRequired;
  final String submitPhotoReadError;
  final String submitUrlMustStartWithHttp;
  final String submitSubmitError;
  final String submitDurationHint;
  final String submitAdminReviewNotice;
  final String submitAddMorePhotos;

  // Favorites
  final String favoritesCountSingle;
  final String favoritesCountPlural;
  final String favoriteRemoveError;
  final String favoritesViewList;
  final String favoritesViewMap;
  final String favoritesEmptyMap;

  // Feedback hot
  final String feedbackTitle;
  final String feedbackHeader;
  final String feedbackThanks;
  final String feedbackSendError;
  final String feedbackNoQuestionsActive;
  final String feedbackQuestionnaireLoadError;
  final String feedbackRetry;
  final String feedbackSkip;
  final String feedbackSubmit;
  final String feedbackRatingNotAtAll;
  final String feedbackRatingFully;
  final String feedbackPlsAnswer;
  final String feedbackTextHint;
  // Titre quand le feedback n'est pas lie a une activite specifique
  // (popup force apres 5 quiz sans feedback).
  final String feedbackGeneralTitle;
  // Popup "feedback force" affiche au start du quiz si compteur >= 5.
  final String feedbackForcedDialogTitle;
  final String feedbackForcedDialogBody;
  final String feedbackForcedDialogClose;
  final String feedbackNoOptions;

  // Badge "Whateka Verified" : tap sur le badge -> dialog explicatif.
  final String whatekaVerifiedTitle;
  final String whatekaVerifiedMessage;
  final String whatekaVerifiedOk;

  // Home menu
  final String homeMenuGreeting; // "Bonjour {0}"
  final String homeMenuSignOutTooltip;
  final String homeMenuExploreTitle;
  final String homeMenuFindActivity;
  final String homeMenuMap;
  final String homeMenuFavorites;
  final String homeMenuDefaultUserName;

  // Loading widget
  final String loadingFunMessage;

  // AI service
  final String aiNoSuggestionsFound;
  final String aiServerOverloaded;
  final String aiUnknownError;
  final String aiErrorPrefix; // "Erreur IA"
  final String aiFetchError;

  // Maintenance
  final String maintenanceCodeIncorrect;
  final String maintenanceOrSeparator;

  // Password visibility & change-password (profile)
  final String passwordShow;
  final String passwordHide;
  final String profileChangePassword;
  final String profileChangePasswordTitle;
  final String profileChangePasswordCurrent;
  final String profileChangePasswordSuccess;
  final String profileChangePasswordCurrentInvalid;
  final String profileChangePasswordSamePwd;
  final String profileChangePasswordGenericError;

  // Subscription system (Phase 1)
  final String subscriptionTitle;
  final String subscriptionHeadline;
  final String subscriptionSubheadline;
  final String subscriptionMostPopular;
  final String subscriptionFreeTitle;
  final String subscriptionRegionalTitle;
  final String subscriptionEvasionTitle;
  final String subscriptionPriceFree;
  final String subscriptionPriceMonth;
  final String subscriptionTrialHint;
  final String subscriptionStartTrial;
  final String subscriptionCurrentPlan;
  final String subscriptionFreeFeature1;
  final String subscriptionFreeFeature2;
  final String subscriptionFreeFeature3;
  final String subscriptionFreeFeature4;
  final String subscriptionRegionalFeature1;
  final String subscriptionRegionalFeature2;
  final String subscriptionRegionalFeature3;
  final String subscriptionRegionalFeature4;
  final String subscriptionEvasionFeature1;
  final String subscriptionEvasionFeature2;
  final String subscriptionEvasionFeature3;
  final String subscriptionEvasionFeature4;
  final String subscriptionPromoCodeButton;
  final String subscriptionDisclaimer;
  final String subscriptionQuizUsage;
  final String subscriptionResetOn;
  final String subscriptionGoPremium;
  final String subscriptionGoEvasion;
  final String subscriptionRegionLabel;
  final String subscriptionExpiresOn;
  final String subscriptionStatusActive;
  final String subscriptionChangeRegionButton;
  final String subscriptionEvasionAllRegions;
  final String subscriptionThreeTiersTitle;   // ex: "3 formules disponibles"
  final String subscriptionCompareTiers;      // ex: "Comparer les abonnements"
  final String subscriptionYourTier;          // ex: "Votre abonnement"
  final String paywallTitle;
  final String paywallSubtitle;
  final String paywallRegionalSubtitle;
  final String paywallEvasionSubtitle;
  final String paywallPromoCodeButton;
  final String paywallResetHint;
  final String paywallLater;
  final String regionChangeTitle;
  final String regionChangeWarning;
  final String regionChangeNextOn;
  final String regionChangeConfirm;
  final String regionChangeSuccess;
  final String regionChangeErrorTooSoon;
  final String regionChangeErrorNotRegional;
  final String regionChangeErrorGeneric;
  final String promoCodeTitle;
  final String promoCodeHeadline;
  final String promoCodeSubheadline;
  final String promoCodeLabel;
  final String promoCodeApply;
  final String promoCodeSuccess;
  final String promoCodeErrorNotFound;
  final String promoCodeErrorInactive;
  final String promoCodeErrorExpired;
  final String promoCodeErrorExhausted;
  final String promoCodeErrorAlreadyRedeemed;
  final String promoCodeErrorAlreadyUsedAPromo;
  final String promoCodeErrorNotAuthenticated;
  final String promoCodeErrorGeneric;
  // Stripe (Phase 2)
  final String subscriptionMobileSoon;
  final String subscriptionManageMobileSoon;
  final String subscriptionCheckoutError;
  final String subscriptionPortalError;
  final String subscriptionManageLink;
  // Thanks-for-interest screen (remplace temporairement le checkout)
  final String thanksTitle;
  final String thanksHeadline;
  final String thanksIntro;
  final String thanksGiftLabel;
  final String thanksGiftValue;
  final String thanksGiftCode;
  final String thanksGiftBenefit;
  final String thanksApplyNow;
  final String thanksCopyCode;
  final String thanksCodeCopied;
  final String thanksSupportTitle;
  final String thanksSupportIntro;
  final String thanksSupportBullet1;
  final String thanksSupportBullet2;
  final String thanksSupportBullet3;
  final String thanksClose;
  // Section "Contactez-nous" dans profil
  final String contactSectionTitle;
  final String contactInstagramButton;
  final String contactInstagramSubtitle;
  final String contactMessageButton;
  final String contactMessageSubtitle;
  final String contactDialogTitle;
  final String contactDialogSubject;
  final String contactDialogMessage;
  final String contactDialogSend;
  final String contactDialogCancel;
  final String contactSendSuccess;
  final String contactSendError;
  final String contactMyMessagesButton;
  final String contactMyMessagesSubtitle;
  final String contactMyMessagesEmpty;
  final String contactMyMessagesEmptyHint;
  final String contactConversationsTitle;
  final String contactThreadTitle;
  final String contactThreadReplyPlaceholder;
  final String contactThreadSend;
  final String contactThreadReplySuccess;
  final String contactThreadReplyError;
  final String contactThreadTeamLabel;
  // Welcome dialog (1ere connexion d'un nouveau compte)
  final String welcomeTitle;
  final String welcomeIntro;
  final String welcomeDiscoveryTitle;
  final String welcomeDiscoveryBullet1;
  final String welcomeDiscoveryBullet2;
  final String welcomeDiscoveryBullet3;
  final String welcomePromoIntro;
  final String welcomeHasCode;
  final String welcomeLater;
  // v36 : option "Tout" + photo de profil
  final String profileRadiusAll;
  final String profilePhotoTapToChange;
  final String profilePhotoUpdated;
  final String profilePhotoError;

  const _Strings({
    required this.appTagline,
    required this.comingSoonTitle,
    required this.comingSoonDescription,
    required this.maintenanceFollowOn,
    required this.maintenanceCodeLabel,
    required this.maintenanceCodePlaceholder,
    required this.maintenanceValidate,
    required this.maintenanceLogout,
    required this.successWelcome,
    required this.successDescription,
    required this.btnLogin,
    required this.btnSignup,
    required this.btnContinue,
    required this.btnSubmit,
    required this.btnCancel,
    required this.btnSave,
    required this.btnUpdate,
    required this.btnFinish,
    required this.loginTitle,
    required this.loginEmailPlaceholder,
    required this.loginPasswordPlaceholder,
    required this.loginForgotPassword,
    required this.loginNoAccount,
    required this.signupTitle,
    required this.signupNamePlaceholder,
    required this.signupConfirmPasswordPlaceholder,
    required this.signupHasAccount,
    required this.forgotPasswordTitle,
    required this.forgotPasswordSendLink,
    required this.quizQ1,
    required this.quizQ2,
    required this.quizQ3,
    required this.quizQ4,
    required this.quizQ5,
    required this.quizMaxPicks,
    required this.quizSolo,
    required this.quizCouple,
    required this.quizFamily,
    required this.quizFriends,
    required this.quizCatNature,
    required this.quizCatCulture,
    required this.quizCatRelax,
    required this.quizCatSport,
    required this.quizCatGastronomy,
    required this.quizCatAdventure,
    required this.quizCatFun,
    required this.quizCatEvent,
    required this.quizOutdoor,
    required this.quizIndoor,
    required this.quizAny,
    required this.quizPriceFree,
    required this.quizPriceLow,
    required this.quizPriceMid,
    required this.quizPriceHigh,
    required this.quizPriceVeryHigh,
    required this.quizDurationShort,
    required this.quizDurationMid,
    required this.quizDurationLong,
    required this.quizLoading,
    required this.mapSearchPlaceholder,
    required this.mapToggleAll,
    required this.mapToggleLive,
    required this.mapRecenter,
    required this.mapSubmitTooltip,
    required this.resultTitle,
    required this.resultSubtitle,
    required this.resultViewMap,
    required this.resultRetry,
    required this.activityDuration,
    required this.activityPrice,
    required this.activityCategory,
    required this.activityDescription,
    required this.activityViewMap,
    required this.activityWebsite,
    required this.activityFavorite,
    required this.navMap,
    required this.navQuiz,
    required this.navFavorites,
    required this.navProfile,
    required this.profileTitle,
    required this.profileSearches,
    required this.profileMeters,
    required this.profileLocation,
    required this.profileLocationAuto,
    required this.profileLocationManual,
    required this.profileLocationRadius,
    required this.profileLanguage,
    required this.profileSignOut,
    required this.profileDeleteAccount,
    required this.profileDeleteAccountDialogTitle,
    required this.profileDeleteAccountDialogBody,
    required this.profileDeleteAccountConfirm,
    required this.profileDeleteAccountSuccess,
    required this.profileDeleteAccountError,
    required this.submitTitle,
    required this.submitName,
    required this.submitLocation,
    required this.submitDescription,
    required this.submitCategories,
    required this.submitDuration,
    required this.submitPrice,
    required this.submitFeatures,
    required this.submitPhoto,
    required this.submitGeolocate,
    required this.submitConfirm,
    required this.submitSuccess,
    required this.yes,
    required this.no,
    required this.loading,
    required this.error,
    required this.retry,
    required this.close,
    required this.search,
    required this.save,
    required this.featureReservation,
    required this.featureParking,
    required this.featureRestrictedHours,
    required this.featureMinParticipants,
    required this.profileLocationGps,
    required this.profileLocationChooseCity,
    required this.profileLocationChooseCityLabel,
    required this.profileRadius,
    required this.profileRadiusInfo,
    required this.profileRadiusVaud,
    required this.profileRadiusValais,
    required this.profileSaveBtn,
    required this.profileLocationModeAuto,
    required this.profileLocationModeManual,
    required this.submitNamePlaceholder,
    required this.submitLocationPlaceholder,
    required this.submitDescriptionPlaceholder,
    required this.submitActivityUrlLabel,
    required this.submitAddPhotos,
    required this.submitTakePhoto,
    required this.submitOrAddUrl,
    required this.submitImageUrlPlaceholder,
    required this.submitAdd,
    required this.resultSuggestionsLabel,
    required this.resultPeriodMorning,
    required this.resultPeriodAfternoon,
    required this.resultPeriodEvening,
    required this.resultPeriodNight,
    required this.resultRetake,
    required this.emptyNoActivities,
    required this.emptyNoActivitiesHint,
    required this.emptyNoFavorites,
    required this.emptyNoFavoritesHint,
    required this.errorOverloadTitle,
    required this.errorGeneric,
    required this.errorRemovingFavorite,
    required this.errorWithDetails,
    required this.moreActivitiesBtn,
    required this.moreIdeasBtn,
    required this.validationRequired,
    required this.validationEmailInvalid,
    required this.validationMinChars,
    required this.validationPasswordsMismatch,
    required this.forgotPasswordPrompt,
    required this.forgotPasswordEmailSent,
    required this.forgotPasswordTooManyAttempts,
    required this.forgotPasswordUnexpectedError,
    required this.updatePasswordTitle,
    required this.updatePasswordSubtitle,
    required this.updatePasswordNewLabel,
    required this.updatePasswordConfirmLabel,
    required this.updatePasswordSuccess,
    required this.updatePasswordCta,
    required this.verificationTitle,
    required this.verificationHeading,
    required this.verificationDescription,
    required this.verificationBackToLogin,
    required this.profileSection,
    required this.profileFirstNameLabel,
    required this.profileEmailLabel,
    required this.profileCharacterLabel,
    required this.profileEmailChangeNotice,
    required this.profileUpdated,
    required this.profileLocationAutoHint,
    required this.quizMaxChoicesError,
    required this.quizContextError,
    required this.quizBudgetCascadeHint,
    required this.activityFeedbackPromptTitle,
    required this.activityFeedbackPromptBody,
    required this.activityFeedbackLater,
    required this.activityFeedbackGive,
    required this.activityNoUrl,
    required this.activityCannotOpenUrl,
    required this.activityOpenError,
    required this.activityViewOnSite,
    required this.activitySite,
    required this.activityViewSite,
    required this.submitGeolocating,
    required this.submitGeolocateError,
    required this.submitNoPlaceFound,
    required this.submitGeolocatePrompt,
    required this.submitMapPreviewLabel,
    required this.submitLatitudeLabel,
    required this.submitLongitudeLabel,
    required this.submitSeasonsLabel,
    required this.submitSocialTagsLabel,
    required this.submitTypeLabel,
    required this.submitSeasonSpring,
    required this.submitSeasonSummer,
    required this.submitSeasonAutumn,
    required this.submitSeasonWinter,
    required this.submitSocialFamily,
    required this.submitSocialCouple,
    required this.submitSocialFriends,
    required this.submitSocialSolo,
    required this.submitIndoor,
    required this.submitOutdoor,
    required this.submitPriceFree,
    required this.submitTitleRequired,
    required this.submitLocationRequired,
    required this.submitCategoryRequired,
    required this.submitDescriptionRequired,
    required this.submitLatitudeInvalid,
    required this.submitLongitudeInvalid,
    required this.submitDurationInvalid,
    required this.submitSeasonRequired,
    required this.submitSocialRequired,
    required this.submitIndoorOutdoorRequired,
    required this.submitPhotoReadError,
    required this.submitUrlMustStartWithHttp,
    required this.submitSubmitError,
    required this.submitDurationHint,
    required this.submitAdminReviewNotice,
    required this.submitAddMorePhotos,
    required this.favoritesCountSingle,
    required this.favoritesCountPlural,
    required this.favoriteRemoveError,
    required this.favoritesViewList,
    required this.favoritesViewMap,
    required this.favoritesEmptyMap,
    required this.feedbackTitle,
    required this.feedbackHeader,
    required this.feedbackThanks,
    required this.feedbackSendError,
    required this.feedbackNoQuestionsActive,
    required this.feedbackQuestionnaireLoadError,
    required this.feedbackRetry,
    required this.feedbackSkip,
    required this.feedbackSubmit,
    required this.feedbackRatingNotAtAll,
    required this.feedbackRatingFully,
    required this.feedbackPlsAnswer,
    required this.feedbackGeneralTitle,
    required this.feedbackForcedDialogTitle,
    required this.feedbackForcedDialogBody,
    required this.feedbackForcedDialogClose,
    required this.whatekaVerifiedTitle,
    required this.whatekaVerifiedMessage,
    required this.whatekaVerifiedOk,
    required this.feedbackTextHint,
    required this.feedbackNoOptions,
    required this.homeMenuGreeting,
    required this.homeMenuSignOutTooltip,
    required this.homeMenuExploreTitle,
    required this.homeMenuFindActivity,
    required this.homeMenuMap,
    required this.homeMenuFavorites,
    required this.homeMenuDefaultUserName,
    required this.loadingFunMessage,
    required this.aiNoSuggestionsFound,
    required this.aiServerOverloaded,
    required this.aiUnknownError,
    required this.aiErrorPrefix,
    required this.aiFetchError,
    required this.maintenanceCodeIncorrect,
    required this.maintenanceOrSeparator,
    required this.passwordShow,
    required this.passwordHide,
    required this.profileChangePassword,
    required this.profileChangePasswordTitle,
    required this.profileChangePasswordCurrent,
    required this.profileChangePasswordSuccess,
    required this.profileChangePasswordCurrentInvalid,
    required this.profileChangePasswordSamePwd,
    required this.profileChangePasswordGenericError,
    required this.subscriptionTitle,
    required this.subscriptionHeadline,
    required this.subscriptionSubheadline,
    required this.subscriptionMostPopular,
    required this.subscriptionFreeTitle,
    required this.subscriptionRegionalTitle,
    required this.subscriptionEvasionTitle,
    required this.subscriptionPriceFree,
    required this.subscriptionPriceMonth,
    required this.subscriptionTrialHint,
    required this.subscriptionStartTrial,
    required this.subscriptionCurrentPlan,
    required this.subscriptionFreeFeature1,
    required this.subscriptionFreeFeature2,
    required this.subscriptionFreeFeature3,
    required this.subscriptionFreeFeature4,
    required this.subscriptionRegionalFeature1,
    required this.subscriptionRegionalFeature2,
    required this.subscriptionRegionalFeature3,
    required this.subscriptionRegionalFeature4,
    required this.subscriptionEvasionFeature1,
    required this.subscriptionEvasionFeature2,
    required this.subscriptionEvasionFeature3,
    required this.subscriptionEvasionFeature4,
    required this.subscriptionPromoCodeButton,
    required this.subscriptionDisclaimer,
    required this.subscriptionQuizUsage,
    required this.subscriptionResetOn,
    required this.subscriptionGoPremium,
    required this.subscriptionGoEvasion,
    required this.subscriptionRegionLabel,
    required this.subscriptionExpiresOn,
    required this.subscriptionStatusActive,
    required this.subscriptionChangeRegionButton,
    required this.subscriptionEvasionAllRegions,
    required this.subscriptionThreeTiersTitle,
    required this.subscriptionCompareTiers,
    required this.subscriptionYourTier,
    required this.paywallTitle,
    required this.paywallSubtitle,
    required this.paywallRegionalSubtitle,
    required this.paywallEvasionSubtitle,
    required this.paywallPromoCodeButton,
    required this.paywallResetHint,
    required this.paywallLater,
    required this.regionChangeTitle,
    required this.regionChangeWarning,
    required this.regionChangeNextOn,
    required this.regionChangeConfirm,
    required this.regionChangeSuccess,
    required this.regionChangeErrorTooSoon,
    required this.regionChangeErrorNotRegional,
    required this.regionChangeErrorGeneric,
    required this.promoCodeTitle,
    required this.promoCodeHeadline,
    required this.promoCodeSubheadline,
    required this.promoCodeLabel,
    required this.promoCodeApply,
    required this.promoCodeSuccess,
    required this.promoCodeErrorNotFound,
    required this.promoCodeErrorInactive,
    required this.promoCodeErrorExpired,
    required this.promoCodeErrorExhausted,
    required this.promoCodeErrorAlreadyRedeemed,
    required this.promoCodeErrorAlreadyUsedAPromo,
    required this.promoCodeErrorNotAuthenticated,
    required this.promoCodeErrorGeneric,
    required this.subscriptionMobileSoon,
    required this.subscriptionManageMobileSoon,
    required this.subscriptionCheckoutError,
    required this.subscriptionPortalError,
    required this.subscriptionManageLink,
    required this.thanksTitle,
    required this.thanksHeadline,
    required this.thanksIntro,
    required this.thanksGiftLabel,
    required this.thanksGiftValue,
    required this.thanksGiftCode,
    required this.thanksGiftBenefit,
    required this.thanksApplyNow,
    required this.thanksCopyCode,
    required this.thanksCodeCopied,
    required this.thanksSupportTitle,
    required this.thanksSupportIntro,
    required this.thanksSupportBullet1,
    required this.thanksSupportBullet2,
    required this.thanksSupportBullet3,
    required this.thanksClose,
    required this.contactSectionTitle,
    required this.contactInstagramButton,
    required this.contactInstagramSubtitle,
    required this.contactMessageButton,
    required this.contactMessageSubtitle,
    required this.contactDialogTitle,
    required this.contactDialogSubject,
    required this.contactDialogMessage,
    required this.contactDialogSend,
    required this.contactDialogCancel,
    required this.contactSendSuccess,
    required this.contactSendError,
    required this.contactMyMessagesButton,
    required this.contactMyMessagesSubtitle,
    required this.contactMyMessagesEmpty,
    required this.contactMyMessagesEmptyHint,
    required this.contactConversationsTitle,
    required this.contactThreadTitle,
    required this.contactThreadReplyPlaceholder,
    required this.contactThreadSend,
    required this.contactThreadReplySuccess,
    required this.contactThreadReplyError,
    required this.contactThreadTeamLabel,
    required this.welcomeTitle,
    required this.welcomeIntro,
    required this.welcomeDiscoveryTitle,
    required this.welcomeDiscoveryBullet1,
    required this.welcomeDiscoveryBullet2,
    required this.welcomeDiscoveryBullet3,
    required this.welcomePromoIntro,
    required this.welcomeHasCode,
    required this.welcomeLater,
    required this.profileRadiusAll,
    required this.profilePhotoTapToChange,
    required this.profilePhotoUpdated,
    required this.profilePhotoError,
  });
}

const _Strings _fr = _Strings(
  appTagline: "L'activité te trouvera !",
  comingSoonTitle: "Whateka arrive bientôt",
  comingSoonDescription: "Notre app est en cours de finalisation. Suis-nous pour être informé du lancement.",
  maintenanceFollowOn: "Suivre",
  maintenanceCodeLabel: "Vous avez un code d'accès ?",
  maintenanceCodePlaceholder: "••••••",
  maintenanceValidate: "Valider",
  maintenanceLogout: "Se déconnecter",
  successWelcome: "Bienvenue !",
  successDescription: "Accès accordé. Place à l'aventure.",
  btnLogin: "Se connecter",
  btnSignup: "Créer un compte",
  btnContinue: "Continuer",
  btnSubmit: "Valider",
  btnCancel: "Annuler",
  btnSave: "Enregistrer",
  btnUpdate: "Mettre à jour",
  btnFinish: "Terminer",
  loginTitle: "Bon retour parmi nous",
  loginEmailPlaceholder: "Adresse e-mail",
  loginPasswordPlaceholder: "Mot de passe",
  loginForgotPassword: "Mot de passe oublié ?",
  loginNoAccount: "Pas encore de compte ?",
  signupTitle: "Créer un compte",
  signupNamePlaceholder: "Prénom",
  signupConfirmPasswordPlaceholder: "Confirmer le mot de passe",
  signupHasAccount: "Déjà un compte ?",
  forgotPasswordTitle: "Mot de passe oublié",
  forgotPasswordSendLink: "Envoyer le lien",
  quizQ1: "Avec qui tu y vas ?",
  quizQ2: "Quelle est votre envie du moment ?",
  quizQ3: "Envie d'extérieur ou d'intérieur ?",
  quizQ4: "Quel budget ?",
  quizQ5: "Combien de temps as-tu ?",
  quizMaxPicks: "Jusqu'à 3 choix",
  quizSolo: "Solo",
  quizCouple: "En couple",
  quizFamily: "En famille",
  quizFriends: "Entre amis",
  quizCatNature: "Nature",
  quizCatCulture: "Culture",
  quizCatRelax: "Détente",
  quizCatSport: "Sport",
  quizCatGastronomy: "Gourmandise",
  quizCatAdventure: "Aventure",
  quizCatFun: "Fun",
  quizCatEvent: "Événement",
  quizOutdoor: "Outdoor",
  quizIndoor: "Indoor",
  quizAny: "Egal",
  quizPriceFree: "Gratuit",
  quizPriceLow: "1–20 CHF",
  quizPriceMid: "20–50 CHF",
  quizPriceHigh: "50–100 CHF",
  quizPriceVeryHigh: "100+ CHF",
  quizDurationShort: "Quelques h.",
  quizDurationMid: "Demi-journée",
  quizDurationLong: "Journée",
  quizLoading: "Chargement...",
  mapSearchPlaceholder: "Rechercher une activité",
  mapToggleAll: "Tout",
  mapToggleLive: "Live",
  mapRecenter: "Recentrer",
  mapSubmitTooltip: "Proposer une activité",
  resultTitle: "Voici nos suggestions",
  resultSubtitle: "Activités sélectionnées pour toi",
  resultViewMap: "Voir sur la carte",
  resultRetry: "Recommencer",
  activityDuration: "Durée",
  activityPrice: "Prix",
  activityCategory: "Catégorie",
  activityDescription: "Description",
  activityViewMap: "Voir sur la carte",
  activityWebsite: "Site web",
  activityFavorite: "Favori",
  navMap: "Carte",
  navQuiz: "Quiz",
  navFavorites: "Favoris",
  navProfile: "Profil",
  profileTitle: "Profil",
  profileSearches: "Recherches",
  profileMeters: "Mètres parcourus",
  profileLocation: "Localisation",
  profileLocationAuto: "Automatique",
  profileLocationManual: "Manuelle",
  profileLocationRadius: "Rayon",
  profileLanguage: "Langue",
  profileSignOut: "Se déconnecter",
  profileDeleteAccount: "Supprimer mon compte",
  profileDeleteAccountDialogTitle: "Supprimer le compte",
  profileDeleteAccountDialogBody: "Cette action est irréversible. Toutes vos données seront définitivement supprimées.",
  profileDeleteAccountConfirm: "Supprimer définitivement",
  profileDeleteAccountSuccess: "Votre compte a été supprimé.",
  profileDeleteAccountError: "Erreur lors de la suppression du compte.",
  submitTitle: "Proposer une activité",
  submitName: "Nom de l'activité",
  submitLocation: "Lieu",
  submitDescription: "Description",
  submitCategories: "Catégories",
  submitDuration: "Durée",
  submitPrice: "Prix",
  submitFeatures: "Informations utiles",
  submitPhoto: "Photo",
  submitGeolocate: "Localiser automatiquement",
  submitConfirm: "Soumettre",
  submitSuccess: "Merci ! Ton activité a été soumise.",
  yes: "Oui",
  no: "Non",
  loading: "Chargement...",
  error: "Une erreur est survenue",
  retry: "Réessayer",
  close: "Fermer",
  search: "Rechercher",
  save: "Enregistrer",
  featureReservation: "Réservation nécessaire",
  featureParking: "Parking",
  featureRestrictedHours: "Horaires restreints",
  featureMinParticipants: "Minimum de participants",
  profileLocationGps: "GPS",
  profileLocationChooseCity: "Choisir une ville",
  profileLocationChooseCityLabel: "Choisissez votre ville",
  profileRadius: "Rayon de recherche",
  profileRadiusInfo: "Le questionnaire limitera les activités à cette zone.",
  profileRadiusVaud: "Vaud complet",
  profileRadiusValais: "Valais complet",
  profileSaveBtn: "Sauvegarder",
  profileLocationModeAuto: "Automatique",
  profileLocationModeManual: "Manuelle",
  submitNamePlaceholder: "Ex : Bains thermaux de Saillon",
  submitLocationPlaceholder: "Ex : Saillon",
  submitDescriptionPlaceholder: "Décrivez l'activité en quelques phrases...",
  submitActivityUrlLabel: "URL de l'activité",
  submitAddPhotos: "Ajouter des photos",
  submitTakePhoto: "Prendre une photo",
  submitOrAddUrl: "Ou coller une URL d'image",
  submitImageUrlPlaceholder: "https://exemple.ch/photo.jpg",
  submitAdd: "Ajouter",
  resultSuggestionsLabel: "suggestions",
  resultPeriodMorning: "ce matin",
  resultPeriodAfternoon: "cet après-midi",
  resultPeriodEvening: "ce soir",
  resultPeriodNight: "cette nuit",
  resultRetake: "Refaire le quiz",
  emptyNoActivities: "Aucune activité trouvée",
  emptyNoActivitiesHint: "Essayez de modifier vos critères de recherche",
  emptyNoFavorites: "Aucun favori pour le moment",
  emptyNoFavoritesHint: "Tapez sur le cœur d'une activité pour la retrouver ici.",
  errorOverloadTitle: "Forte affluence",
  errorGeneric: "Une erreur est survenue",
  errorRemovingFavorite: "Erreur lors de la suppression",
  errorWithDetails: "Erreur",
  moreActivitiesBtn: "Plus d'activités",
  moreIdeasBtn: "Plus d'idées",
  validationRequired: "Requis",
  validationEmailInvalid: "Email invalide",
  validationMinChars: "Min 6 caractères",
  validationPasswordsMismatch: "Les mots de passe ne correspondent pas",
  forgotPasswordPrompt: "Entrez votre email pour recevoir un lien de réinitialisation.",
  forgotPasswordEmailSent: "Email de réinitialisation envoyé",
  forgotPasswordTooManyAttempts: "Trop de tentatives. Veuillez patienter.",
  forgotPasswordUnexpectedError: "Erreur inattendue",
  updatePasswordTitle: "Nouveau mot de passe",
  updatePasswordSubtitle: "Définissez votre nouveau mot de passe",
  updatePasswordNewLabel: "Nouveau mot de passe",
  updatePasswordConfirmLabel: "Confirmer le mot de passe",
  updatePasswordSuccess: "Mot de passe mis à jour avec succès",
  updatePasswordCta: "Mettre à jour",
  verificationTitle: "Vérification",
  verificationHeading: "Vérifiez votre email",
  verificationDescription: "Un lien de confirmation a été envoyé à votre adresse email. Veuillez cliquer dessus pour activer votre compte.",
  verificationBackToLogin: "Retour à la connexion",
  profileSection: "Préférences",
  profileFirstNameLabel: "Prénom",
  profileEmailLabel: "Email",
  profileCharacterLabel: "Personnage",
  profileEmailChangeNotice: "Un email de vérification a été envoyé pour le changement d'adresse.",
  profileUpdated: "Profil mis à jour",
  profileLocationAutoHint: "L'app utilise votre position GPS automatiquement.",
  quizMaxChoicesError: "Maximum {0} choix possible(s)",
  quizContextError: "Erreur lors de la récupération du contexte",
  quizBudgetCascadeHint: "Les budgets inférieurs sont inclus automatiquement (désélectionnables).",
  activityFeedbackPromptTitle: "Votre avis compte",
  activityFeedbackPromptBody: "Souhaitez-vous partager votre expérience avec cette activité ?",
  activityFeedbackLater: "Plus tard",
  activityFeedbackGive: "Donner mon avis",
  activityNoUrl: "Aucune URL disponible pour cette activité",
  activityCannotOpenUrl: "Impossible d'ouvrir l'URL",
  activityOpenError: "Erreur lors de l'ouverture du lien",
  activityViewOnSite: "Voir sur",
  activitySite: "le site",
  activityViewSite: "Voir le site",
  submitGeolocating: "Localisation...",
  submitGeolocateError: "Erreur géolocalisation",
  submitNoPlaceFound: "Aucun lieu trouvé",
  submitGeolocatePrompt: "Remplis au moins le titre et le lieu pour la localisation auto.",
  submitMapPreviewLabel: "Aperçu sur la carte (tape pour ajuster)",
  submitLatitudeLabel: "Latitude",
  submitLongitudeLabel: "Longitude",
  submitSeasonsLabel: "Saisons",
  submitSocialTagsLabel: "Tags sociaux",
  submitTypeLabel: "Type (Indoor / Outdoor — au moins un)",
  submitSeasonSpring: "Printemps",
  submitSeasonSummer: "Été",
  submitSeasonAutumn: "Automne",
  submitSeasonWinter: "Hiver",
  submitSocialFamily: "Famille",
  submitSocialCouple: "Couple",
  submitSocialFriends: "Amis",
  submitSocialSolo: "Solo",
  submitIndoor: "Indoor",
  submitOutdoor: "Outdoor",
  submitPriceFree: "Gratuit",
  submitTitleRequired: "Le titre est requis.",
  submitLocationRequired: "Le lieu est requis.",
  submitCategoryRequired: "Sélectionne au moins une catégorie.",
  submitDescriptionRequired: "La description est requise.",
  submitLatitudeInvalid: "Latitude invalide (-90 à 90).",
  submitLongitudeInvalid: "Longitude invalide (-180 à 180).",
  submitDurationInvalid: "Durée invalide.",
  submitSeasonRequired: "Sélectionne au moins une saison.",
  submitSocialRequired: "Sélectionne au moins un tag social.",
  submitIndoorOutdoorRequired: "Indoor ou Outdoor doit être coché.",
  submitPhotoReadError: "Impossible de lire les photos",
  submitUrlMustStartWithHttp: "L'URL doit commencer par http(s)://",
  submitSubmitError: "Erreur lors de la soumission",
  submitDurationHint: "Ex : 2.5",
  submitAdminReviewNotice: "Votre proposition sera vérifiée par un administrateur avant publication.",
  submitAddMorePhotos: "Ajouter d'autres photos",
  favoritesCountSingle: "activité",
  favoritesCountPlural: "activités",
  favoriteRemoveError: "Erreur lors de la suppression",
  favoritesViewList: "Liste",
  favoritesViewMap: "Carte",
  favoritesEmptyMap: "Tape sur un pin pour ouvrir l'activité.",
  feedbackTitle: "Votre avis compte !",
  feedbackHeader: "Merci de prendre quelques instants pour nous donner votre avis !",
  feedbackThanks: "Merci pour votre feedback !",
  feedbackSendError: "Erreur lors de l'envoi du feedback",
  feedbackNoQuestionsActive: "Aucune question de feedback n'est active pour le moment. Merci !",
  feedbackQuestionnaireLoadError: "Impossible de charger le questionnaire.",
  feedbackRetry: "Réessayer",
  feedbackSkip: "Passer",
  feedbackSubmit: "Envoyer",
  feedbackRatingNotAtAll: "Pas du tout",
  feedbackRatingFully: "Tout à fait",
  feedbackPlsAnswer: "Merci de répondre à",
  feedbackTextHint: "Votre réponse...",
  feedbackNoOptions: "(Aucune option configurée)",
  feedbackGeneralTitle: "Votre avis sur Whateka",
  feedbackForcedDialogTitle: "Votre avis nous intéresse !",
  feedbackForcedDialogBody: "Vous avez fait plusieurs quiz sans nous donner votre avis. Pouvez-vous prendre 1 minute pour nous aider à améliorer Whateka ?",
  feedbackForcedDialogClose: "Plus tard",
  whatekaVerifiedTitle: "Activité certifiée Whateka",
  whatekaVerifiedMessage: "Cette activité a été testée et approuvée par l'équipe Whateka.",
  whatekaVerifiedOk: "OK",
  homeMenuGreeting: "Bonjour",
  homeMenuSignOutTooltip: "Se déconnecter",
  homeMenuExploreTitle: "Commence à explorer avec WHATEKA !",
  homeMenuFindActivity: "Trouver mon activité du jour !",
  homeMenuMap: "Carte",
  homeMenuFavorites: "Activités likées",
  homeMenuDefaultUserName: "Voyageur",
  loadingFunMessage: "Nous concoctons votre sélection...",
  aiNoSuggestionsFound: "Aucune suggestion trouvée pour ces critères.",
  aiServerOverloaded: "Le serveur IA est actuellement surchargé. Veuillez réessayer dans quelques instants.",
  aiUnknownError: "Erreur inconnue",
  aiErrorPrefix: "Erreur IA",
  aiFetchError: "Erreur lors de la récupération des recommandations IA",
  maintenanceCodeIncorrect: "Code incorrect",
  maintenanceOrSeparator: "ou",
  passwordShow: "Afficher le mot de passe",
  passwordHide: "Masquer le mot de passe",
  profileChangePassword: "Changer de mot de passe",
  profileChangePasswordTitle: "Changer de mot de passe",
  profileChangePasswordCurrent: "Mot de passe actuel",
  profileChangePasswordSuccess: "Mot de passe modifié avec succès",
  profileChangePasswordCurrentInvalid: "Mot de passe actuel incorrect",
  profileChangePasswordSamePwd: "Le nouveau mot de passe doit être différent de l'ancien",
  profileChangePasswordGenericError: "Impossible de changer le mot de passe",
  subscriptionTitle: "Abonnement",
  subscriptionHeadline: "Choisis ton plan",
  subscriptionSubheadline: "Débloque toutes les activités de Vaud et Valais.",
  subscriptionMostPopular: "LE PLUS POPULAIRE",
  subscriptionFreeTitle: "Découverte",
  subscriptionRegionalTitle: "Régional",
  subscriptionEvasionTitle: "Évasion",
  subscriptionPriceFree: "Gratuit",
  subscriptionPriceMonth: "CHF / mois",
  subscriptionTrialHint: "7 jours d'essai gratuit",
  subscriptionStartTrial: "Démarrer l'essai",
  subscriptionCurrentPlan: "Plan actuel",
  subscriptionFreeFeature1: "5 quiz tous les 30 jours",
  subscriptionFreeFeature2: "Carte complète",
  subscriptionFreeFeature3: "Favoris illimités",
  subscriptionFreeFeature4: "Proposer une activité",
  subscriptionRegionalFeature1: "Quiz illimités",
  subscriptionRegionalFeature2: "Vaud OU Valais",
  subscriptionRegionalFeature3: "Recommandations personnalisées",
  subscriptionRegionalFeature4: "Changement de canton 1× / 30 jours",
  subscriptionEvasionFeature1: "Tout Régional inclus",
  subscriptionEvasionFeature2: "Vaud ET Valais",
  subscriptionEvasionFeature3: "Activités en avant-première",
  subscriptionEvasionFeature4: "Badge Premium",
  subscriptionPromoCodeButton: "J'ai un code promo",
  subscriptionDisclaimer: "Annulable à tout moment.",
  subscriptionQuizUsage: "{used} / {limit} quiz utilisés",
  subscriptionResetOn: "Reset le {date}",
  subscriptionGoPremium: "Passer Premium 🚀",
  subscriptionGoEvasion: "Passer à Évasion (5 CHF)",
  subscriptionRegionLabel: "Canton actuel",
  subscriptionExpiresOn: "Renouvellement le {date}",
  subscriptionStatusActive: "ACTIF",
  subscriptionChangeRegionButton: "Changer de canton",
  subscriptionEvasionAllRegions: "Toutes régions débloquées (Vaud + Valais)",
  subscriptionThreeTiersTitle: "3 formules d'abonnement",
  subscriptionCompareTiers: "Comparer les abonnements",
  subscriptionYourTier: "Votre formule actuelle",
  paywallTitle: "Tu as utilisé tes 5 quiz",
  paywallSubtitle: "Continue à découvrir Vaud et Valais avec un abonnement.",
  paywallRegionalSubtitle: "Quiz illimités · 1 canton",
  paywallEvasionSubtitle: "Quiz illimités · Vaud + Valais",
  paywallPromoCodeButton: "J'ai un code promo",
  paywallResetHint: "Reset gratuit le {date}",
  paywallLater: "Plus tard",
  regionChangeTitle: "Changer de canton",
  regionChangeWarning: "Tu pourras à nouveau changer dans 30 jours.",
  regionChangeNextOn: "Prochain changement possible le {date}",
  regionChangeConfirm: "Confirmer le changement",
  regionChangeSuccess: "Canton mis à jour",
  regionChangeErrorTooSoon: "Tu dois attendre 30 jours entre deux changements.",
  regionChangeErrorNotRegional: "Cette option n'est disponible qu'avec l'abonnement Régional.",
  regionChangeErrorGeneric: "Impossible de changer de canton pour le moment.",
  promoCodeTitle: "Code promo",
  promoCodeHeadline: "Active ton code",
  promoCodeSubheadline: "Saisis ton code promo pour débloquer ton abonnement.",
  promoCodeLabel: "Code",
  promoCodeApply: "Activer",
  promoCodeSuccess: "Code activé : {months} mois offerts !",
  promoCodeErrorNotFound: "Code introuvable.",
  promoCodeErrorInactive: "Ce code n'est plus actif.",
  promoCodeErrorExpired: "Ce code a expiré.",
  promoCodeErrorExhausted: "Ce code a atteint sa limite d'utilisations.",
  promoCodeErrorAlreadyRedeemed: "Tu as déjà utilisé ce code.",
  promoCodeErrorAlreadyUsedAPromo: "Tu as déjà utilisé un code promo sur ce compte. Un seul code par compte est autorisé.",
  promoCodeErrorNotAuthenticated: "Connecte-toi d'abord.",
  promoCodeErrorGeneric: "Impossible d'activer ce code.",
  subscriptionMobileSoon: "Le paiement sur mobile arrive bientôt. En attendant, abonne-toi depuis whateka.ch ou utilise un code promo.",
  subscriptionManageMobileSoon: "La gestion sur mobile arrive bientôt. En attendant, va sur whateka.ch pour gérer ton abonnement.",
  subscriptionCheckoutError: "Impossible de démarrer le paiement. Réessaie dans quelques instants.",
  subscriptionPortalError: "Impossible d'ouvrir la gestion de l'abonnement.",
  subscriptionManageLink: "Gérer / annuler mon abonnement →",
  thanksTitle: "Merci de ton intérêt 💙",
  thanksHeadline: "Whateka, c'est encore tout jeune",
  thanksIntro: "Ton envie de soutenir l'app nous touche énormément. Pour l'instant, l'équipe Whateka ne fait pas encore payer les abonnements — on est en phase de lancement et on préfère que tu profites de tout, gratuitement.",
  thanksGiftLabel: "Ton cadeau",
  thanksGiftValue: "3 mois Évasion offerts",
  thanksGiftCode: "WA2026",
  thanksGiftBenefit: "Accès complet à Vaud + Valais, quiz illimités, avant-premières — sans rien payer.",
  thanksApplyNow: "Activer mon accès",
  thanksCopyCode: "Copier le code",
  thanksCodeCopied: "Code copié dans le presse-papier",
  thanksSupportTitle: "Comment nous aider en retour",
  thanksSupportIntro: "Le plus grand soutien que tu peux nous apporter aujourd'hui :",
  thanksSupportBullet1: "Recommander Whateka autour de toi (amis, famille, réseaux)",
  thanksSupportBullet2: "Suggérer de nouvelles activités via le bouton « Proposer une activité »",
  thanksSupportBullet3: "Continuer à utiliser l'app et nous envoyer tes feedbacks",
  thanksClose: "Plus tard",
  contactSectionTitle: "Contactez-nous",
  contactInstagramButton: "Suivez-nous sur Instagram",
  contactInstagramSubtitle: "@whateka.ch",
  contactMessageButton: "Nous envoyer un message",
  contactMessageSubtitle: "Question, suggestion, bug…",
  contactDialogTitle: "Nouveau message",
  contactDialogSubject: "Sujet",
  contactDialogMessage: "Votre message",
  contactDialogSend: "Envoyer",
  contactDialogCancel: "Annuler",
  contactSendSuccess: "Message envoyé ! L'équipe Whateka revient vers toi rapidement.",
  contactSendError: "Impossible d'envoyer le message. Réessaie dans un instant.",
  contactMyMessagesButton: "Mes messages",
  contactMyMessagesSubtitle: "Tes conversations avec l'équipe",
  contactMyMessagesEmpty: "Aucune conversation pour l'instant",
  contactMyMessagesEmptyHint: "Quand tu nous envoies un message, il apparaîtra ici avec nos réponses.",
  contactConversationsTitle: "Mes messages",
  contactThreadTitle: "Conversation",
  contactThreadReplyPlaceholder: "Écris ta réponse…",
  contactThreadSend: "Envoyer",
  contactThreadReplySuccess: "Message envoyé",
  contactThreadReplyError: "Impossible d'envoyer pour le moment",
  contactThreadTeamLabel: "Équipe Whateka",
  welcomeTitle: "Bienvenue sur Whateka 👋",
  welcomeIntro: "Tu fais maintenant partie de l'aventure. Voici comment ça marche :",
  welcomeDiscoveryTitle: "Tu commences en mode Découverte",
  welcomeDiscoveryBullet1: "5 quiz tous les 30 jours pour découvrir des activités",
  welcomeDiscoveryBullet2: "Carte complète et favoris illimités",
  welcomeDiscoveryBullet3: "Possibilité de proposer une activité",
  welcomePromoIntro: "Tu as un code promo ? Active-le maintenant pour 3 mois d'Évasion offerts (quiz illimités, Vaud + Valais).",
  welcomeHasCode: "J'ai un code promo",
  welcomeLater: "Plus tard",
  profileRadiusAll: "Tout",
  profilePhotoTapToChange: "Tape pour changer la photo",
  profilePhotoUpdated: "Photo de profil mise à jour",
  profilePhotoError: "Erreur lors de l'envoi de la photo",
);

const _Strings _en = _Strings(
  appTagline: "Activities will find you!",
  comingSoonTitle: "Whateka is coming soon",
  comingSoonDescription: "Our app is being finalized. Follow us to know when it launches.",
  maintenanceFollowOn: "Follow",
  maintenanceCodeLabel: "Got an access code?",
  maintenanceCodePlaceholder: "••••••",
  maintenanceValidate: "Submit",
  maintenanceLogout: "Sign out",
  successWelcome: "Welcome!",
  successDescription: "Access granted. Time for adventure.",
  btnLogin: "Log in",
  btnSignup: "Sign up",
  btnContinue: "Continue",
  btnSubmit: "Submit",
  btnCancel: "Cancel",
  btnSave: "Save",
  btnUpdate: "Update",
  btnFinish: "Finish",
  loginTitle: "Welcome back",
  loginEmailPlaceholder: "Email address",
  loginPasswordPlaceholder: "Password",
  loginForgotPassword: "Forgot password?",
  loginNoAccount: "No account yet?",
  signupTitle: "Create an account",
  signupNamePlaceholder: "First name",
  signupConfirmPasswordPlaceholder: "Confirm password",
  signupHasAccount: "Already have an account?",
  forgotPasswordTitle: "Forgot password",
  forgotPasswordSendLink: "Send link",
  quizQ1: "Who's coming with you?",
  quizQ2: "What are you in the mood for?",
  quizQ3: "Outdoor or indoor?",
  quizQ4: "What's your budget?",
  quizQ5: "How much time do you have?",
  quizMaxPicks: "Up to 3 picks",
  quizSolo: "Solo",
  quizCouple: "Couple",
  quizFamily: "Family",
  quizFriends: "Friends",
  quizCatNature: "Nature",
  quizCatCulture: "Culture",
  quizCatRelax: "Wellness",
  quizCatSport: "Sports",
  quizCatGastronomy: "Foodie",
  quizCatAdventure: "Adventure",
  quizCatFun: "Fun",
  quizCatEvent: "Event",
  quizOutdoor: "Outdoor",
  quizIndoor: "Indoor",
  quizAny: "Either",
  quizPriceFree: "Free",
  quizPriceLow: "1–20 CHF",
  quizPriceMid: "20–50 CHF",
  quizPriceHigh: "50–100 CHF",
  quizPriceVeryHigh: "100+ CHF",
  quizDurationShort: "A few hours",
  quizDurationMid: "Half a day",
  quizDurationLong: "Full day",
  quizLoading: "Loading...",
  mapSearchPlaceholder: "Search activities",
  mapToggleAll: "All",
  mapToggleLive: "Live",
  mapRecenter: "Re-center",
  mapSubmitTooltip: "Submit an activity",
  resultTitle: "Here are your picks",
  resultSubtitle: "Activities selected for you",
  resultViewMap: "View on map",
  resultRetry: "Start over",
  activityDuration: "Duration",
  activityPrice: "Price",
  activityCategory: "Category",
  activityDescription: "Description",
  activityViewMap: "View on map",
  activityWebsite: "Website",
  activityFavorite: "Favorite",
  navMap: "Map",
  navQuiz: "Quiz",
  navFavorites: "Favorites",
  navProfile: "Profile",
  profileTitle: "Profile",
  profileSearches: "Searches",
  profileMeters: "Steps walked",
  profileLocation: "Location",
  profileLocationAuto: "Automatic",
  profileLocationManual: "Manual",
  profileLocationRadius: "Radius",
  profileLanguage: "Language",
  profileSignOut: "Sign out",
  profileDeleteAccount: "Delete my account",
  profileDeleteAccountDialogTitle: "Delete account",
  profileDeleteAccountDialogBody: "This action is irreversible. All your data will be permanently deleted.",
  profileDeleteAccountConfirm: "Delete permanently",
  profileDeleteAccountSuccess: "Your account has been deleted.",
  profileDeleteAccountError: "Error deleting account.",
  submitTitle: "Submit an activity",
  submitName: "Activity name",
  submitLocation: "Location",
  submitDescription: "Description",
  submitCategories: "Categories",
  submitDuration: "Duration",
  submitPrice: "Price",
  submitFeatures: "Useful info",
  submitPhoto: "Photo",
  submitGeolocate: "Locate automatically",
  submitConfirm: "Submit",
  submitSuccess: "Thanks! Your activity has been submitted.",
  yes: "Yes",
  no: "No",
  loading: "Loading...",
  error: "Something went wrong",
  retry: "Retry",
  close: "Close",
  search: "Search",
  save: "Save",
  featureReservation: "Booking required",
  featureParking: "Parking",
  featureRestrictedHours: "Restricted hours",
  featureMinParticipants: "Minimum participants",
  profileLocationGps: "GPS",
  profileLocationChooseCity: "Choose a city",
  profileLocationChooseCityLabel: "Choose your city",
  profileRadius: "Search radius",
  profileRadiusInfo: "The quiz will only show activities in this area.",
  profileRadiusVaud: "All Vaud",
  profileRadiusValais: "All Valais",
  profileSaveBtn: "Save",
  profileLocationModeAuto: "Automatic",
  profileLocationModeManual: "Manual",
  submitNamePlaceholder: "e.g. Bains thermaux de Saillon",
  submitLocationPlaceholder: "e.g. Saillon",
  submitDescriptionPlaceholder: "Describe the activity in a few sentences...",
  submitActivityUrlLabel: "Activity URL",
  submitAddPhotos: "Add photos",
  submitTakePhoto: "Take a photo",
  submitOrAddUrl: "Or paste an image URL",
  submitImageUrlPlaceholder: "https://example.com/photo.jpg",
  submitAdd: "Add",
  resultSuggestionsLabel: "picks",
  resultPeriodMorning: "this morning",
  resultPeriodAfternoon: "this afternoon",
  resultPeriodEvening: "this evening",
  resultPeriodNight: "tonight",
  resultRetake: "Retake quiz",
  emptyNoActivities: "No activities found",
  emptyNoActivitiesHint: "Try adjusting your search criteria",
  emptyNoFavorites: "No favorites yet",
  emptyNoFavoritesHint: "Tap the heart on an activity to find it here.",
  errorOverloadTitle: "High traffic",
  errorGeneric: "Something went wrong",
  errorRemovingFavorite: "Error removing favorite",
  errorWithDetails: "Error",
  moreActivitiesBtn: "More activities",
  moreIdeasBtn: "More ideas",
  validationRequired: "Required",
  validationEmailInvalid: "Invalid email",
  validationMinChars: "Min 6 characters",
  validationPasswordsMismatch: "Passwords do not match",
  forgotPasswordPrompt: "Enter your email to receive a reset link.",
  forgotPasswordEmailSent: "Reset email sent",
  forgotPasswordTooManyAttempts: "Too many attempts. Please wait.",
  forgotPasswordUnexpectedError: "Unexpected error",
  updatePasswordTitle: "New password",
  updatePasswordSubtitle: "Set your new password",
  updatePasswordNewLabel: "New password",
  updatePasswordConfirmLabel: "Confirm password",
  updatePasswordSuccess: "Password updated successfully",
  updatePasswordCta: "Update",
  verificationTitle: "Verification",
  verificationHeading: "Check your email",
  verificationDescription: "A confirmation link has been sent to your email address. Please click it to activate your account.",
  verificationBackToLogin: "Back to login",
  profileSection: "Preferences",
  profileFirstNameLabel: "First name",
  profileEmailLabel: "Email",
  profileCharacterLabel: "Character",
  profileEmailChangeNotice: "A verification email has been sent to confirm your new address.",
  profileUpdated: "Profile updated",
  profileLocationAutoHint: "The app uses your GPS location automatically.",
  quizMaxChoicesError: "Maximum {0} choice(s) allowed",
  quizContextError: "Error fetching context",
  quizBudgetCascadeHint: "Lower budgets are included automatically (deselectable).",
  activityFeedbackPromptTitle: "Your opinion matters",
  activityFeedbackPromptBody: "Would you like to share your experience with this activity?",
  activityFeedbackLater: "Later",
  activityFeedbackGive: "Give my feedback",
  activityNoUrl: "No URL available for this activity",
  activityCannotOpenUrl: "Could not open the URL",
  activityOpenError: "Error opening link",
  activityViewOnSite: "View on",
  activitySite: "the site",
  activityViewSite: "View site",
  submitGeolocating: "Locating...",
  submitGeolocateError: "Geolocation error",
  submitNoPlaceFound: "No place found",
  submitGeolocatePrompt: "Fill at least the title and place for auto location.",
  submitMapPreviewLabel: "Map preview (tap to adjust)",
  submitLatitudeLabel: "Latitude",
  submitLongitudeLabel: "Longitude",
  submitSeasonsLabel: "Seasons",
  submitSocialTagsLabel: "Social tags",
  submitTypeLabel: "Type (Indoor / Outdoor — at least one)",
  submitSeasonSpring: "Spring",
  submitSeasonSummer: "Summer",
  submitSeasonAutumn: "Autumn",
  submitSeasonWinter: "Winter",
  submitSocialFamily: "Family",
  submitSocialCouple: "Couple",
  submitSocialFriends: "Friends",
  submitSocialSolo: "Solo",
  submitIndoor: "Indoor",
  submitOutdoor: "Outdoor",
  submitPriceFree: "Free",
  submitTitleRequired: "Title is required.",
  submitLocationRequired: "Location is required.",
  submitCategoryRequired: "Select at least one category.",
  submitDescriptionRequired: "Description is required.",
  submitLatitudeInvalid: "Invalid latitude (-90 to 90).",
  submitLongitudeInvalid: "Invalid longitude (-180 to 180).",
  submitDurationInvalid: "Invalid duration.",
  submitSeasonRequired: "Select at least one season.",
  submitSocialRequired: "Select at least one social tag.",
  submitIndoorOutdoorRequired: "Indoor or Outdoor must be checked.",
  submitPhotoReadError: "Cannot read photos",
  submitUrlMustStartWithHttp: "URL must start with http(s)://",
  submitSubmitError: "Submission error",
  submitDurationHint: "e.g. 2.5",
  submitAdminReviewNotice: "Your submission will be reviewed by an admin before publication.",
  submitAddMorePhotos: "Add more photos",
  favoritesCountSingle: "activity",
  favoritesCountPlural: "activities",
  favoriteRemoveError: "Error removing favorite",
  favoritesViewList: "List",
  favoritesViewMap: "Map",
  favoritesEmptyMap: "Tap a pin to open the activity.",
  feedbackTitle: "Your opinion matters!",
  feedbackHeader: "Please take a moment to share your feedback!",
  feedbackThanks: "Thanks for your feedback!",
  feedbackSendError: "Error sending feedback",
  feedbackNoQuestionsActive: "No feedback question is active right now. Thanks!",
  feedbackQuestionnaireLoadError: "Could not load the questionnaire.",
  feedbackRetry: "Retry",
  feedbackSkip: "Skip",
  feedbackSubmit: "Send",
  feedbackRatingNotAtAll: "Not at all",
  feedbackRatingFully: "Absolutely",
  feedbackPlsAnswer: "Please answer",
  feedbackTextHint: "Your answer...",
  feedbackNoOptions: "(No option configured)",
  feedbackGeneralTitle: "Your opinion on Whateka",
  feedbackForcedDialogTitle: "Your opinion matters!",
  feedbackForcedDialogBody: "You've completed several quizzes without sharing your feedback. Could you spare a minute to help us improve Whateka?",
  feedbackForcedDialogClose: "Later",
  whatekaVerifiedTitle: "Whateka-certified activity",
  whatekaVerifiedMessage: "This activity has been tested and approved by the Whateka team.",
  whatekaVerifiedOk: "OK",
  homeMenuGreeting: "Hello",
  homeMenuSignOutTooltip: "Sign out",
  homeMenuExploreTitle: "Start exploring with WHATEKA!",
  homeMenuFindActivity: "Find my activity for the day!",
  homeMenuMap: "Map",
  homeMenuFavorites: "Liked activities",
  homeMenuDefaultUserName: "Traveler",
  loadingFunMessage: "Cooking up your selection...",
  aiNoSuggestionsFound: "No suggestions found for these criteria.",
  aiServerOverloaded: "The AI server is currently overloaded. Please try again in a few moments.",
  aiUnknownError: "Unknown error",
  aiErrorPrefix: "AI Error",
  aiFetchError: "Error fetching AI recommendations",
  maintenanceCodeIncorrect: "Incorrect code",
  maintenanceOrSeparator: "or",
  passwordShow: "Show password",
  passwordHide: "Hide password",
  profileChangePassword: "Change password",
  profileChangePasswordTitle: "Change password",
  profileChangePasswordCurrent: "Current password",
  profileChangePasswordSuccess: "Password changed successfully",
  profileChangePasswordCurrentInvalid: "Current password is incorrect",
  profileChangePasswordSamePwd: "The new password must be different from the current one",
  profileChangePasswordGenericError: "Could not change password",
  subscriptionTitle: "Subscription",
  subscriptionHeadline: "Choose your plan",
  subscriptionSubheadline: "Unlock all activities in Vaud and Valais.",
  subscriptionMostPopular: "MOST POPULAR",
  subscriptionFreeTitle: "Discovery",
  subscriptionRegionalTitle: "Regional",
  subscriptionEvasionTitle: "Escape",
  subscriptionPriceFree: "Free",
  subscriptionPriceMonth: "CHF / month",
  subscriptionTrialHint: "7-day free trial",
  subscriptionStartTrial: "Start trial",
  subscriptionCurrentPlan: "Current plan",
  subscriptionFreeFeature1: "5 quizzes every 30 days",
  subscriptionFreeFeature2: "Full map access",
  subscriptionFreeFeature3: "Unlimited favorites",
  subscriptionFreeFeature4: "Submit an activity",
  subscriptionRegionalFeature1: "Unlimited quizzes",
  subscriptionRegionalFeature2: "Vaud OR Valais",
  subscriptionRegionalFeature3: "Personalized recommendations",
  subscriptionRegionalFeature4: "Switch canton 1× / 30 days",
  subscriptionEvasionFeature1: "Everything in Regional",
  subscriptionEvasionFeature2: "Vaud AND Valais",
  subscriptionEvasionFeature3: "Early access to new activities",
  subscriptionEvasionFeature4: "Premium badge",
  subscriptionPromoCodeButton: "I have a promo code",
  subscriptionDisclaimer: "Cancel anytime.",
  subscriptionQuizUsage: "{used} / {limit} quizzes used",
  subscriptionResetOn: "Resets on {date}",
  subscriptionGoPremium: "Go Premium 🚀",
  subscriptionGoEvasion: "Upgrade to Escape (5 CHF)",
  subscriptionRegionLabel: "Current canton",
  subscriptionExpiresOn: "Renews on {date}",
  subscriptionStatusActive: "ACTIVE",
  subscriptionChangeRegionButton: "Change canton",
  subscriptionEvasionAllRegions: "All regions unlocked (Vaud + Valais)",
  subscriptionThreeTiersTitle: "3 subscription plans",
  subscriptionCompareTiers: "Compare plans",
  subscriptionYourTier: "Your current plan",
  paywallTitle: "You've used your 5 quizzes",
  paywallSubtitle: "Keep exploring Vaud and Valais with a subscription.",
  paywallRegionalSubtitle: "Unlimited quizzes · 1 canton",
  paywallEvasionSubtitle: "Unlimited quizzes · Vaud + Valais",
  paywallPromoCodeButton: "I have a promo code",
  paywallResetHint: "Free reset on {date}",
  paywallLater: "Later",
  regionChangeTitle: "Change canton",
  regionChangeWarning: "You'll be able to change again in 30 days.",
  regionChangeNextOn: "Next change available on {date}",
  regionChangeConfirm: "Confirm change",
  regionChangeSuccess: "Canton updated",
  regionChangeErrorTooSoon: "You must wait 30 days between changes.",
  regionChangeErrorNotRegional: "This option is only available with the Regional plan.",
  regionChangeErrorGeneric: "Could not change canton right now.",
  promoCodeTitle: "Promo code",
  promoCodeHeadline: "Redeem your code",
  promoCodeSubheadline: "Enter your promo code to unlock your subscription.",
  promoCodeLabel: "Code",
  promoCodeApply: "Redeem",
  promoCodeSuccess: "Code applied: {months} months free!",
  promoCodeErrorNotFound: "Code not found.",
  promoCodeErrorInactive: "This code is no longer active.",
  promoCodeErrorExpired: "This code has expired.",
  promoCodeErrorExhausted: "This code has reached its usage limit.",
  promoCodeErrorAlreadyRedeemed: "You've already redeemed this code.",
  promoCodeErrorAlreadyUsedAPromo: "You've already redeemed a promo code on this account. Only one code per account is allowed.",
  promoCodeErrorNotAuthenticated: "Sign in first.",
  promoCodeErrorGeneric: "Could not apply this code.",
  subscriptionMobileSoon: "Mobile payment is coming soon. In the meantime, subscribe at whateka.ch or use a promo code.",
  subscriptionManageMobileSoon: "Mobile management is coming soon. For now, go to whateka.ch to manage your subscription.",
  subscriptionCheckoutError: "Could not start checkout. Try again in a moment.",
  subscriptionPortalError: "Could not open subscription management.",
  subscriptionManageLink: "Manage / cancel my subscription →",
  thanksTitle: "Thanks for your interest 💙",
  thanksHeadline: "Whateka is still young",
  thanksIntro: "Your willingness to support the app means a lot. For now, the Whateka team isn't charging for subscriptions yet — we're in launch phase and we'd rather you enjoy everything for free.",
  thanksGiftLabel: "Your gift",
  thanksGiftValue: "3 months of Escape free",
  thanksGiftCode: "WA2026",
  thanksGiftBenefit: "Full access to Vaud + Valais, unlimited quizzes, early previews — no payment needed.",
  thanksApplyNow: "Activate my access",
  thanksCopyCode: "Copy code",
  thanksCodeCopied: "Code copied to clipboard",
  thanksSupportTitle: "How you can help us back",
  thanksSupportIntro: "The biggest support you can offer us today:",
  thanksSupportBullet1: "Recommend Whateka around you (friends, family, social media)",
  thanksSupportBullet2: "Suggest new activities via the \"Submit an activity\" button",
  thanksSupportBullet3: "Keep using the app and send us your feedback",
  thanksClose: "Later",
  contactSectionTitle: "Contact us",
  contactInstagramButton: "Follow us on Instagram",
  contactInstagramSubtitle: "@whateka.ch",
  contactMessageButton: "Send us a message",
  contactMessageSubtitle: "Question, feedback, bug…",
  contactDialogTitle: "New message",
  contactDialogSubject: "Subject",
  contactDialogMessage: "Your message",
  contactDialogSend: "Send",
  contactDialogCancel: "Cancel",
  contactSendSuccess: "Message sent! The Whateka team will get back to you soon.",
  contactSendError: "Couldn't send your message. Try again in a moment.",
  contactMyMessagesButton: "My messages",
  contactMyMessagesSubtitle: "Your conversations with the team",
  contactMyMessagesEmpty: "No conversations yet",
  contactMyMessagesEmptyHint: "When you send us a message, it will appear here with our replies.",
  contactConversationsTitle: "My messages",
  contactThreadTitle: "Conversation",
  contactThreadReplyPlaceholder: "Write your reply…",
  contactThreadSend: "Send",
  contactThreadReplySuccess: "Message sent",
  contactThreadReplyError: "Couldn't send right now",
  contactThreadTeamLabel: "Whateka team",
  welcomeTitle: "Welcome to Whateka 👋",
  welcomeIntro: "You're now part of the adventure. Here's how it works:",
  welcomeDiscoveryTitle: "You're starting in Discovery mode",
  welcomeDiscoveryBullet1: "5 quizzes every 30 days to discover activities",
  welcomeDiscoveryBullet2: "Full map and unlimited favorites",
  welcomeDiscoveryBullet3: "Submit your own activity ideas",
  welcomePromoIntro: "Got a promo code? Activate it now for 3 months of Escape free (unlimited quizzes, Vaud + Valais).",
  welcomeHasCode: "I have a promo code",
  welcomeLater: "Later",
  profileRadiusAll: "All",
  profilePhotoTapToChange: "Tap to change photo",
  profilePhotoUpdated: "Profile photo updated",
  profilePhotoError: "Error uploading photo",
);

// Allemand (orthographe suisse : "ss" au lieu de "ß" ; tutoiement "du" ;
// exonymes Waadt/Wallis pour Vaud/Valais). Item #11.
const _Strings _de = _Strings(
  appTagline: "Die Aktivität findet dich!",
  comingSoonTitle: "Whateka kommt bald",
  comingSoonDescription: "Unsere App wird gerade fertiggestellt. Folge uns, um vom Launch zu erfahren.",
  maintenanceFollowOn: "Folgen",
  maintenanceCodeLabel: "Hast du einen Zugangscode?",
  maintenanceCodePlaceholder: "••••••",
  maintenanceValidate: "Bestätigen",
  maintenanceLogout: "Abmelden",
  successWelcome: "Willkommen!",
  successDescription: "Zugang gewährt. Auf ins Abenteuer!",
  btnLogin: "Anmelden",
  btnSignup: "Konto erstellen",
  btnContinue: "Weiter",
  btnSubmit: "Bestätigen",
  btnCancel: "Abbrechen",
  btnSave: "Speichern",
  btnUpdate: "Aktualisieren",
  btnFinish: "Fertig",
  loginTitle: "Schön, dich wiederzusehen",
  loginEmailPlaceholder: "E-Mail-Adresse",
  loginPasswordPlaceholder: "Passwort",
  loginForgotPassword: "Passwort vergessen?",
  loginNoAccount: "Noch kein Konto?",
  signupTitle: "Konto erstellen",
  signupNamePlaceholder: "Vorname",
  signupConfirmPasswordPlaceholder: "Passwort bestätigen",
  signupHasAccount: "Schon ein Konto?",
  forgotPasswordTitle: "Passwort vergessen",
  forgotPasswordSendLink: "Link senden",
  quizQ1: "Mit wem gehst du?",
  quizQ2: "Worauf hast du gerade Lust?",
  quizQ3: "Lieber draussen oder drinnen?",
  quizQ4: "Welches Budget?",
  quizQ5: "Wie viel Zeit hast du?",
  quizMaxPicks: "Bis zu 3 Auswahlen",
  quizSolo: "Solo",
  quizCouple: "Zu zweit",
  quizFamily: "Mit der Familie",
  quizFriends: "Mit Freunden",
  quizCatNature: "Natur",
  quizCatCulture: "Kultur",
  quizCatRelax: "Entspannung",
  quizCatSport: "Sport",
  quizCatGastronomy: "Genuss",
  quizCatAdventure: "Abenteuer",
  quizCatFun: "Spass",
  quizCatEvent: "Event",
  quizOutdoor: "Outdoor",
  quizIndoor: "Indoor",
  quizAny: "Egal",
  quizPriceFree: "Gratis",
  quizPriceLow: "1–20 CHF",
  quizPriceMid: "20–50 CHF",
  quizPriceHigh: "50–100 CHF",
  quizPriceVeryHigh: "100+ CHF",
  quizDurationShort: "Ein paar Std.",
  quizDurationMid: "Halber Tag",
  quizDurationLong: "Ganzer Tag",
  quizLoading: "Wird geladen...",
  mapSearchPlaceholder: "Aktivität suchen",
  mapToggleAll: "Alle",
  mapToggleLive: "Live",
  mapRecenter: "Zentrieren",
  mapSubmitTooltip: "Aktivität vorschlagen",
  resultTitle: "Hier sind unsere Vorschläge",
  resultSubtitle: "Für dich ausgewählte Aktivitäten",
  resultViewMap: "Auf der Karte ansehen",
  resultRetry: "Nochmal",
  activityDuration: "Dauer",
  activityPrice: "Preis",
  activityCategory: "Kategorie",
  activityDescription: "Beschreibung",
  activityViewMap: "Auf der Karte ansehen",
  activityWebsite: "Website",
  activityFavorite: "Favorit",
  navMap: "Karte",
  navQuiz: "Quiz",
  navFavorites: "Favoriten",
  navProfile: "Profil",
  profileTitle: "Profil",
  profileSearches: "Suchen",
  profileMeters: "Zurückgelegte Meter",
  profileLocation: "Standort",
  profileLocationAuto: "Automatisch",
  profileLocationManual: "Manuell",
  profileLocationRadius: "Radius",
  profileLanguage: "Sprache",
  profileSignOut: "Abmelden",
  profileDeleteAccount: "Konto löschen",
  profileDeleteAccountDialogTitle: "Konto löschen",
  profileDeleteAccountDialogBody: "Diese Aktion ist unwiderruflich. Alle deine Daten werden endgültig gelöscht.",
  profileDeleteAccountConfirm: "Endgültig löschen",
  profileDeleteAccountSuccess: "Dein Konto wurde gelöscht.",
  profileDeleteAccountError: "Fehler beim Löschen des Kontos.",
  submitTitle: "Aktivität vorschlagen",
  submitName: "Name der Aktivität",
  submitLocation: "Ort",
  submitDescription: "Beschreibung",
  submitCategories: "Kategorien",
  submitDuration: "Dauer",
  submitPrice: "Preis",
  submitFeatures: "Nützliche Infos",
  submitPhoto: "Foto",
  submitGeolocate: "Automatisch lokalisieren",
  submitConfirm: "Einreichen",
  submitSuccess: "Danke! Deine Aktivität wurde eingereicht.",
  yes: "Ja",
  no: "Nein",
  loading: "Wird geladen...",
  error: "Ein Fehler ist aufgetreten",
  retry: "Erneut versuchen",
  close: "Schliessen",
  search: "Suchen",
  save: "Speichern",
  featureReservation: "Reservation erforderlich",
  featureParking: "Parkplatz",
  featureRestrictedHours: "Eingeschränkte Öffnungszeiten",
  featureMinParticipants: "Mindestteilnehmerzahl",
  profileLocationGps: "GPS",
  profileLocationChooseCity: "Stadt wählen",
  profileLocationChooseCityLabel: "Wähle deine Stadt",
  profileRadius: "Suchradius",
  profileRadiusInfo: "Der Fragebogen beschränkt die Aktivitäten auf dieses Gebiet.",
  profileRadiusVaud: "Ganze Waadt",
  profileRadiusValais: "Ganzes Wallis",
  profileSaveBtn: "Speichern",
  profileLocationModeAuto: "Automatisch",
  profileLocationModeManual: "Manuell",
  submitNamePlaceholder: "z. B. Thermalbad Saillon",
  submitLocationPlaceholder: "z. B. Saillon",
  submitDescriptionPlaceholder: "Beschreibe die Aktivität in ein paar Sätzen...",
  submitActivityUrlLabel: "URL der Aktivität",
  submitAddPhotos: "Fotos hinzufügen",
  submitTakePhoto: "Foto aufnehmen",
  submitOrAddUrl: "Oder eine Bild-URL einfügen",
  submitImageUrlPlaceholder: "https://beispiel.ch/foto.jpg",
  submitAdd: "Hinzufügen",
  resultSuggestionsLabel: "Vorschläge",
  resultPeriodMorning: "heute Morgen",
  resultPeriodAfternoon: "heute Nachmittag",
  resultPeriodEvening: "heute Abend",
  resultPeriodNight: "heute Nacht",
  resultRetake: "Quiz wiederholen",
  emptyNoActivities: "Keine Aktivität gefunden",
  emptyNoActivitiesHint: "Versuche, deine Suchkriterien anzupassen",
  emptyNoFavorites: "Noch keine Favoriten",
  emptyNoFavoritesHint: "Tippe auf das Herz einer Aktivität, um sie hier wiederzufinden.",
  errorOverloadTitle: "Hoher Andrang",
  errorGeneric: "Ein Fehler ist aufgetreten",
  errorRemovingFavorite: "Fehler beim Entfernen",
  errorWithDetails: "Fehler",
  moreActivitiesBtn: "Mehr Aktivitäten",
  moreIdeasBtn: "Mehr Ideen",
  validationRequired: "Erforderlich",
  validationEmailInvalid: "Ungültige E-Mail",
  validationMinChars: "Mind. 6 Zeichen",
  validationPasswordsMismatch: "Die Passwörter stimmen nicht überein",
  forgotPasswordPrompt: "Gib deine E-Mail ein, um einen Link zum Zurücksetzen zu erhalten.",
  forgotPasswordEmailSent: "E-Mail zum Zurücksetzen gesendet",
  forgotPasswordTooManyAttempts: "Zu viele Versuche. Bitte warte einen Moment.",
  forgotPasswordUnexpectedError: "Unerwarteter Fehler",
  updatePasswordTitle: "Neues Passwort",
  updatePasswordSubtitle: "Lege dein neues Passwort fest",
  updatePasswordNewLabel: "Neues Passwort",
  updatePasswordConfirmLabel: "Passwort bestätigen",
  updatePasswordSuccess: "Passwort erfolgreich aktualisiert",
  updatePasswordCta: "Aktualisieren",
  verificationTitle: "Bestätigung",
  verificationHeading: "Überprüfe deine E-Mail",
  verificationDescription: "Ein Bestätigungslink wurde an deine E-Mail-Adresse gesendet. Bitte klicke darauf, um dein Konto zu aktivieren.",
  verificationBackToLogin: "Zurück zur Anmeldung",
  profileSection: "Einstellungen",
  profileFirstNameLabel: "Vorname",
  profileEmailLabel: "E-Mail",
  profileCharacterLabel: "Figur",
  profileEmailChangeNotice: "Für die Adressänderung wurde eine Bestätigungs-E-Mail gesendet.",
  profileUpdated: "Profil aktualisiert",
  profileLocationAutoHint: "Die App nutzt automatisch deinen GPS-Standort.",
  quizMaxChoicesError: "Maximal {0} Auswahl(en) möglich",
  quizContextError: "Fehler beim Abrufen des Kontexts",
  quizBudgetCascadeHint: "Niedrigere Budgets sind automatisch inbegriffen (abwählbar).",
  activityFeedbackPromptTitle: "Deine Meinung zählt",
  activityFeedbackPromptBody: "Möchtest du deine Erfahrung mit dieser Aktivität teilen?",
  activityFeedbackLater: "Später",
  activityFeedbackGive: "Bewerten",
  activityNoUrl: "Für diese Aktivität ist keine URL verfügbar",
  activityCannotOpenUrl: "URL kann nicht geöffnet werden",
  activityOpenError: "Fehler beim Öffnen des Links",
  activityViewOnSite: "Ansehen auf",
  activitySite: "der Website",
  activityViewSite: "Website ansehen",
  submitGeolocating: "Wird lokalisiert...",
  submitGeolocateError: "Fehler bei der Standortbestimmung",
  submitNoPlaceFound: "Kein Ort gefunden",
  submitGeolocatePrompt: "Fülle mindestens Titel und Ort aus für die automatische Lokalisierung.",
  submitMapPreviewLabel: "Kartenvorschau (tippen zum Anpassen)",
  submitLatitudeLabel: "Breitengrad",
  submitLongitudeLabel: "Längengrad",
  submitSeasonsLabel: "Jahreszeiten",
  submitSocialTagsLabel: "Soziale Tags",
  submitTypeLabel: "Typ (Indoor / Outdoor — mindestens eins)",
  submitSeasonSpring: "Frühling",
  submitSeasonSummer: "Sommer",
  submitSeasonAutumn: "Herbst",
  submitSeasonWinter: "Winter",
  submitSocialFamily: "Familie",
  submitSocialCouple: "Paar",
  submitSocialFriends: "Freunde",
  submitSocialSolo: "Solo",
  submitIndoor: "Indoor",
  submitOutdoor: "Outdoor",
  submitPriceFree: "Gratis",
  submitTitleRequired: "Der Titel ist erforderlich.",
  submitLocationRequired: "Der Ort ist erforderlich.",
  submitCategoryRequired: "Wähle mindestens eine Kategorie.",
  submitDescriptionRequired: "Die Beschreibung ist erforderlich.",
  submitLatitudeInvalid: "Ungültiger Breitengrad (-90 bis 90).",
  submitLongitudeInvalid: "Ungültiger Längengrad (-180 bis 180).",
  submitDurationInvalid: "Ungültige Dauer.",
  submitSeasonRequired: "Wähle mindestens eine Jahreszeit.",
  submitSocialRequired: "Wähle mindestens einen sozialen Tag.",
  submitIndoorOutdoorRequired: "Indoor oder Outdoor muss angekreuzt sein.",
  submitPhotoReadError: "Fotos können nicht gelesen werden",
  submitUrlMustStartWithHttp: "Die URL muss mit http(s):// beginnen",
  submitSubmitError: "Fehler beim Einreichen",
  submitDurationHint: "z. B. 2.5",
  submitAdminReviewNotice: "Dein Vorschlag wird vor der Veröffentlichung von einem Administrator geprüft.",
  submitAddMorePhotos: "Weitere Fotos hinzufügen",
  favoritesCountSingle: "Aktivität",
  favoritesCountPlural: "Aktivitäten",
  favoriteRemoveError: "Fehler beim Entfernen",
  favoritesViewList: "Liste",
  favoritesViewMap: "Karte",
  favoritesEmptyMap: "Tippe auf einen Pin, um die Aktivität zu öffnen.",
  feedbackTitle: "Deine Meinung zählt!",
  feedbackHeader: "Danke, dass du dir einen Moment Zeit nimmst für dein Feedback!",
  feedbackThanks: "Danke für dein Feedback!",
  feedbackSendError: "Fehler beim Senden des Feedbacks",
  feedbackNoQuestionsActive: "Momentan ist keine Feedback-Frage aktiv. Danke!",
  feedbackQuestionnaireLoadError: "Der Fragebogen konnte nicht geladen werden.",
  feedbackRetry: "Erneut versuchen",
  feedbackSkip: "Überspringen",
  feedbackSubmit: "Senden",
  feedbackRatingNotAtAll: "Überhaupt nicht",
  feedbackRatingFully: "Voll und ganz",
  feedbackPlsAnswer: "Bitte beantworte",
  feedbackTextHint: "Deine Antwort...",
  feedbackNoOptions: "(Keine Option konfiguriert)",
  feedbackGeneralTitle: "Deine Meinung zu Whateka",
  feedbackForcedDialogTitle: "Deine Meinung interessiert uns!",
  feedbackForcedDialogBody: "Du hast mehrere Quiz gemacht, ohne uns dein Feedback zu geben. Nimmst du dir 1 Minute Zeit, um Whateka zu verbessern?",
  feedbackForcedDialogClose: "Später",
  whatekaVerifiedTitle: "Whateka-zertifizierte Aktivität",
  whatekaVerifiedMessage: "Diese Aktivität wurde vom Whateka-Team getestet und freigegeben.",
  whatekaVerifiedOk: "OK",
  homeMenuGreeting: "Hallo",
  homeMenuSignOutTooltip: "Abmelden",
  homeMenuExploreTitle: "Starte deine Entdeckungsreise mit WHATEKA!",
  homeMenuFindActivity: "Finde meine Aktivität des Tages!",
  homeMenuMap: "Karte",
  homeMenuFavorites: "Gelikte Aktivitäten",
  homeMenuDefaultUserName: "Entdecker",
  loadingFunMessage: "Wir stellen deine Auswahl zusammen...",
  aiNoSuggestionsFound: "Keine Vorschläge für diese Kriterien gefunden.",
  aiServerOverloaded: "Der KI-Server ist momentan überlastet. Bitte versuche es in einem Moment erneut.",
  aiUnknownError: "Unbekannter Fehler",
  aiErrorPrefix: "KI-Fehler",
  aiFetchError: "Fehler beim Abrufen der KI-Empfehlungen",
  maintenanceCodeIncorrect: "Falscher Code",
  maintenanceOrSeparator: "oder",
  passwordShow: "Passwort anzeigen",
  passwordHide: "Passwort verbergen",
  profileChangePassword: "Passwort ändern",
  profileChangePasswordTitle: "Passwort ändern",
  profileChangePasswordCurrent: "Aktuelles Passwort",
  profileChangePasswordSuccess: "Passwort erfolgreich geändert",
  profileChangePasswordCurrentInvalid: "Aktuelles Passwort falsch",
  profileChangePasswordSamePwd: "Das neue Passwort muss sich vom alten unterscheiden",
  profileChangePasswordGenericError: "Passwort konnte nicht geändert werden",
  subscriptionTitle: "Abonnement",
  subscriptionHeadline: "Wähle deinen Plan",
  subscriptionSubheadline: "Schalte alle Aktivitäten in Waadt und Wallis frei.",
  subscriptionMostPopular: "AM BELIEBTESTEN",
  subscriptionFreeTitle: "Entdeckung",
  subscriptionRegionalTitle: "Regional",
  subscriptionEvasionTitle: "Evasion",
  subscriptionPriceFree: "Gratis",
  subscriptionPriceMonth: "CHF / Monat",
  subscriptionTrialHint: "7 Tage gratis testen",
  subscriptionStartTrial: "Test starten",
  subscriptionCurrentPlan: "Aktueller Plan",
  subscriptionFreeFeature1: "5 Quiz alle 30 Tage",
  subscriptionFreeFeature2: "Vollständige Karte",
  subscriptionFreeFeature3: "Unbegrenzte Favoriten",
  subscriptionFreeFeature4: "Aktivität vorschlagen",
  subscriptionRegionalFeature1: "Unbegrenzte Quiz",
  subscriptionRegionalFeature2: "Waadt ODER Wallis",
  subscriptionRegionalFeature3: "Personalisierte Empfehlungen",
  subscriptionRegionalFeature4: "Kantonswechsel 1× / 30 Tage",
  subscriptionEvasionFeature1: "Alles aus Regional inklusive",
  subscriptionEvasionFeature2: "Waadt UND Wallis",
  subscriptionEvasionFeature3: "Aktivitäten in der Vorpremiere",
  subscriptionEvasionFeature4: "Premium-Badge",
  subscriptionPromoCodeButton: "Ich habe einen Promo-Code",
  subscriptionDisclaimer: "Jederzeit kündbar.",
  subscriptionQuizUsage: "{used} / {limit} Quiz genutzt",
  subscriptionResetOn: "Zurücksetzung am {date}",
  subscriptionGoPremium: "Premium werden 🚀",
  subscriptionGoEvasion: "Auf Evasion wechseln (5 CHF)",
  subscriptionRegionLabel: "Aktueller Kanton",
  subscriptionExpiresOn: "Verlängerung am {date}",
  subscriptionStatusActive: "AKTIV",
  subscriptionChangeRegionButton: "Kanton wechseln",
  subscriptionEvasionAllRegions: "Alle Regionen freigeschaltet (Waadt + Wallis)",
  subscriptionThreeTiersTitle: "3 Abo-Varianten",
  subscriptionCompareTiers: "Abos vergleichen",
  subscriptionYourTier: "Dein aktuelles Abo",
  paywallTitle: "Du hast deine 5 Quiz aufgebraucht",
  paywallSubtitle: "Entdecke Waadt und Wallis weiter mit einem Abo.",
  paywallRegionalSubtitle: "Unbegrenzte Quiz · 1 Kanton",
  paywallEvasionSubtitle: "Unbegrenzte Quiz · Waadt + Wallis",
  paywallPromoCodeButton: "Ich habe einen Promo-Code",
  paywallResetHint: "Gratis-Zurücksetzung am {date}",
  paywallLater: "Später",
  regionChangeTitle: "Kanton wechseln",
  regionChangeWarning: "Du kannst in 30 Tagen wieder wechseln.",
  regionChangeNextOn: "Nächster Wechsel möglich am {date}",
  regionChangeConfirm: "Wechsel bestätigen",
  regionChangeSuccess: "Kanton aktualisiert",
  regionChangeErrorTooSoon: "Zwischen zwei Wechseln musst du 30 Tage warten.",
  regionChangeErrorNotRegional: "Diese Option ist nur mit dem Regional-Abo verfügbar.",
  regionChangeErrorGeneric: "Kanton kann momentan nicht gewechselt werden.",
  promoCodeTitle: "Promo-Code",
  promoCodeHeadline: "Aktiviere deinen Code",
  promoCodeSubheadline: "Gib deinen Promo-Code ein, um dein Abo freizuschalten.",
  promoCodeLabel: "Code",
  promoCodeApply: "Aktivieren",
  promoCodeSuccess: "Code aktiviert: {months} Monate geschenkt!",
  promoCodeErrorNotFound: "Code nicht gefunden.",
  promoCodeErrorInactive: "Dieser Code ist nicht mehr aktiv.",
  promoCodeErrorExpired: "Dieser Code ist abgelaufen.",
  promoCodeErrorExhausted: "Dieser Code hat sein Nutzungslimit erreicht.",
  promoCodeErrorAlreadyRedeemed: "Du hast diesen Code bereits verwendet.",
  promoCodeErrorAlreadyUsedAPromo: "Du hast bereits einen Promo-Code auf diesem Konto verwendet. Nur ein Code pro Konto ist erlaubt.",
  promoCodeErrorNotAuthenticated: "Melde dich zuerst an.",
  promoCodeErrorGeneric: "Dieser Code konnte nicht aktiviert werden.",
  subscriptionMobileSoon: "Die Zahlung auf dem Handy kommt bald. Abonniere in der Zwischenzeit über whateka.ch oder nutze einen Promo-Code.",
  subscriptionManageMobileSoon: "Die Verwaltung auf dem Handy kommt bald. Gehe in der Zwischenzeit auf whateka.ch, um dein Abo zu verwalten.",
  subscriptionCheckoutError: "Zahlung konnte nicht gestartet werden. Versuche es in einem Moment erneut.",
  subscriptionPortalError: "Die Abo-Verwaltung konnte nicht geöffnet werden.",
  subscriptionManageLink: "Abo verwalten / kündigen →",
  thanksTitle: "Danke für dein Interesse 💙",
  thanksHeadline: "Whateka ist noch ganz jung",
  thanksIntro: "Dass du die App unterstützen möchtest, berührt uns sehr. Momentan verlangt das Whateka-Team noch nichts für die Abos — wir sind in der Startphase und möchten, dass du alles gratis geniessen kannst.",
  thanksGiftLabel: "Dein Geschenk",
  thanksGiftValue: "3 Monate Evasion geschenkt",
  thanksGiftCode: "WA2026",
  thanksGiftBenefit: "Voller Zugang zu Waadt + Wallis, unbegrenzte Quiz, Vorpremieren — ohne etwas zu bezahlen.",
  thanksApplyNow: "Zugang aktivieren",
  thanksCopyCode: "Code kopieren",
  thanksCodeCopied: "Code in die Zwischenablage kopiert",
  thanksSupportTitle: "Wie du uns im Gegenzug helfen kannst",
  thanksSupportIntro: "Die grösste Unterstützung, die du uns heute geben kannst:",
  thanksSupportBullet1: "Whateka weiterempfehlen (Freunde, Familie, Netzwerke)",
  thanksSupportBullet2: "Neue Aktivitäten über den Button «Aktivität vorschlagen» einreichen",
  thanksSupportBullet3: "Die App weiter nutzen und uns dein Feedback schicken",
  thanksClose: "Später",
  contactSectionTitle: "Kontaktiere uns",
  contactInstagramButton: "Folge uns auf Instagram",
  contactInstagramSubtitle: "@whateka.ch",
  contactMessageButton: "Uns eine Nachricht senden",
  contactMessageSubtitle: "Frage, Vorschlag, Bug…",
  contactDialogTitle: "Neue Nachricht",
  contactDialogSubject: "Betreff",
  contactDialogMessage: "Deine Nachricht",
  contactDialogSend: "Senden",
  contactDialogCancel: "Abbrechen",
  contactSendSuccess: "Nachricht gesendet! Das Whateka-Team meldet sich bald bei dir.",
  contactSendError: "Nachricht konnte nicht gesendet werden. Versuche es gleich erneut.",
  contactMyMessagesButton: "Meine Nachrichten",
  contactMyMessagesSubtitle: "Deine Gespräche mit dem Team",
  contactMyMessagesEmpty: "Noch keine Gespräche",
  contactMyMessagesEmptyHint: "Wenn du uns eine Nachricht schickst, erscheint sie hier zusammen mit unseren Antworten.",
  contactConversationsTitle: "Meine Nachrichten",
  contactThreadTitle: "Gespräch",
  contactThreadReplyPlaceholder: "Schreib deine Antwort…",
  contactThreadSend: "Senden",
  contactThreadReplySuccess: "Nachricht gesendet",
  contactThreadReplyError: "Senden momentan nicht möglich",
  contactThreadTeamLabel: "Whateka-Team",
  welcomeTitle: "Willkommen bei Whateka 👋",
  welcomeIntro: "Du bist jetzt Teil des Abenteuers. So funktioniert's:",
  welcomeDiscoveryTitle: "Du startest im Entdeckungsmodus",
  welcomeDiscoveryBullet1: "5 Quiz alle 30 Tage, um Aktivitäten zu entdecken",
  welcomeDiscoveryBullet2: "Vollständige Karte und unbegrenzte Favoriten",
  welcomeDiscoveryBullet3: "Möglichkeit, eine Aktivität vorzuschlagen",
  welcomePromoIntro: "Hast du einen Promo-Code? Aktiviere ihn jetzt für 3 Monate Evasion geschenkt (unbegrenzte Quiz, Waadt + Wallis).",
  welcomeHasCode: "Ich habe einen Promo-Code",
  welcomeLater: "Später",
  profileRadiusAll: "Alles",
  profilePhotoTapToChange: "Tippen, um das Foto zu ändern",
  profilePhotoUpdated: "Profilfoto aktualisiert",
  profilePhotoError: "Fehler beim Hochladen des Fotos",
);

/// Mappe AppLocale <-> code stocké dans user_metadata.locale.
String _localeCode(AppLocale l) {
  switch (l) {
    case AppLocale.en:
      return 'en';
    case AppLocale.de:
      return 'de';
    case AppLocale.fr:
      return 'fr';
  }
}

AppLocale _localeFromCode(String? code) {
  switch (code) {
    case 'en':
      return AppLocale.en;
    case 'de':
      return AppLocale.de;
    default:
      return AppLocale.fr;
  }
}

/// Provider de locale (notifie les widgets quand la langue change).
class LocaleProvider extends ChangeNotifier {
  static final LocaleProvider instance = LocaleProvider._internal();
  factory LocaleProvider() => instance;
  LocaleProvider._internal();

  AppLocale _current = AppLocale.fr;
  AppLocale get current => _current;
  bool get isEn => _current == AppLocale.en;

  /// Initialise la locale depuis le user_metadata Supabase.
  Future<void> init() async {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};
    _current = _localeFromCode(meta['locale']?.toString());
    notifyListeners();
  }

  /// Change la langue et persiste dans user_metadata.
  Future<void> setLocale(AppLocale loc) async {
    if (_current == loc) return;
    _current = loc;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'locale': _localeCode(loc)}),
      );
    } catch (_) {
      // Pas connecté : la locale reste en mémoire pour la session
    }
  }
}

/// Helper d'accès aux strings traduits.
class S {
  static _Strings _forLocale(AppLocale l) {
    switch (l) {
      case AppLocale.en:
        return _en;
      case AppLocale.de:
        return _de;
      case AppLocale.fr:
        return _fr;
    }
  }

  /// Retourne les strings dans la locale courante.
  static _Strings of(BuildContext context) =>
      _forLocale(LocaleProvider.instance.current);

  /// Variante sans context (utile dans services).
  static _Strings get current => _forLocale(LocaleProvider.instance.current);
}

/// Choisit la bonne version d'un champ d'activité selon la locale.
/// Le contenu des activités n'existe qu'en FR/EN : en allemand on privilégie
/// l'anglais (plus universel), puis on retombe sur le français.
String pickLocalized(String? fr, String? en) {
  final l = LocaleProvider.instance.current;
  if ((l == AppLocale.en || l == AppLocale.de) &&
      en != null &&
      en.trim().isNotEmpty) {
    return en;
  }
  return fr ?? '';
}
