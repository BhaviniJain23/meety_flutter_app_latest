import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/models/interest_model.dart';
import 'package:meety_dating_app/screens/home/tabs/explore/explore_users.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

import '../../../services/singleton_locator.dart';

class InterestCard extends StatelessWidget {
  final InterestModel interestModel;

  const InterestCard({Key? key, required this.interestModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        sl<NavigationService>().navigateTo(RoutePaths.exploreUserScreen,
            nextScreen: ExploreUsersScreen(interestModel: interestModel));
      },
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
            color: whitesmoke, borderRadius: BorderRadius.circular(5)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ).createShader(
                      Rect.fromLTRB(0, -140, rect.width, rect.height));
                },
                blendMode: BlendMode.darken,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image(
                    image: NetworkImage(interestModel.image),
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: white.withOpacity(0.6)),
                  child: Text(
                    interestModel.interest,
                    style: const TextStyle(
                        // color: white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        fontSize: 13),
                  ),
                )),
            Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 15, bottom: 5),
                  child: Text(
                    interestModel.tagline,
                    style: context.textTheme.titleSmall?.copyWith(
                        color: white,
                        fontWeight: FontWeight.w400,
                        fontSize: 13),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
