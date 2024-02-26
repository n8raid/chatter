// ignore_for_file: avoid_print

import 'package:dumble/dumble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:chatter/providers/theme_provider.dart';
// import 'package:opus_dart/opus_dart.dart';

void main() {
  runApp(const ProviderScope(child: Chatter()));
}

class Chatter extends ConsumerStatefulWidget {
  const Chatter({super.key});

  @override
  ConsumerState<Chatter> createState() => _ChatterState();
}

class _ChatterState extends ConsumerState<Chatter> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ref.watch(themeNotifierProvider),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController mumbleHostController;
  late final TextEditingController mumblePortController;
  MumbleClient? client;

  void connect(String serverUrl, int portNum) {
    MumbleClient.connect(
        options: ConnectionOptions(
          host: serverUrl,
          port: portNum,
          name: 'chatter-test',
        ),
        onBadCertificate: (cert) {
          return true;
        }).then((mumClient) {
      client = mumClient;
      final callback = MumbleExampleCallback(client!);
      client!.add(callback);
      print('Client synced with server!');
      print('Listing channels...');
      print(client!.getChannels());
      print('Listing users...');
      print(client!.getUsers());
      // Watch all users that are already on the server
      // New users will reported to the callback (because of line 14) and we will
      // watch these new users in onUserAdded below
      client!.getUsers().values.forEach((User element) => element.add(callback));
      // Also, watch self
      client!.self.add(callback);
      // Set a comment for us
      client!.self.setComment(comment: 'I\'m a bot!');
      // Create a channel. If the channel is succesfully created, our callback is invoked.
      client!.createChannel(name: 'Dumble Test Channel');

      // const int inputSampleRate = 8000;
      // const int frameTimeMs = 40; // use frames of 40ms
      // const FrameTime frameTime = FrameTime.ms40;
      // const int outputSampleRate = 48000;
      // const int channels = 1;

      // StreamOpusEncoder<int> encoder = StreamOpusEncoder.bytes(
      //     frameTime: frameTime,
      //     floatInput: false,
      //     sampleRate: inputSampleRate,
      //     channels: channels,
      //     application: Application.voip);
      // final audioOut = client!.audio.sendAudio(
      //   codec: AudioCodec.opus,
      // );
    });
  }

  @override
  void initState() {
    super.initState();

    mumbleHostController = TextEditingController();
    mumblePortController = TextEditingController(text: '64738');
  }

  @override
  Widget build(BuildContext context) {
    // This Localizations.override widget is just for ease of testing localizations,
    // Provide a different value in the `Locale()` object to switch the app over
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: Builder(builder: (context) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: SizedBox(
                      width: 400,
                    child: Text(
                      AppLocalizations.of(context).connectionScreenTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).hostTextTitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(
                          width: 250,
                          child: TextField(controller: mumbleHostController),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).portTextTitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(
                          width: 60,
                          child: TextField(controller: mumblePortController),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    child: const Text('Connect'),
                    onPressed: () {
                      connect(mumbleHostController.text, int.parse(mumblePortController.text));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class MumbleExampleCallback with MumbleClientListener, UserListener {
  final MumbleClient client;

  const MumbleExampleCallback(this.client);

  @override
  void onBanListReceived(List<BanEntry> bans) {}

  @override
  void onChannelAdded(Channel channel) {
    if (channel.name == 'Dumble Test Channel') {
      // This is our channel
      // join it
      client.self.moveToChannel(channel: channel);
    }
  }

  @override
  void onCryptStateChanged() {}

  @override
  void onDone() {
    print('onDone');
  }

  @override
  void onDropAllChannelPermissions() {}

  @override
  void onError(error, [StackTrace? stackTrace]) {
    print('An error occured!');
    print(error);
    if (stackTrace != null) {
      print(stackTrace);
    }
  }

  @override
  void onQueryUsersResult(Map<int, String> idToName) {}

  @override
  void onTextMessage(IncomingTextMessage message) {
    print('[${DateTime.now()}] ${message.actor?.name}: ${message.message}');
  }

  @override
  void onUserAdded(User user) {
    //Keep an eye on the user
    user.add(this);
  }

  @override
  void onUserListReceived(List<RegisteredUser> users) {}

  @override
  void onUserChanged(User? user, User? actor, UserChanges changes) {
    print('User $user changed $changes');
    // The user changed
    if (changes.channel) {
      // ...his channel
      if (user?.channel == client.self.channel) {
        // ... to our channel
        // So greet him
        client.self.channel.sendMessageToChannel(message: 'Hello ${user?.name}!');
      }
    }
  }

  @override
  void onUserRemoved(User user, User? actor, String? reason, bool? ban) {
    // If the removed user is the actor that is responsible for this, the
    // user simply left the server. Same is ture if the actor is null.
    if (actor == null || user == actor) {
      print('${user.name} left the server');
    } else if (ban ?? false) {
      // The user was baned from the server
      print('${user.name} was banned by ${actor.name}, reason $reason.');
    } else {
      // The user was kicked from the server
      print('${user.name} was kicked by ${actor.name}, reason $reason.');
    }
  }

  @override
  void onUserStats(User user, UserStats stats) {}

  @override
  void onPermissionDenied(PermissionDeniedException e) {
    print('Permission denied!');
    print(
        'This will occur if this example is run a second time, since it will try to create a channel that already exists!');
    print('The concrete exception was: $e');
  }
}
