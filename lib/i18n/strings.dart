import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Système de traduction simple basé sur des Maps. Pas de dépendance externe.
/// Utilisation : `S.of(context).homeTagline`
///
/// La langue est lue depuis user_metadata.locale (Supabase) à la connexion,
/// ou depuis SharedPreferences en fallback. Persistante cross-device.

enum AppLocale { fr, en }

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
  final String activityViewOnSite;
  final String activitySite;

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
  final String feedbackNoOptions;

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
);

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
    final loc = meta['locale']?.toString();
    if (loc == 'en') {
      _current = AppLocale.en;
    } else {
      _current = AppLocale.fr;
    }
    notifyListeners();
  }

  /// Change la langue et persiste dans user_metadata.
  Future<void> setLocale(AppLocale loc) async {
    if (_current == loc) return;
    _current = loc;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'locale': loc == AppLocale.en ? 'en' : 'fr'}),
      );
    } catch (_e) {
      // Pas connecté : la locale reste en mémoire pour la session
    }
  }
}

/// Helper d'accès aux strings traduits.
class S {
  /// Retourne les strings dans la locale courante.
  static _Strings of(BuildContext context) {
    return LocaleProvider.instance.isEn ? _en : _fr;
  }

  /// Variante sans context (utile dans services).
  static _Strings get current => LocaleProvider.instance.isEn ? _en : _fr;
}

/// Choisit la version FR ou EN d'un champ d'activité selon la locale.
/// Si la version EN est null/vide, fallback sur FR.
String pickLocalized(String? fr, String? en) {
  if (LocaleProvider.instance.isEn && en != null && en.trim().isNotEmpty) {
    return en;
  }
  return fr ?? '';
}
