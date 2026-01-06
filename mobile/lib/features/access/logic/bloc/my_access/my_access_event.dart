abstract class MyAccessEvent {
  const MyAccessEvent();
}

class MyAccessRequested extends MyAccessEvent {
  final bool refresh;

  const MyAccessRequested({this.refresh = false});
}
