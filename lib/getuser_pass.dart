import 'dart:convert';
import 'package:http/http.dart' as http;

class UsersService {
  static final UsersService _singleton = UsersService._internal();
  UsersService._internal();
  static UsersService get instance => _singleton;

  final String url =
      "https://67e251bf97fc65f535356b57.mockapi.io/api/v1/userpass";

  Future<List<dynamic>> getUsers() async {
    http.Response data = await http.get(Uri.parse(url));
    if (data.statusCode == 200) {
      //Test the data
      print(data.body);

      return jsonDecode(data.body);
    } else {
      return [];
    }
  }

  Future<dynamic> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$url/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Successfully updated
        return jsonDecode(response.body);
      } else {
        // Handle error
        print('Failed to update user. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle any network or parsing errors
      print('Error updating user: $e');
      return null;
    }
  }

  Future<dynamic> createUser(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        // Most APIs return 201 (Created) for successful POST requests
        return jsonDecode(response.body);
      } else {
        print('Failed to create user. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<dynamic> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$url/$id'),
      );

      if (response.statusCode == 200) {
        // Successful deletion
        return jsonDecode(response.body);
      } else {
        print('Failed to delete user. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error deleting user: $e');
      return null;
    }
  }
}
