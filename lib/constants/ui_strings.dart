class UiString {
  /// Common strings & regular expressions
  static final emailCharSet = RegExp(r"[a-zA-Z\d.@!#$%&'*+/=?^_`{|}~-]");
  static final emailRegEx = RegExp(
    r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|"
    r'[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+'
    r"(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|"
    r'[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|'
    r'((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?'
    r'(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]'
    r'|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])'
    r'|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|'
    r'[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*'
    r'(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))'
    r'@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|'
    r'(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])'
    r'([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*'
    r'([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)'
    r'+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]'
    r'|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|'
    r'[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|'
    r'[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$',
  );
  static final nameRegEx = RegExp('[a-z A-Z]');
  static final numberRegEx = RegExp('[0-9]');
  static final normalizationRegEx = RegExp('-|_');
  static const space = ' ';
  static const error = 'Something went wrong!';
  static const invalidAccessToken = 'invalid Access Token!';
  static const nothingFound = 'No data found!';
  static const noJobsYet = 'No Jobs Yet!';
  static const noInternet = 'Oops, no internet connection';
  static const noInternetCaption =
      'Make sure wifi or cellular data is turned on and then try again.';
  static const pageNotFound = 'Page not found';
  static const charSet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

  /// Splash view
  static const appMotto = 'Find help near you';

  /// Onboarding flow
  static const appTitle = 'Meety';
  static const signInHeading = 'Sign in to continue';
  static const usePhoneNumber = 'Continue with phone';
  static const signInWith = 'or continue with';
  static const captionForTermsAndCondition =
      'When you create an account, you are affirming that you are of legal age, which is a minimum of 18 years old, and that you consent to abide by our ';
  static const termsAndConditions = 'Terms & Conditions';
  static const andText = ' and ';
  static const privacyPolicy = 'Privacy Policy';
  static const skipBtn = 'Skip';
  static const googleBtn = 'Sign in with Google';
  static const facebookBtn = 'Sign in with Facebook';
  static const appleBtn = 'Sign in with Apple';
  static const emailChoice = 'Continue with email';
  static const getStartedText = 'Get Started';
  static const otpSent = 'OTP Sent Successful';
  static const otpCaption = 'Type the verification code we\'ve sent you to ';
  static const signInText = 'Sign in';
  static const sendOTPText = 'Send OTP';
  static const forgotPasswordText = 'Forgot Password';
  static const forgotPasswordCaptionText =
      '''Please enter your email address and we will send you an email to reset your password''';
  static const sendMailText = 'Send Mail';
  static const resetPasswordText = 'Reset Password';
  static const resetPasswordCaptionText =
      '''Enter a new password that must be different from previously used passwords.''';
  static const createNewPasswordText = 'Create New Password';
  static const changePasswordSnackbarText = 'Your password has been changed.';
  static const resendText = 'Resend Code';
  static const profileDetailText = 'Profile Details';
  static const myMobile = 'My mobile';
  static const myName = 'Tell us about you';
  static const myNameText = 'My name is';
  static const chooseBirthdayDate = 'Choose birthday date';
  static const emailBtn = 'Sign in with Email';
  static const emailText = 'Email Address';
  static const verificationEmailInYourInbox =
      "If you don't see the verification email in your inbox, please check your spam folder and mark it as Not Spam to ensure you receive future emails from us.";

  static const phoneText = 'Phone Number';
  static const firstNameText = 'First Name* ';
  static const nameText = 'Name';
  static const aboutText = 'About';
  static const lastNameText = 'Last Name';
  static const dobText = 'Date of birth* ';
  static const myBirthText = 'My Birthdate is ';
  static const important = "Important:";
  static const dobImportantText =
      ' Please note that some criteria, like birthdate, cannot be changed after you submit them. Make sure to double-check your information before proceeding. We want to ensure the accuracy of profiles and matches for a better experience.';
  static const next = 'Next';
  static const update = 'Update';
  static const access = 'Access';
  static const continueText = 'Continue';
  static const mayBeLaterText = 'May be later';
  static const whatYourGenderText = 'What\'s your gender?';
  static const mySexOrientationText = 'What is your sex orientation?';
  static const showMe = 'Show me';
  static const iAmLookingFOr = 'What are your Match Preferences?';
  static const matchPreferences = 'Match Preferences';
  static const matchPreferencesGoals = 'Goals';
  static const yourInterest = 'Let us know your Hobbies & Interests';
  static const interest = 'Hobbies & Interests';
  static const languages = 'Languages';
  static const addLanguages = 'Add languages';
  static const enterYourEmailAddress = 'Enter your Email address';
  static const enterYourPassword = 'Enter your password';
  static const enterYourConfirmPassword = 'Enter your confirm password';
  static const enterYourFirstName = 'Enter valid first name';
  static const enterYourLastName = 'Enter valid last name';
  static const enterYourAbout = 'Enter your about';
  static const enterYourDOB = 'Enter a valid date of birth';
  static const knownLanguages = 'Known Languages';
  static const addPhotos = 'Add Photos';
  static const editPhotos = 'Edit Photos';
  static const discover = 'Discover';
  static const messages = 'Messages';
  static const basic = 'Basics';
  static const zodiac = 'Zodiac';
  static const noBlockedContacts = "No Blocked Contacts";
  static const importContact = "Import Contact";
  static const blockPeoplebyUsingtheContacts =
      "Block People by using the Contacts tab to select anyone you don't want to see";
  static const knowOnMeety = "Want to avoid someone you know on Meety?";
  static const contactsWithMeety =
      "it's easy - share your device's contacts with Meety when using this feature to pick who you want to avoid.";
  static const education = 'Education';
  static const futurePlan = 'Future Plan';
  static const covidVaccine = 'Covid Vaccine';
  static const personalityType = 'Personality Type';
  static const habit = 'Habit';
  static const occupations = 'Occupation';
  static const addOccupation = 'Add Occupation';
  static const profileVerified = "Profile Verified";
  static const company = 'Company';
  static const addCompany = 'Add Company';
  static const school = 'School';
  static const addSchool = 'Add School';
  static const livingIn = 'Living in';
  static const addCity = 'Add City';
  static const setting = 'Setting';
  static const subscriptionPlans = 'Plan';
  static const subscriptionToPremium = 'Subscribe To Premium';
  static const subscriptionToPremiumCaption =
      'Unlock Love\'s Secrets: Elevate Your Dating Experience with Our Exclusive Subscription Plans 💕';
  static const editProfile = 'Edit Profile';
  static const accountSetting = 'Account Setting';
  static const discoverSetting = 'Discover Setting';
  static const location = 'Location';
  static const global = 'Global';
  static const autoRenew = "To Keep Your Subscription Active:";
  static const myCurrentLocation = 'My Current Location';
  static const addNewLocation = 'Add a new Location';
  static const maximumDistance = 'Maximum Distance';
  static const distance = 'Distance';
  static const ageRange = 'Age Range';
  static const onlyShowPeople = 'Only Show People in this range';
  static const activityStatus = 'Activity Status';
  static const managePaymentMethod = "Manage Payment Method";
  static const paymentAccount = "Payment Account";
  static const availablePaymentMethod = "Available Payment Method";
  static const addCreditOrDebitCard = "Add Credit Or Debit Card";
  static const addCard = "Add Card";
  static const yourPlan = "Your Plan";
  static const recentlyActiveStatus = 'Recently Active Status';
  static const online = 'Online';
  static const onlineOffline = 'Online / Offline';
  static const active = 'Active People';
  static const showActivityStatus = 'Online';
  static const showOnline = 'Show Online Status';
  static const showDistance = 'Show Distances in. ';
  static const km = 'Km.';
  static const mi = 'Mi.';
  static const notifications = 'Notifications';
  static const notificationSettings = "Notification Settings";
  static const pushNotifications = 'Push Notifications';
  static const pushEmailNotifications = "Push Email Notifications";
  static const team$appTitle = '$appTitle Team';
  static const contactUs = 'Contact Us';
  static const helpSupport = 'Help & Support';
  static const community = 'Community';
  static const communityGuide = 'Community Guidelines';
  static const safetyTip = 'Safety Tips';
  static const safetyCenter = 'Safety Center';
  static const privacy = 'Privacy';
  static const privacyPreferences = 'Privacy Preferences';
  static const legal = 'Legal';
  static const licenses = 'Licenses';
  static const termsOfServices = 'Terms of Services';
  static const logout = 'Logout';
  static const deactivateAccount = 'Deactivate Account';
  static const deleteAccount = 'Delete Account';
  static const shareTinder = 'Share $appTitle';
  static const shareProfile = 'Share Profile';
  static const reportUser = 'Report';
  static const notification = "Notification";
  static const tryAgain = 'Try again';
  static const msgCantBeEmpty = 'Your message can\'t  be empty';
  static const viewProfile = "View Profile";
  static const premium = "Premium";
  static const premiumPlan = "Premium Plan";
  static const myMobileSubCaption =
      'Please enter your valid phone number. We will send you a 4-digit code to verify your account.';
  static const interestSubCaptionBold = 'Select at least 4 of your interest';
  static const interestSubCaption =
      ' and let everyone know what you are passionate about.';
  static const lookingForSubCaption =
      "We don't want to create preconceived restrictions for all of you. So here is the default answers of that awkward question.";
  static const addPhotosSubCaption =
      'To get more match, pick your best photos. Make sure you are clearly visible and add at least 1 photos to continue.';
  static const basicSubCaption = 'Describe about your best';
  static const editPhotoSubCaption =
      "You can change the position of images with simply dragging them.";
  static const enableLocation =
      'will allows you to see who is nearby in real-time, which can facilitate spontaneous meetups & interactions.';
  static const enableLocationSubCaption = 'Enable Location';
  static const aboutMeSubCaption =
      'Let others know who you are, what you like to do. It can be used to convey what you\'re looking for in a match.';
  static const oops = 'Oops !!';
  static const block = "Block";
  static const blockContact = "Block Contact";
  static const openSetting = 'Open Settings';
  static const notNow = 'Not Now';
  static const camera = 'Camera';
  static const gallery = 'Gallery';
  static const remove = 'Remove';
  static const blockText = 'Block';
  static const reportText = 'Report';
  static const unMatch = "UnMatch";
  static const selectCamera = 'Allow access to your camera';
  static const selectCameraDesc =
      'Allow $appTitle to use your camera to set a profile picture.';
  static const selectGallery = 'Allow access to your gallery';
  static const selectGalleryDesc =
      'Allow $appTitle to use your gallery to set a profile picture.';
  static const selectContact = 'Allow access to your contact';
  static const selectContactDesc =
      'Allow $appTitle to use your contact to block user.';

  static const man = 'Male';
  static const woman = 'Female';
  static const trans = 'Trans';
  static const everyone = 'Everyone';
  static const educationRestricted = 'Education is Restricted.';

  static const straight = 'Straight';
  static const homosexual = 'Homosexual';
  static const bisexual = 'Bisexual';
  static const asexual = 'Asexual';
  static const demisexual = 'Demisexual';
  static const pansexual = 'Pansexual';
  static const queer = 'Queer';
  static const bicurious = 'Bicurious';
  static const notToSay = 'Not to Say';
  static const selectOptions = "You can select up to two options";

  static const longtermPartner = 'Long-term partner';
  static const longtermButShortPartner = 'Long-term, but short-term OK';
  static const shortTermButLongPartner = 'Short-term but long-term OK';
  static const shortTerm = 'Short-term fun';
  static const newFriends = 'New friends';
  static const figuringOut = 'Still figuring it out';
  static const openToOptions = "😄 Open to options";
  static const longTermRelationship = "❤️ Long-term relationship";
  static const marriageMinded = "💍 Marriage-minded";
  static const casualDating = "⏳ Casual dating/Short-term dating";
  static const friendship = "🤝 Friendship";
  static const meaningfulConversations = "💬 Meaningful conversations";
  static const activityPartners = "🎉 Activity partners";
  static const noStringsAttached = "🚫 No strings attached/Open relationship";
  static const virtualConnections = "🌐 Virtual connections/Networking";
  static const travelCompanions = "🌴 Travel companions";
  static const fitnessBuddies = "🏋️‍♂️ Fitness buddies";
  static const gamingEnthusiasts = "🎮 Gaming enthusiasts";

  static const showGenderText = 'Show my gender on profile';
  static const showSexOrientationText = 'Show my orientation on profile';
  static const showMeMyShowText = 'Show me on profile';
  static const successText = 'success';
  static const messageText = 'message';
  static const dataText = 'data';

  //zodiac sign
  static const zodiacQue = 'What \'s your zodiac sign ?';
  static const aries = 'Aries';
  static const aquarius = 'Aquarius';
  static const cancer = 'Cancer';
  static const taurus = 'Taurus';
  static const gemini = 'Gemini';
  static const leo = 'Leo';
  static const virgo = 'Virgo';
  static const libra = 'Libra';
  static const scorpio = 'Scorpio';
  static const sagittarius = 'Sagittarius';
  static const capricorn = 'Capricorn';
  static const pisces = 'Pisces';

  //education que
  static const educationQue = 'What \'s your education level ?';
  static const doctoralDeg = 'Doctoral Degree';
  static const professionalDeg = 'Professional Degree';
  static const masterDeg = 'Master Degree';
  static const bachelorDeg = 'Bachelor\'s Degree';
  static const associateDeg = 'Associate Degree';
  static const someClgNoDeg = 'At University';
  static const highSchool = 'High School';
  static const diploma = 'Diploma Degree';
  static const lifelongLearner = 'Lifelong Learner';
  static const collegeDropoutPassionPursuer = 'College Dropout/Passion Pursuer';
  static const academicExplorer = 'Academic Explorer';
  static const creativeSelfTaught = 'Creative Self-Taught';
  static const onlineCourseEnthusiast1 =
      'Online Course Enthusiast'; // You had this listed twice, so I added a number
  static const militaryServiceGraduate = 'Military Service Graduate';
  static const parentingUniversity = 'Parenting University';
  static const hybridEducationJourney = 'Hybrid Education Journey';
  static const schoolDropOut = "School DropOut";
  static const charteredAccount = "Chartered Account";
  static const other = 'Other';

  //family plan que
  static const familyPlanQue = 'What \'s your future plan ?';
  static const wantChild = 'I want children';
  static const dontWantChild = 'I don\'t want children';
  static const haveChildAndWant = 'I have children and want more';
  static const haveChildAndDontWant = 'I have children and don\'t want more';
  static const notSureChild = 'Not sure yet';
  static const startingAFamily = 'Starting a Family';
  static const alreadyAParent = 'Already a Parent';
  static const childFreeByChoice = 'Child-Free by Choice';
  static const blendedFamily =
      'Blended Family: Part of a blended family with stepchildren or shared custody. (I have children & want more)';
  static const petParent = 'Pet Parent';
  static const openToCoParenting = 'Open to co-parenting';
  static const parentingPartner =
      'Parenting Partner: Enjoys being a supportive figure in a partner\'s existing parenting role.';
  static const careerOverFamily = 'Career Focus over starting a family';
  static const travelAndAdventure =
      'Travel and Adventure: Plans to travel and explore before considering family life.';
  static const nurturingRelationships = 'Nurturing Relationships';
  static const elderCare = 'Elder Care';
  static const culturalTraditions = 'Cultural Traditions';
  static const undecided = 'Undecided';

  //vaccinated que
  static const vaccinatedQue = 'Are you vaccinated ? ';
  static const vaccinated = 'Vaccinated';
  static const notVaccinated = 'Not Vaccinated';
  static const preferNotVaccinated = 'Prefer not to say';

  //personality type que
  static const personalityQue = 'What \'s your personality type ? ';

  //error message
  static const loginFailed =
      'Your email or password is incorrect, Please try again.';
  static const photosRestriction = 'You must have at least 2 photos.';

  static const accountSettingUpdateDesc =
      'After updating account setting, you must verify first. '
      'Without verification, you cannot logged in an app.';
  static const accountSettingUpdatePhone =
      "Your phone number is valuable to us and will be treated with the utmost care. We will not use it for any other purposes except for enabling the feature of blocking family members on our platform, and that too, with your express consent. Your privacy and security are our priorities.";

  static const accountSettingUpdateName =
      'If you change your name on $appTitle, you can\'t change it for 14 days.';

  static const accountSettingUpdateDOB =
      'Make sure to double-check your information before proceeding. We want to ensure the accuracy of profiles and matches for a better experience.';
  static const accountSettingDOB =
      "If you change your birthdate on $appTitle, you can't change it for 1 month.";
  static const importants = "Important: ";
  static const signInCaptionText = 'Create a New Account ?';
  static const signUpText = 'Sign up';
  static const signUpCaptionText = 'Already have an Account? ';

  static const addressText = 'Address';
  static const addressHintText = 'Your address';
  static const passwordText = 'Password';
  static const passwordHintText = 'Your password';
  static const newPasswordHintText = 'New password';
  static const confirmPasswordText = 'Confirm Password';
  static const changePasswordText = 'Change Password';
  static const confirmPasswordHintText = 'Confirm password';
  static const confirmText = 'Confirm';
  static const okayText = 'Okay';
  static const verifiedAgainText = 'Verification Again';
  static const submitText = 'Submit';
  static const documentVerifyText = 'We need to verify your ID';
  static const verifyText = 'Verify';
  static const emailRequired = 'Email is required !';
  static const validEmailRequired = 'Valid Email is required !';
  static const firstNameRequired = 'First Name is required !';
  static const lastNameRequired = 'Last Name is required !';
  static const addressRequired = 'Address is required !';
  static const phoneRequired = 'Phone is required !';
  static const validPhoneNumberRequired = 'Valid phone number required !';
  static const passwordRequired = 'Password is required !';
  static const confirmationRequired = 'Confirmation is required !';
  static const passwordMismatch = 'Password mismatch !';
  static const restartApp = 'Please restart the app !';
  static const userExistsOnMail =
      'User already exists.\nPlease sign in using Email !';
  static const authenticationError =
      'Could not authenticate the user.\nPlease contact support !';
  static const weakPasswordError = 'The password provided is too short.';
  static const accountInUseError = 'The account already exists for that email.';
  static const noUserFound = 'No User for this email ! Please sign up !';
  static const signInCancelled = 'Sign in was cancelled';
  static const appleLoginError = 'Apple Login is not available';

  static const noPeopleAroundYou =
      'There\'s no one around you. Expand your discovery setting to see more people.';

  static String educationNote =
      "Including a variety of choices acknowledges because education can take many forms and goes beyond traditional degrees.";
  static String aboutMe = "About Me";
  static String reasonForReportUser = "Why are you reporting this user?";
  static String thanksForReporting = "Thanks for reporting";
  static String thanksForReportingCaption =
      "We'll take action against this account if we find that it goes against our policy. Thanks for helping us keep $appTitle safe and supportive one.";
  static String blockCaption =
      "We'll take action against this account if we find that it goes against our policy. Thanks for helping us keep $appTitle safe and supportive one.";

  static String timeOutError =
      "Oops, It takes too long to respond. Please try again later or contact support.";

  static var emptyLikesTitle = 'Oops !! No Likes Found';
  static var emptyLikesSentTitle = 'Oops !! No Sent Likes Found';
  static var emptyVisitorsTitle = 'Oops !! No Visitors Found';
  static var emptyLikesCaption =
      'Be active and engage with others: Log in regularly, update your profile photos every few months, like and message other people. An active profile gets more visibility and engagement.';

  static var clearText = 'Clear';

  static var likesText = 'Likes';
  static var matchText = "Match";
  static var msgRequests = "Message Requests";
  static var msgMatch = "Message Match";

  static var likeSentText = 'Likes Sent';

  static var visitorText = 'Visitor';

  // Verification:
// Constants for static text
  static String verificationDescription =
      'We will compare the face in your video selfie to the pics in your profile. '
      'After that, we will delete your recognition information once verification is complete - usually in less than 24 hours.';

  static String enableCameraTitle = 'Enable Camera';
  static String enableCameraCaption =
      'Allow $appTitle to take a picture to verify your profile.';
  static String openSettingButtonText = 'Open Setting';
  static String startRecordingButtonText = 'Start Recording';
  static String stopRecordingButtonText = 'Stop Recording ';
  static String uploadVerificationVideoTitle = 'Upload Your Verification Video';
  static String uploadVerificationVideoMessage =
      'Are you sure you want to upload this video for verification?';
  static String yesButtonText = 'Yes';
  static String noButtonText = 'No';
  static String videoDurationErrorMessage =
      'Your Video must be greater than 10 seconds.';

  static String buyPlan = 'Buy Plan';
  static String upgradePlan = 'Upgrade Plan';
  static String payNow = 'Pay Now';

  static var paymentMethod = "Payment Method";

  static String saveThisCard = "Save this Card for future purchases";

  static String deleteYourCardDetails =
      "You'll be able to delete your card details at any time form your settings.";

  static String days = "Days";

  static Future<Map<String, dynamic>> fixFailResponse(
      {String? errorMsg}) async {
    return {successText: false, messageText: errorMsg ?? error};
  }

  static Future<Map<String, dynamic>> noInternetResponse(
      {String? errorMsg}) async {
    return {successText: false, messageText: noInternet};
  }
}
