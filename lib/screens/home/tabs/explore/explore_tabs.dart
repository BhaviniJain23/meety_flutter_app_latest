import 'package:flutter/material.dart';
import 'package:meety_dating_app/models/interest_model.dart';
import 'package:meety_dating_app/screens/home/widgets/interest_card.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

class ExploreTabs extends StatefulWidget {
  const ExploreTabs({Key? key}) : super(key: key);

  @override
  State<ExploreTabs> createState() => _ExploreTabsState();
}

class _ExploreTabsState extends State<ExploreTabs> {
  final imgList = [
    "https://media.istockphoto.com/photos/aquarium-with-dwarf-cichlid-apistogramma-panduro-fresh-water-tropical-picture-id1352709173?b=1&k=20&m=1352709173&s=170667a&w=0&h=hyDukviH7YTeGxVYlD44dYF6j2MCL9Aq_LSHC4_vjnk=",
    "https://media.istockphoto.com/photos/boat-riding-in-a-river-picture-id606217830?b=1&k=20&m=606217830&s=170667a&w=0&h=u_oTQcaRPv0f6SsYHer50qpZu5YZLa7hP79jZYyz2_o=",
    "https://images.unsplash.com/photo-1599074914978-2946b69e5a4a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8YmVhdXRpZnVsJTIwYmFuZ2xhZGVzaHxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1585123388867-3bfe6dd4bdbf?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmVhdXRpZnVsJTIwYmFuZ2xhZGVzaHxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1606546008984-41818b01968a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8YmVhdXRpZnVsJTIwYmFuZ2xhZGVzaHxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1609692029268-f9ba9b2a728b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8N3x8YmVhdXRpZnVsJTIwYmFuZ2xhZGVzaHxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1558673810-9b0b6316d4f4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fGJlYXV0aWZ1bCUyMGJhbmdsYWRlc2h8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1611563780943-76813488c06f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fGJlYXV0aWZ1bCUyMGJhbmdsYWRlc2h8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1600099492237-711d9141b2f7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTl8fGJlYXV0aWZ1bCUyMGJhbmdsYWRlc2h8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1596292284084-4f1e231b4528?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fGJlYXV0aWZ1bCUyMGJhbmdsYWRlc2h8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1596895111956-bf1cf0599ce5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MjB8fGJlYXV0aWZ1bCUyMGJhbmdsYWRlc2h8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60",
    "https://media.istockphoto.com/photos/tetulia-jame-masjid-at-tala-satkhira-bangladesh-picture-id1056699672?b=1&k=20&m=1056699672&s=170667a&w=0&h=tL5fl2-v3Mtn79LbRiZjPTXvRn-ve802FgJKRqUk9GE=",
    "https://media.istockphoto.com/photos/rural-beauty-picture-id1345380908?b=1&k=20&m=1345380908&s=170667a&w=0&h=Rr7Lg2ozV5alP14N1WLKFasD0vhlGQZimYcq3xetEGY=",
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height * 0.9,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Explore',
                      style: context.textTheme.titleLarge
                          ?.copyWith(fontSize: 18),
                    ),
                    Text(
                      'My Interest...',
                      style: context.textTheme.displaySmall
                          ?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.70),
                itemCount: 3,
                itemBuilder: (BuildContext context, int index) {
                  return InterestCard(
                    interestModel: InterestModel(
                        id: 1,
                        image: imgList[index],
                        interest: 'Date Night',
                        tagline: 'Go to someone whose right for you'),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For You',
                      style: context.textTheme.titleLarge
                          ?.copyWith(fontSize: 18),
                    ),
                    Text(
                      'Recommended on basis of your interest.',
                      style: context.textTheme.displaySmall
                          ?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75),
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  return InterestCard(
                    interestModel: InterestModel(
                        id: 1,
                        image: imgList[index],
                        interest: 'Date Night',
                        tagline: 'Go to someone whose right for you'),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
