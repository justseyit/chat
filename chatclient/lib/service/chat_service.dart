import 'package:chatapp/protos/service.pbgrpc.dart';
import 'package:grpc/grpc.dart';


class ChatService {
  late final User user;
  static late BroadcastClient client;

  ChatService(this.user) {
    client = BroadcastClient(
      ClientChannel(
        "10.0.2.2",
        port: 9999,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      ),
    );
  }

  Future<Close> sendMessage(String body) async {
    return client.broadcastMessage(
      Message()
        ..sender = user
        ..id = user.id
        ..content = body
        ..timestamp = DateTime.now().toIso8601String(),
    );
  }

  Stream<Message> recieveMessage() async* {
    Connect connect = Connect()
      ..user = user
      ..active = true;

    await for (var msg in client.createStream(connect)) {
      yield msg;
    }
  }
}
