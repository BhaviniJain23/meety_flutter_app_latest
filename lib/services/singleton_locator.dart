import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/persistent_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/services/dynamic_link_service.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/notification_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';

final sl = GetIt.instance;

Future<void> init() async {
  FirebaseDatabase database;
  database = FirebaseDatabase.instance;
  database.setPersistenceEnabled(true);
  database.setPersistenceCacheSizeBytes(10000000);

  sl.registerLazySingleton<SharedPrefsManager>(
    () => SharedPrefsManager(),
  );

  sl.registerLazySingleton(() => PersistentTabControllerService());
  sl.registerLazySingleton(() => LikeListProvider());

  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  sl.registerLazySingleton<ApiHelper>(
    () => ApiHelper(),
  );
  sl.registerLazySingleton<InternetConnectionService>(
    () => InternetConnectionService.getInstance(),
  );
  sl.registerLazySingleton<DynamicLinkService>(
    () => DynamicLinkService(),
  );
  sl.registerLazySingleton<NavigationService>(
    () => NavigationService(),
  );

  sl.registerSingleton<DatabaseReference>(database.ref());

  sl.registerSingleton<ChatRepository>(ChatRepository());

  sl.registerSingleton<UserChatListProvider>(UserChatListProvider());
  sl.registerSingleton<BackgroundTimer>(BackgroundTimer());
}
