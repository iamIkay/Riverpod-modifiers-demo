import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_modifiers/modifiers/user_helper.dart';
import 'package:riverpod_modifiers/user_card.dart';

class UserRequest {
  final bool isFemale;
  final int minAge;

  const UserRequest({
    required this.isFemale,
    required this.minAge
});

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
      other is UserRequest &&
        runtimeType == other.runtimeType &&
  isFemale == other.isFemale &&
  minAge == other.minAge;

  @override
  int get hashCode => isFemale.hashCode ^ minAge.hashCode;

}

Future<User> fetchUser(UserRequest request) async {
  await Future.delayed(const Duration(milliseconds: 400));
  final gender = request.isFemale ? 'female' : 'male';

  return users.firstWhere(
          (user) => user.gender == gender && user.age >= request.minAge);
}

final userProvider = FutureProvider.family<User, UserRequest> ((ref, userRequest)async => fetchUser(userRequest));

class FamilyObjectPage extends StatefulWidget {
  const FamilyObjectPage({Key? key}) : super(key: key);

  @override
  _FamilyObjectPageState createState() => _FamilyObjectPageState();
}

class _FamilyObjectPageState extends State<FamilyObjectPage> {
  static final ages = [18, 25, 30, 40];
  bool isFemale = true;
  int minAge = ages.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FamilyObject Modifier"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: Consumer(builder: (context, ref, child){
                  final userRequest =
                  UserRequest(isFemale: isFemale, minAge: minAge);

                  final future = ref.watch(userProvider(userRequest));

                  return future.when(
                      data: (user) => UserCard(user: user),
                      error: (e, stack) => Center(child: Text("No user found")),
                      loading: () => CircularProgressIndicator());

                },
                ),

            ),

            const SizedBox(height: 32),
            buildSearch()
          ],
        ),
      ),
    );
  }

  Widget buildSearch() => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        buildGenderSwitch(),
        const SizedBox(height: 16),
        buildAgeDropdown(),
      ],
    ),
  );

  Widget buildGenderSwitch() => Row(
    children: [
      Text(
        'Female',
        style: TextStyle(fontSize: 24),
      ),
      Spacer(),
      CupertinoSwitch(
        value: isFemale,
        onChanged: (value) => setState(() => isFemale = value),
      ),
    ],
  );

  Widget buildAgeDropdown() => Row(
    children: [
      Text(
        'Age',
        style: TextStyle(fontSize: 24),
      ),
      Spacer(),
      DropdownButton<int>(
        value: minAge,
        iconSize: 32,
        style: TextStyle(fontSize: 24, color: Colors.black),
        onChanged: (value) => setState(() => minAge = value!),
        items: ages
            .map<DropdownMenuItem<int>>(
                (int value) => DropdownMenuItem<int>(
              value: value,
              child: Text('$value years old'),
            ))
            .toList(),
      ),
    ],
  );



}
