import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/screens/author_publications_screen.dart';
import 'package:wordsmith_mobile/screens/ebook_screen.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/profile/profile_image.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/ebook/ebook_search.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_statistics.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/providers/user_statistics_provider.dart';

class ProfileScreenWidget extends StatefulWidget {
  final int userId;

  const ProfileScreenWidget({super.key, required this.userId});

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  late UserProvider _userProvider;
  late UserStatisticsProvider _userStatisticsProvider;
  late EbookProvider _ebookProvider;

  late Future<Result<User>> _userFuture;
  late Future<Result<QueryResult<UserStatistics>>> _userStatisticsFuture;
  late Future<Result<QueryResult<Ebook>>> _ebooksFuture;

  final _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 11.0,
  );

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("User"),
      centerTitle: true,
    );
  }

  Widget _buildUsernameCard(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Username",
              style: _labelStyle,
            ),
            Text(
              user.username,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberDateCard(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Member since",
              style: _labelStyle,
            ),
            Text(formatDateTime(
              date: user.registrationDate,
              format: "yMMMMd",
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(User user) {
    return SizedBox(
      width: double.infinity,
      height: 130.0,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "About me",
                style: _labelStyle,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    user.about,
                    softWrap: true,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return FutureBuilder(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        late User user;

        switch (snapshot.data!) {
          case Success<User>(data: final d):
            user = d;
          case Failure<User>(exception: final e):
            return Center(child: Text(e.message));
        }

        return Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
                  child: ProfileImageWidget(
                    profileImagePath: user.profileImage?.imagePath,
                    radius: 72.0,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Builder(builder: (context) => _buildUsernameCard(user)),
                      Builder(builder: (context) => _buildMemberDateCard(user)),
                    ],
                  ),
                ),
              ],
            ),
            Builder(builder: (context) => _buildAboutCard(user)),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsCounter() {
    return FutureBuilder(
      future: _userStatisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        late UserStatistics userStatistics;

        switch (snapshot.data!) {
          case Success(data: final d):
            userStatistics = d.result.first;
          case Failure(exception: final e):
            return Center(child: Text(e.message));
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkResponse(
                  onTap: () => _openAuthorPublicationsScreen(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userStatistics.publishedBooksCount.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                          ),
                        ),
                        const Text("Published books"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkResponse(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userStatistics.favoriteBooksCount.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                          ),
                        ),
                        const Text("Favorite books"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBooksCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                "My books",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              TextButton(
                  onPressed: () => _openAuthorPublicationsScreen(),
                  child: const Text("View all")),
            ],
          ),
          FutureBuilder(
            future: _ebooksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              late List<Ebook> ebooks;

              switch (snapshot.data!) {
                case Success(data: final d):
                  ebooks = d.result;
                case Failure(exception: final e):
                  return Center(child: Text(e.message));
              }

              return CarouselSlider.builder(
                options: CarouselOptions(
                  viewportFraction: 0.50,
                  pageSnapping: true,
                  enlargeCenterPage: false,
                ),
                itemCount: ebooks.length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  if (ebooks.isEmpty) {
                    return Container();
                  }

                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              EbookScreenWidget(ebookId: ebooks[itemIndex].id),
                        ));
                      },
                      child: EbookImageWidget(
                        coverArtUrl: ebooks[itemIndex].coverArt.imagePath,
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _openAuthorPublicationsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              AuthorPublicationsScreenWidget(userId: widget.userId)),
    );
  }

  void _getUser() {
    _userFuture = _userProvider.getUser(widget.userId);
  }

  void _getUserStatistics() {
    _userStatisticsFuture =
        _userStatisticsProvider.getUserStatistics(widget.userId);
  }

  void _getUserEbooks() {
    var search = EbookSearch(authorId: widget.userId);
    _ebooksFuture = _ebookProvider.getEbooks(search, page: 1, pageSize: 5);
  }

  @override
  void initState() {
    _userProvider = context.read<UserProvider>();
    _userStatisticsProvider = context.read<UserStatisticsProvider>();
    _ebookProvider = context.read<EbookProvider>();
    _getUser();
    _getUserStatistics();
    _getUserEbooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Builder(builder: (context) => _buildUserInfo()),
            const Divider(),
            Flexible(
              flex: 1,
              child: Builder(builder: (context) => _buildStatisticsCounter()),
            ),
            Flexible(
              flex: 3,
              child: Builder(builder: (context) => _buildBooksCarousel()),
            ),
          ],
        ),
      ),
    );
  }
}
