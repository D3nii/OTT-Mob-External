import 'package:onetwotrail/repositories/enums/resource_state.dart';

class Resource<T> {
  T data;
  ResourceState state;

  Resource(this.data, this.state);
}
