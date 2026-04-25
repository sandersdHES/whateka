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
