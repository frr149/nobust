class Notification<Sender, Payload> {
  // Fields
  late final String _name;
  late final Sender? _sender;
  late final Payload? _payload;

  // Accessors
  String get name => _name;
  Sender? get sender => _sender;
  Payload? get payload => _payload;

  // Constructors
  Notification({required String name, Sender? sender, Payload? payload})
      : _name = name,
        _sender = sender,
        _payload = payload;

  // Equality & hash
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is Notification &&
          name == other.name &&
          sender == other.sender &&
          payload == other.payload;
    }
  }

  @override
  int get hashCode {
    return name.hashCode ^ sender.hashCode ^ payload.hashCode;
  }

  // Other
  @override
  String toString() {
    return '[$runtimeType: $_name - $sender - $payload]';
  }
}
