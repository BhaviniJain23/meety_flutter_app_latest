// ignore_for_file: constant_identifier_names

enum DataState {
  Uninitialized,
  Initial_Fetching,
  Searching,
  Refreshing,
  More_Fetching,
  Fetched,
  No_More_Data,
  Error
}

enum LoadingState {
  Uninitialized,
  Loading,
  NoInternet,
  Success,
  Failure,
}

enum FileTypes { IMAGE, VIDEO, PDF, PPT, EXCEL, DOC, TEXT, GIF }

enum NotificationType { Matches, Visitor, Chat, Like, None }

enum CardType {
  Master,
  Visa,
  Discover,
  AmericanExpress,
  DinersClub,
  Jcb,
}
