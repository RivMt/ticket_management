import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/firebase.dart';
import 'package:ticket_management/models/model.dart';

class ModelsState<T extends Model> extends StateNotifier<List<T>> {

  ModelsState(this.ref, this.convert) : super([]);

  final Ref ref;

  final T Function(Map<String, dynamic>) convert;

  /// Clear state
  void clear() => state = [];

  Future<void> set(String section, String namespace, T data) async {
    final client = FirebaseHelper();
    await client.set<T>(
      section: section,
      namespace: namespace,
      data: data,
    );
    get(section, namespace);
  }

  /// Request [T] items fit to [condition] and filter by [options]
  ///
  /// This method overrides [state]
  Future<void> get(String section, String namespace) async {
    final client = FirebaseHelper();
    final List<Map<String, dynamic>> response = await client.gets<T>(
      section: section,
      namespace: namespace,
    );
    if (response.isEmpty) {
      return;
    }
    state = List<T>.generate(response.length, (index) => convert(response[index]));
  }
}

class ModelState<T extends Model> extends StateNotifier<T> {

  ModelState(this.ref, this.base, this.convert) : super(base);

  final Ref ref;

  final T base;

  final T Function(Map<String, dynamic>) convert;

  /// Clear state
  void clear() => state = base;

  Future<void> set(String section, String namespace, T data) async {
    final client = FirebaseHelper();
    await client.set<T>(
      section: section,
      namespace: namespace,
      data: data,
    );
    get(section, namespace, data.code);
  }

  Future<void> update(String section, String namespace, T data) async {
    final client = FirebaseHelper();
    await client.update<T>(
      section: section,
      namespace: namespace,
      data: data,
    );
    get(section, namespace, data.code);
  }

  Future<void> inject(T data) async {
    state = data;
  }

  /// Request [T] items fit to [condition] and filter by [options]
  ///
  /// This method overrides [state]
  Future<void> get(String section, String namespace, String uid) async {
    final client = FirebaseHelper();
    final Map<String, dynamic>? response = await client.get<T>(
      section: section,
      namespace: namespace,
      doc: uid,
    );
    if (response == null) {
      return;
    }
    state = convert(response);
  }
}