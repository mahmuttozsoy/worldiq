import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @academy.
  ///
  /// In en, this message translates to:
  /// **'Academy'**
  String get academy;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leagues'**
  String get leaderboard;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Private Account'**
  String get privacy;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get streak;

  /// No description provided for @totalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXp;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @outgoingRequests.
  ///
  /// In en, this message translates to:
  /// **'Sent Requests'**
  String get outgoingRequests;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications.'**
  String get noNotifications;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Word of the Day'**
  String get dailyChallenge;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @masteredWords.
  ///
  /// In en, this message translates to:
  /// **'Mastered Words'**
  String get masteredWords;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @dailyMissions.
  ///
  /// In en, this message translates to:
  /// **'Daily Missions'**
  String get dailyMissions;

  /// No description provided for @gameModes.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get gameModes;

  /// No description provided for @flagQuiz.
  ///
  /// In en, this message translates to:
  /// **'Flag Quiz'**
  String get flagQuiz;

  /// No description provided for @continentQuiz.
  ///
  /// In en, this message translates to:
  /// **'Continent Explorer'**
  String get continentQuiz;

  /// No description provided for @cityQuiz.
  ///
  /// In en, this message translates to:
  /// **'City Puzzle'**
  String get cityQuiz;

  /// No description provided for @languageAcademy.
  ///
  /// In en, this message translates to:
  /// **'Language Academy'**
  String get languageAcademy;

  /// No description provided for @sudoku.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get sudoku;

  /// No description provided for @chess.
  ///
  /// In en, this message translates to:
  /// **'Chess'**
  String get chess;

  /// No description provided for @dailyChallengeLabel.
  ///
  /// In en, this message translates to:
  /// **'DAILY CHALLENGE'**
  String get dailyChallengeLabel;

  /// No description provided for @playGame.
  ///
  /// In en, this message translates to:
  /// **'Play Game'**
  String get playGame;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get reward;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'GO'**
  String get go;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get educationLevel;

  /// No description provided for @brainGames.
  ///
  /// In en, this message translates to:
  /// **'Brain Games'**
  String get brainGames;

  /// No description provided for @leagueLabel.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get leagueLabel;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @matchHistory.
  ///
  /// In en, this message translates to:
  /// **'Match History'**
  String get matchHistory;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @viewAchievements.
  ///
  /// In en, this message translates to:
  /// **'View Achievements'**
  String get viewAchievements;

  /// No description provided for @privateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Private Account'**
  String get privateAccountTitle;

  /// No description provided for @privateAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Follow this user to see their info.'**
  String get privateAccountDesc;

  /// No description provided for @noMatchHistory.
  ///
  /// In en, this message translates to:
  /// **'No match history yet.'**
  String get noMatchHistory;

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get win;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get loss;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New Name'**
  String get newName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @privacySocial.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Social'**
  String get privacySocial;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the app in dark mode'**
  String get darkModeDesc;

  /// No description provided for @privacyDesc.
  ///
  /// In en, this message translates to:
  /// **'You need to approve follow requests'**
  String get privacyDesc;

  /// No description provided for @notificationsActive.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get notificationsActive;

  /// No description provided for @notificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Game invites and reminders'**
  String get notificationsDesc;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmDesc;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Friends'**
  String get friendsTitle;

  /// No description provided for @searchFriends.
  ///
  /// In en, this message translates to:
  /// **'Search friends...'**
  String get searchFriends;

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'No friends yet.'**
  String get noFriends;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @searchUsername.
  ///
  /// In en, this message translates to:
  /// **'Search username...'**
  String get searchUsername;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSent;

  /// No description provided for @friendRequestSentMsg.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent!'**
  String get friendRequestSentMsg;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loadingInvite.
  ///
  /// In en, this message translates to:
  /// **'Creating invitation...'**
  String get loadingInvite;

  /// No description provided for @sessionError.
  ///
  /// In en, this message translates to:
  /// **'Could not create session.'**
  String get sessionError;

  /// No description provided for @inviteSentMsg.
  ///
  /// In en, this message translates to:
  /// **'invitation sent!'**
  String get inviteSentMsg;

  /// No description provided for @selectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty:'**
  String get selectDifficulty;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @champion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get champion;

  /// No description provided for @inviteToChess.
  ///
  /// In en, this message translates to:
  /// **'Invite to Chess'**
  String get inviteToChess;

  /// No description provided for @leagueBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get leagueBronze;

  /// No description provided for @leagueSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get leagueSilver;

  /// No description provided for @leagueGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get leagueGold;

  /// No description provided for @leaguePlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get leaguePlatinum;

  /// No description provided for @leagueDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get leagueDiamond;

  /// No description provided for @noNotificationsMsg.
  ///
  /// In en, this message translates to:
  /// **'You have no new notifications.'**
  String get noNotificationsMsg;

  /// No description provided for @friendRequest.
  ///
  /// In en, this message translates to:
  /// **'Friend Request'**
  String get friendRequest;

  /// No description provided for @gameInvite.
  ///
  /// In en, this message translates to:
  /// **'Game Invite'**
  String get gameInvite;

  /// No description provided for @friendRequestMsg.
  ///
  /// In en, this message translates to:
  /// **'sent you a friend request.'**
  String get friendRequestMsg;

  /// No description provided for @gameInviteMsg.
  ///
  /// In en, this message translates to:
  /// **'invited you to play Chess.'**
  String get gameInviteMsg;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\\'**
  String get noAccountRegister;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get fillAllFields;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @createAccountToStart.
  ///
  /// In en, this message translates to:
  /// **'Create a new account to start'**
  String get createAccountToStart;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  /// No description provided for @chessArena.
  ///
  /// In en, this message translates to:
  /// **'Chess Arena'**
  String get chessArena;

  /// No description provided for @chessDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your opponent, make your move, find the checkmate.'**
  String get chessDesc;

  /// No description provided for @onlineMatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Online match starting. Use your pieces wisely.'**
  String get onlineMatchDesc;

  /// No description provided for @whiteTurn.
  ///
  /// In en, this message translates to:
  /// **'White is moving'**
  String get whiteTurn;

  /// No description provided for @blackThinking.
  ///
  /// In en, this message translates to:
  /// **'Black is thinking...'**
  String get blackThinking;

  /// No description provided for @blackTurn.
  ///
  /// In en, this message translates to:
  /// **'Black is moving'**
  String get blackTurn;

  /// No description provided for @matchCompleted.
  ///
  /// In en, this message translates to:
  /// **'Match Completed'**
  String get matchCompleted;

  /// No description provided for @invalidMove.
  ///
  /// In en, this message translates to:
  /// **'Invalid move!'**
  String get invalidMove;

  /// No description provided for @gameOverWin.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You won!'**
  String get gameOverWin;

  /// No description provided for @chessGame.
  ///
  /// In en, this message translates to:
  /// **'Chess'**
  String get chessGame;

  /// No description provided for @blackWon.
  ///
  /// In en, this message translates to:
  /// **'Black won.'**
  String get blackWon;

  /// No description provided for @checkmateWhiteWon.
  ///
  /// In en, this message translates to:
  /// **'Checkmate! White won.'**
  String get checkmateWhiteWon;

  /// No description provided for @winXpMsg.
  ///
  /// In en, this message translates to:
  /// **'{msg} You earned +{xp} XP!'**
  String winXpMsg(Object msg, Object xp);

  /// No description provided for @whiteInCheck.
  ///
  /// In en, this message translates to:
  /// **'White is in check!'**
  String get whiteInCheck;

  /// No description provided for @blackInCheck.
  ///
  /// In en, this message translates to:
  /// **'Black is in check!'**
  String get blackInCheck;

  /// No description provided for @restartGame.
  ///
  /// In en, this message translates to:
  /// **'Restart Game'**
  String get restartGame;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @piecesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pieces'**
  String piecesCount(Object count);

  /// No description provided for @chessHintGameOver.
  ///
  /// In en, this message translates to:
  /// **'Game over. You can refresh or play again from the top right.'**
  String get chessHintGameOver;

  /// No description provided for @chessHintMultiplayer.
  ///
  /// In en, this message translates to:
  /// **'Select a piece when it\\'**
  String get chessHintMultiplayer;

  /// No description provided for @chessHintDefault.
  ///
  /// In en, this message translates to:
  /// **'Valid moves appear in green when you select a piece. Last move glows orange.'**
  String get chessHintDefault;

  /// No description provided for @gameOverLoss.
  ///
  /// In en, this message translates to:
  /// **'Game Over! You lost.'**
  String get gameOverLoss;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @patMsg.
  ///
  /// In en, this message translates to:
  /// **'Stalemate! The game ended in a draw.'**
  String get patMsg;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get playAgain;

  /// No description provided for @returnToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get returnToMenu;

  /// No description provided for @sudokuTitle.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get sudokuTitle;

  /// No description provided for @errorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorsLabel;

  /// No description provided for @hintsLabel.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hintsLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @perfect.
  ///
  /// In en, this message translates to:
  /// **'PERFECT!'**
  String get perfect;

  /// No description provided for @levelCompletedMsg.
  ///
  /// In en, this message translates to:
  /// **'level successfully completed.'**
  String get levelCompletedMsg;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeLabel;

  /// No description provided for @wrongNumberMsg.
  ///
  /// In en, this message translates to:
  /// **'Wrong number!'**
  String get wrongNumberMsg;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @whichCountryFlagMsg.
  ///
  /// In en, this message translates to:
  /// **'Which country does this flag belong to?'**
  String get whichCountryFlagMsg;

  /// No description provided for @whichContinentMsg.
  ///
  /// In en, this message translates to:
  /// **'Which continent is this country in?'**
  String get whichContinentMsg;

  /// No description provided for @whichCountryCapitalMsg.
  ///
  /// In en, this message translates to:
  /// **'Which country does this capital belong to?'**
  String get whichCountryCapitalMsg;

  /// No description provided for @whatIsCapitalMsg.
  ///
  /// In en, this message translates to:
  /// **'What is the capital of this country?'**
  String get whatIsCapitalMsg;

  /// No description provided for @scoreEarned.
  ///
  /// In en, this message translates to:
  /// **'Score Earned'**
  String get scoreEarned;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @sudokuLobbyDesc.
  ///
  /// In en, this message translates to:
  /// **'Test your mind, solve the mystery of numbers and reach the highest score.'**
  String get sudokuLobbyDesc;

  /// No description provided for @sudokuLevel4x4.
  ///
  /// In en, this message translates to:
  /// **'Beginner (4x4)'**
  String get sudokuLevel4x4;

  /// No description provided for @sudokuLevel4x4Desc.
  ///
  /// In en, this message translates to:
  /// **'Take your first step into the Sudoku world'**
  String get sudokuLevel4x4Desc;

  /// No description provided for @sudokuLevel6x6.
  ///
  /// In en, this message translates to:
  /// **'Amateur (6x6)'**
  String get sudokuLevel6x6;

  /// No description provided for @sudokuLevel6x6Desc.
  ///
  /// In en, this message translates to:
  /// **'Improve your skills with medium difficulty'**
  String get sudokuLevel6x6Desc;

  /// No description provided for @sudokuLevel9x9.
  ///
  /// In en, this message translates to:
  /// **'Professional (9x9)'**
  String get sudokuLevel9x9;

  /// No description provided for @sudokuLevel9x9Desc.
  ///
  /// In en, this message translates to:
  /// **'Experience a real Sudoku challenge'**
  String get sudokuLevel9x9Desc;

  /// No description provided for @sudokuLevel16x16.
  ///
  /// In en, this message translates to:
  /// **'Legend (16x16)'**
  String get sudokuLevel16x16;

  /// No description provided for @sudokuLevel16x16Desc.
  ///
  /// In en, this message translates to:
  /// **'Are you ready to solve a massive puzzle?'**
  String get sudokuLevel16x16Desc;

  /// No description provided for @easyDesc.
  ///
  /// In en, this message translates to:
  /// **'Ideal for beginners.'**
  String get easyDesc;

  /// No description provided for @mediumDesc.
  ///
  /// In en, this message translates to:
  /// **'For players who trust themselves.'**
  String get mediumDesc;

  /// No description provided for @hardDesc.
  ///
  /// In en, this message translates to:
  /// **'True masters compete here.'**
  String get hardDesc;

  /// No description provided for @difficultyLobbyDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your level and prove your skills.'**
  String get difficultyLobbyDesc;

  /// No description provided for @hintLabel.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hintLabel;

  /// No description provided for @showHint.
  ///
  /// In en, this message translates to:
  /// **'Show Hint'**
  String get showHint;

  /// No description provided for @noHintMsg.
  ///
  /// In en, this message translates to:
  /// **'No hint available for this question.'**
  String get noHintMsg;

  /// No description provided for @trPlateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Plate Codes'**
  String get trPlateQuiz;

  /// No description provided for @trRegionQuiz.
  ///
  /// In en, this message translates to:
  /// **'City & Region'**
  String get trRegionQuiz;

  /// No description provided for @capitalsTitle.
  ///
  /// In en, this message translates to:
  /// **'World Capitals'**
  String get capitalsTitle;

  /// No description provided for @capitalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Match countries with their capitals'**
  String get capitalsDesc;

  /// No description provided for @plateToCityMsg.
  ///
  /// In en, this message translates to:
  /// **'Which city does this plate code belong to?'**
  String get plateToCityMsg;

  /// No description provided for @cityToPlateMsg.
  ///
  /// In en, this message translates to:
  /// **'What is the plate code of this city?'**
  String get cityToPlateMsg;

  /// No description provided for @cityToRegionMsg.
  ///
  /// In en, this message translates to:
  /// **'In which region is this city located?'**
  String get cityToRegionMsg;

  /// No description provided for @regionToCityMsg.
  ///
  /// In en, this message translates to:
  /// **'Which of these cities is in this region?'**
  String get regionToCityMsg;

  /// No description provided for @thisCountry.
  ///
  /// In en, this message translates to:
  /// **'This country'**
  String get thisCountry;

  /// No description provided for @thisCity.
  ///
  /// In en, this message translates to:
  /// **'This city'**
  String get thisCity;

  /// No description provided for @hintRegionPattern.
  ///
  /// In en, this message translates to:
  /// **'This city is located in the {region} region.'**
  String hintRegionPattern(Object region);

  /// No description provided for @hintPlatePattern.
  ///
  /// In en, this message translates to:
  /// **'The plate code of this city is {plate}.'**
  String hintPlatePattern(Object plate);

  /// No description provided for @hintCapitalPattern.
  ///
  /// In en, this message translates to:
  /// **'The capital of this country is {capital}.'**
  String hintCapitalPattern(Object capital);

  /// No description provided for @hintContinentPattern.
  ///
  /// In en, this message translates to:
  /// **'This country is located in {continent}.'**
  String hintContinentPattern(Object continent);

  /// No description provided for @avrupa.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get avrupa;

  /// No description provided for @asya.
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get asya;

  /// No description provided for @afrika.
  ///
  /// In en, this message translates to:
  /// **'Africa'**
  String get afrika;

  /// No description provided for @amerika.
  ///
  /// In en, this message translates to:
  /// **'America'**
  String get amerika;

  /// No description provided for @okyanusya.
  ///
  /// In en, this message translates to:
  /// **'Oceania'**
  String get okyanusya;

  /// No description provided for @marmara.
  ///
  /// In en, this message translates to:
  /// **'Marmara'**
  String get marmara;

  /// No description provided for @ege.
  ///
  /// In en, this message translates to:
  /// **'Aegean'**
  String get ege;

  /// No description provided for @icAnadolu.
  ///
  /// In en, this message translates to:
  /// **'Central Anatolia'**
  String get icAnadolu;

  /// No description provided for @akdeniz.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get akdeniz;

  /// No description provided for @karadeniz.
  ///
  /// In en, this message translates to:
  /// **'Black Sea'**
  String get karadeniz;

  /// No description provided for @doguAnadolu.
  ///
  /// In en, this message translates to:
  /// **'Eastern Anatolia'**
  String get doguAnadolu;

  /// No description provided for @guneydoguAnadolu.
  ///
  /// In en, this message translates to:
  /// **'Southeastern Anatolia'**
  String get guneydoguAnadolu;

  /// No description provided for @turkiye.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get turkiye;

  /// No description provided for @almanya.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get almanya;

  /// No description provided for @fransa.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get fransa;

  /// No description provided for @italya.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get italya;

  /// No description provided for @ispanya.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get ispanya;

  /// No description provided for @ingiltere.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get ingiltere;

  /// No description provided for @birlesikKrallik.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get birlesikKrallik;

  /// No description provided for @amerikaBirlesikDevletleri.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get amerikaBirlesikDevletleri;

  /// No description provided for @japonya.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get japonya;

  /// No description provided for @cin.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get cin;

  /// No description provided for @rusya.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get rusya;

  /// No description provided for @brezilya.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get brezilya;

  /// No description provided for @kanada.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get kanada;

  /// No description provided for @avustralya.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get avustralya;

  /// No description provided for @yunanistan.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get yunanistan;

  /// No description provided for @hollanda.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get hollanda;

  /// No description provided for @meksika.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get meksika;

  /// No description provided for @hindistan.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get hindistan;

  /// No description provided for @guneyKore.
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get guneyKore;

  /// No description provided for @misir.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get misir;

  /// No description provided for @adana.
  ///
  /// In en, this message translates to:
  /// **'Adana'**
  String get adana;

  /// No description provided for @adiyaman.
  ///
  /// In en, this message translates to:
  /// **'Adiyaman'**
  String get adiyaman;

  /// No description provided for @afyonkarahisar.
  ///
  /// In en, this message translates to:
  /// **'Afyonkarahisar'**
  String get afyonkarahisar;

  /// No description provided for @agri.
  ///
  /// In en, this message translates to:
  /// **'Agri'**
  String get agri;

  /// No description provided for @amasya.
  ///
  /// In en, this message translates to:
  /// **'Amasya'**
  String get amasya;

  /// No description provided for @ankara.
  ///
  /// In en, this message translates to:
  /// **'Ankara'**
  String get ankara;

  /// No description provided for @antalya.
  ///
  /// In en, this message translates to:
  /// **'Antalya'**
  String get antalya;

  /// No description provided for @artvin.
  ///
  /// In en, this message translates to:
  /// **'Artvin'**
  String get artvin;

  /// No description provided for @aydin.
  ///
  /// In en, this message translates to:
  /// **'Aydin'**
  String get aydin;

  /// No description provided for @balikesir.
  ///
  /// In en, this message translates to:
  /// **'Balikesir'**
  String get balikesir;

  /// No description provided for @bilecik.
  ///
  /// In en, this message translates to:
  /// **'Bilecik'**
  String get bilecik;

  /// No description provided for @bingol.
  ///
  /// In en, this message translates to:
  /// **'Bingol'**
  String get bingol;

  /// No description provided for @bitlis.
  ///
  /// In en, this message translates to:
  /// **'Bitlis'**
  String get bitlis;

  /// No description provided for @bolu.
  ///
  /// In en, this message translates to:
  /// **'Bolu'**
  String get bolu;

  /// No description provided for @burdur.
  ///
  /// In en, this message translates to:
  /// **'Burdur'**
  String get burdur;

  /// No description provided for @bursa.
  ///
  /// In en, this message translates to:
  /// **'Bursa'**
  String get bursa;

  /// No description provided for @canakkale.
  ///
  /// In en, this message translates to:
  /// **'Canakkale'**
  String get canakkale;

  /// No description provided for @cankiri.
  ///
  /// In en, this message translates to:
  /// **'Cankiri'**
  String get cankiri;

  /// No description provided for @corum.
  ///
  /// In en, this message translates to:
  /// **'Corum'**
  String get corum;

  /// No description provided for @denizli.
  ///
  /// In en, this message translates to:
  /// **'Denizli'**
  String get denizli;

  /// No description provided for @diyarbakir.
  ///
  /// In en, this message translates to:
  /// **'Diyarbakir'**
  String get diyarbakir;

  /// No description provided for @edirne.
  ///
  /// In en, this message translates to:
  /// **'Edirne'**
  String get edirne;

  /// No description provided for @elazig.
  ///
  /// In en, this message translates to:
  /// **'Elazig'**
  String get elazig;

  /// No description provided for @erzincan.
  ///
  /// In en, this message translates to:
  /// **'Erzincan'**
  String get erzincan;

  /// No description provided for @erzurum.
  ///
  /// In en, this message translates to:
  /// **'Erzurum'**
  String get erzurum;

  /// No description provided for @eskisehir.
  ///
  /// In en, this message translates to:
  /// **'Eskisehir'**
  String get eskisehir;

  /// No description provided for @gaziantep.
  ///
  /// In en, this message translates to:
  /// **'Gaziantep'**
  String get gaziantep;

  /// No description provided for @giresun.
  ///
  /// In en, this message translates to:
  /// **'Giresun'**
  String get giresun;

  /// No description provided for @gumushane.
  ///
  /// In en, this message translates to:
  /// **'Gumushane'**
  String get gumushane;

  /// No description provided for @hakkari.
  ///
  /// In en, this message translates to:
  /// **'Hakkari'**
  String get hakkari;

  /// No description provided for @hatay.
  ///
  /// In en, this message translates to:
  /// **'Hatay'**
  String get hatay;

  /// No description provided for @isparta.
  ///
  /// In en, this message translates to:
  /// **'Isparta'**
  String get isparta;

  /// No description provided for @icelMersin.
  ///
  /// In en, this message translates to:
  /// **'Icel (Mersin)'**
  String get icelMersin;

  /// No description provided for @istanbul.
  ///
  /// In en, this message translates to:
  /// **'Istanbul'**
  String get istanbul;

  /// No description provided for @izmir.
  ///
  /// In en, this message translates to:
  /// **'Izmir'**
  String get izmir;

  /// No description provided for @kars.
  ///
  /// In en, this message translates to:
  /// **'Kars'**
  String get kars;

  /// No description provided for @kastamonu.
  ///
  /// In en, this message translates to:
  /// **'Kastamonu'**
  String get kastamonu;

  /// No description provided for @kayseri.
  ///
  /// In en, this message translates to:
  /// **'Kayseri'**
  String get kayseri;

  /// No description provided for @kirklareli.
  ///
  /// In en, this message translates to:
  /// **'Kirklareli'**
  String get kirklareli;

  /// No description provided for @kirsehir.
  ///
  /// In en, this message translates to:
  /// **'Kirsehir'**
  String get kirsehir;

  /// No description provided for @kocaeli.
  ///
  /// In en, this message translates to:
  /// **'Kocaeli'**
  String get kocaeli;

  /// No description provided for @konya.
  ///
  /// In en, this message translates to:
  /// **'Konya'**
  String get konya;

  /// No description provided for @kutahya.
  ///
  /// In en, this message translates to:
  /// **'Kutahya'**
  String get kutahya;

  /// No description provided for @malatya.
  ///
  /// In en, this message translates to:
  /// **'Malatya'**
  String get malatya;

  /// No description provided for @manisa.
  ///
  /// In en, this message translates to:
  /// **'Manisa'**
  String get manisa;

  /// No description provided for @kahramanmaras.
  ///
  /// In en, this message translates to:
  /// **'Kahramanmaras'**
  String get kahramanmaras;

  /// No description provided for @mardin.
  ///
  /// In en, this message translates to:
  /// **'Mardin'**
  String get mardin;

  /// No description provided for @mugla.
  ///
  /// In en, this message translates to:
  /// **'Mugla'**
  String get mugla;

  /// No description provided for @mus.
  ///
  /// In en, this message translates to:
  /// **'Mus'**
  String get mus;

  /// No description provided for @nevsehir.
  ///
  /// In en, this message translates to:
  /// **'Nevsehir'**
  String get nevsehir;

  /// No description provided for @nigde.
  ///
  /// In en, this message translates to:
  /// **'Nigde'**
  String get nigde;

  /// No description provided for @ordu.
  ///
  /// In en, this message translates to:
  /// **'Ordu'**
  String get ordu;

  /// No description provided for @rize.
  ///
  /// In en, this message translates to:
  /// **'Rize'**
  String get rize;

  /// No description provided for @sakarya.
  ///
  /// In en, this message translates to:
  /// **'Sakarya'**
  String get sakarya;

  /// No description provided for @samsun.
  ///
  /// In en, this message translates to:
  /// **'Samsun'**
  String get samsun;

  /// No description provided for @siirt.
  ///
  /// In en, this message translates to:
  /// **'Siirt'**
  String get siirt;

  /// No description provided for @sinop.
  ///
  /// In en, this message translates to:
  /// **'Sinop'**
  String get sinop;

  /// No description provided for @sivas.
  ///
  /// In en, this message translates to:
  /// **'Sivas'**
  String get sivas;

  /// No description provided for @tekirdag.
  ///
  /// In en, this message translates to:
  /// **'Tekirdag'**
  String get tekirdag;

  /// No description provided for @tokat.
  ///
  /// In en, this message translates to:
  /// **'Tokat'**
  String get tokat;

  /// No description provided for @trabzon.
  ///
  /// In en, this message translates to:
  /// **'Trabzon'**
  String get trabzon;

  /// No description provided for @tunceli.
  ///
  /// In en, this message translates to:
  /// **'Tunceli'**
  String get tunceli;

  /// No description provided for @sanliurfa.
  ///
  /// In en, this message translates to:
  /// **'Sanliurfa'**
  String get sanliurfa;

  /// No description provided for @usak.
  ///
  /// In en, this message translates to:
  /// **'Usak'**
  String get usak;

  /// No description provided for @van.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get van;

  /// No description provided for @yozgat.
  ///
  /// In en, this message translates to:
  /// **'Yozgat'**
  String get yozgat;

  /// No description provided for @zonguldak.
  ///
  /// In en, this message translates to:
  /// **'Zonguldak'**
  String get zonguldak;

  /// No description provided for @aksaray.
  ///
  /// In en, this message translates to:
  /// **'Aksaray'**
  String get aksaray;

  /// No description provided for @bayburt.
  ///
  /// In en, this message translates to:
  /// **'Bayburt'**
  String get bayburt;

  /// No description provided for @karaman.
  ///
  /// In en, this message translates to:
  /// **'Karaman'**
  String get karaman;

  /// No description provided for @kirikkale.
  ///
  /// In en, this message translates to:
  /// **'Kirikkale'**
  String get kirikkale;

  /// No description provided for @batman.
  ///
  /// In en, this message translates to:
  /// **'Batman'**
  String get batman;

  /// No description provided for @sirnak.
  ///
  /// In en, this message translates to:
  /// **'Sirnak'**
  String get sirnak;

  /// No description provided for @bartin.
  ///
  /// In en, this message translates to:
  /// **'Bartin'**
  String get bartin;

  /// No description provided for @ardahan.
  ///
  /// In en, this message translates to:
  /// **'Ardahan'**
  String get ardahan;

  /// No description provided for @igdir.
  ///
  /// In en, this message translates to:
  /// **'Igdir'**
  String get igdir;

  /// No description provided for @yalova.
  ///
  /// In en, this message translates to:
  /// **'Yalova'**
  String get yalova;

  /// No description provided for @karabuk.
  ///
  /// In en, this message translates to:
  /// **'Karabuk'**
  String get karabuk;

  /// No description provided for @kilis.
  ///
  /// In en, this message translates to:
  /// **'Kilis'**
  String get kilis;

  /// No description provided for @osmaniye.
  ///
  /// In en, this message translates to:
  /// **'Osmaniye'**
  String get osmaniye;

  /// No description provided for @duzce.
  ///
  /// In en, this message translates to:
  /// **'Duzce'**
  String get duzce;

  /// No description provided for @ingilizce.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get ingilizce;

  /// No description provided for @ispanyolca.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get ispanyolca;

  /// No description provided for @fransizca.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get fransizca;

  /// No description provided for @almanca.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get almanca;

  /// No description provided for @italyanca.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italyanca;

  /// No description provided for @portekizce.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portekizce;

  /// No description provided for @rusca.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get rusca;

  /// No description provided for @japonca.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japonca;

  /// No description provided for @cince.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get cince;

  /// No description provided for @arapca.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arapca;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @missionQuizDesc.
  ///
  /// In en, this message translates to:
  /// **'Solve {goal} Quizzes'**
  String missionQuizDesc(Object goal);

  /// No description provided for @missionScoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn {goal} Points'**
  String missionScoreDesc(Object goal);

  /// No description provided for @missionWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn {goal} New Words'**
  String missionWordDesc(Object goal);

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover languages and cities while traveling the world!'**
  String get aboutDesc;

  /// No description provided for @dailyChallengeDoneMsg.
  ///
  /// In en, this message translates to:
  /// **'You have completed today\\'**
  String get dailyChallengeDoneMsg;

  /// No description provided for @levelSuffix.
  ///
  /// In en, this message translates to:
  /// **'{level} Level'**
  String levelSuffix(Object level);

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @resetProgressConfirm.
  ///
  /// In en, this message translates to:
  /// **'All learned words in {level} will be reset. Are you sure?'**
  String resetProgressConfirm(Object level);

  /// No description provided for @resetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Level progress has been reset.'**
  String get resetSuccess;

  /// No description provided for @wordsCountMsg.
  ///
  /// In en, this message translates to:
  /// **'There are {count} words in this level.'**
  String wordsCountMsg(Object count);

  /// No description provided for @levelProgress.
  ///
  /// In en, this message translates to:
  /// **'Level Progress'**
  String get levelProgress;

  /// No description provided for @wordsLearnedMsg.
  ///
  /// In en, this message translates to:
  /// **'{mastered} / {total} words learned'**
  String wordsLearnedMsg(Object mastered, Object total);

  /// No description provided for @learnWords.
  ///
  /// In en, this message translates to:
  /// **'Learn Words'**
  String get learnWords;

  /// No description provided for @learnWordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Strengthen your memory with flashcards'**
  String get learnWordsDesc;

  /// No description provided for @testYourself.
  ///
  /// In en, this message translates to:
  /// **'Test Yourself'**
  String get testYourself;

  /// No description provided for @testYourselfDesc.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge, collect stars'**
  String get testYourselfDesc;

  /// No description provided for @masteredWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Mastered Words'**
  String get masteredWordsTitle;

  /// No description provided for @masteredWordsDesc.
  ///
  /// In en, this message translates to:
  /// **'See all you\\'**
  String get masteredWordsDesc;

  /// No description provided for @addCustomWord.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Word'**
  String get addCustomWord;

  /// No description provided for @addCustomWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Add custom words to the list'**
  String get addCustomWordDesc;

  /// No description provided for @viewWordList.
  ///
  /// In en, this message translates to:
  /// **'View Word List'**
  String get viewWordList;

  /// No description provided for @viewWordListDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage all your learned words'**
  String get viewWordListDesc;

  /// No description provided for @practiceTest.
  ///
  /// In en, this message translates to:
  /// **'Take Practice Test'**
  String get practiceTest;

  /// No description provided for @practiceTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Practice with words you\\'**
  String get practiceTestDesc;

  /// No description provided for @selectQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'Select Number of Questions'**
  String get selectQuestionCount;

  /// No description provided for @notEnoughWords.
  ///
  /// In en, this message translates to:
  /// **'Not enough words found.'**
  String get notEnoughWords;

  /// No description provided for @preparingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Preparing questions...'**
  String get preparingQuestions;

  /// No description provided for @ptsLabel.
  ///
  /// In en, this message translates to:
  /// **'PTS'**
  String get ptsLabel;

  /// No description provided for @questionCountMsg.
  ///
  /// In en, this message translates to:
  /// **'Question {index} / {total}'**
  String questionCountMsg(Object index, Object total);

  /// No description provided for @usageInSentence.
  ///
  /// In en, this message translates to:
  /// **'USAGE IN SENTENCE'**
  String get usageInSentence;

  /// No description provided for @meaningPrompt.
  ///
  /// In en, this message translates to:
  /// **'Which is the meaning of this word?'**
  String get meaningPrompt;

  /// No description provided for @congrats.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congrats;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer:'**
  String get correctAnswerLabel;

  /// No description provided for @awesomeMsg.
  ///
  /// In en, this message translates to:
  /// **'You\\'**
  String get awesomeMsg;

  /// No description provided for @challengeResult.
  ///
  /// In en, this message translates to:
  /// **'Challenge Result'**
  String get challengeResult;

  /// No description provided for @testCompleted.
  ///
  /// In en, this message translates to:
  /// **'Test Completed!'**
  String get testCompleted;

  /// No description provided for @levelUnlockedMsg.
  ///
  /// In en, this message translates to:
  /// **'{level} Unlocked!'**
  String levelUnlockedMsg(Object level);

  /// No description provided for @levelLockFailed.
  ///
  /// In en, this message translates to:
  /// **'Lock Not Opened'**
  String get levelLockFailed;

  /// No description provided for @unlockRequirementMsg.
  ///
  /// In en, this message translates to:
  /// **'90% success is required to pass.Your success: %{percentage}'**
  String unlockRequirementMsg(Object percentage);

  /// No description provided for @yourScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR SCORE'**
  String get yourScoreLabel;

  /// No description provided for @totalQuestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Questions: {count}'**
  String totalQuestionsLabel(Object count);

  /// No description provided for @backToAcademy.
  ///
  /// In en, this message translates to:
  /// **'BACK TO ACADEMY'**
  String get backToAcademy;

  /// No description provided for @levelA1Desc.
  ///
  /// In en, this message translates to:
  /// **'Beginner words'**
  String get levelA1Desc;

  /// No description provided for @levelA2Desc.
  ///
  /// In en, this message translates to:
  /// **'Basic daily expressions'**
  String get levelA2Desc;

  /// No description provided for @levelB1Desc.
  ///
  /// In en, this message translates to:
  /// **'Intermediate vocabulary'**
  String get levelB1Desc;

  /// No description provided for @levelB2Desc.
  ///
  /// In en, this message translates to:
  /// **'Words for fluent communication'**
  String get levelB2Desc;

  /// No description provided for @levelC1Desc.
  ///
  /// In en, this message translates to:
  /// **'Advanced expressions'**
  String get levelC1Desc;

  /// No description provided for @levelC2Desc.
  ///
  /// In en, this message translates to:
  /// **'Near-native level'**
  String get levelC2Desc;

  /// No description provided for @levelDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Level study'**
  String get levelDefaultDesc;

  /// No description provided for @chess_invite_waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Chess Invitation...'**
  String get chess_invite_waiting;

  /// No description provided for @difficulty_label.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {difficulty}'**
  String difficulty_label(Object difficulty);

  /// No description provided for @seconds_left_label.
  ///
  /// In en, this message translates to:
  /// **'Seconds Left'**
  String get seconds_left_label;

  /// No description provided for @waiting_for_opponent.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your opponent to accept the invitation.'**
  String get waiting_for_opponent;

  /// No description provided for @cancel_invite.
  ///
  /// In en, this message translates to:
  /// **'CANCEL INVITATION'**
  String get cancel_invite;

  /// No description provided for @invite_timed_out.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up! Invitation timed out.'**
  String get invite_timed_out;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
