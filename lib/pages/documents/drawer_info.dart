import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/pages/documents/documents_page.dart';

final openInfoProvider = StateNotifierProvider<OpenInfoState, bool>((ref) {
  return OpenInfoState();
});

class OpenInfoState extends StateNotifier<bool> {
  OpenInfoState() : super(false);
  void setValue(bool value) {
    state = value;
  }
}

class Info extends StatelessWidget {
  const Info({
    Key? key,
    this.onNavigate = false,
  }) : super(key: key);

  final bool onNavigate;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final mediaState = ref.watch(mediaProvider);
      final openInfoState = ref.watch(openInfoProvider);
      return mediaState.media != null && openInfoState
          ? Expanded(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    leading: Icon(
                      Icons.description,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      mediaState.media!.reference.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          ref.read(openInfoProvider.notifier).setValue(false);
                          ref.read(mediaProvider).selectedFile(null);
                        },
                        icon: const Icon(Icons.close),
                        color: Theme.of(context).primaryColor,
                        splashRadius: 15,
                      )
                    ],
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: FutureBuilder(
                        future: mediaState.media!.reference.getDownloadURL(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    snapshot.data.toString(),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container();
                        }),
                  ),
                  if (onNavigate)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            mediaState.media!.reference.getDownloadURL().then(
                              (value) {
                                Navigator.pop(context, value);
                              },
                            );
                          },
                          child: const Text('Sélectionner'),
                        ),
                      ),
                    ),
                ],
              ),
            )
          : const SizedBox.shrink();
    });
  }
}
