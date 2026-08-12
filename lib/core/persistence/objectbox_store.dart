import 'package:path_provider/path_provider.dart';

import '../../objectbox.g.dart';


class ObjectBoxStore {

  const ObjectBoxStore(this.store);

  final Store store;

  static Future<ObjectBoxStore> create() async {
    final directory = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${directory.path}/objectbox');
    return ObjectBoxStore(store);
  }
}
