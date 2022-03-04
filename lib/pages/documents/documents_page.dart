import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kapte_cms/models/restaurant_media/restaurant_media.dart';
import 'package:kapte_cms/models/utilisateur/utilisateur.dart';
import 'package:kapte_cms/pages/documents/drawer_info.dart';
import 'package:kapte_cms/services/data.dart';

final mediaProvider = ChangeNotifierProvider.autoDispose<MediaState>((ref) {
  return MediaState();
});

class MediaState with ChangeNotifier {
  MediaState() {
    initRestaurantMediaPath();
  }

  String path = '';
  Utilisateur? utilisateur;
  List folderList = <RestaurantMedia>[];
  RestaurantMedia? media;
  List<bool> listCheckboxSelectedValue = [];
  bool checkboxSelected = false;
  List listSelectedMedia = <RestaurantMedia>[];

  initRestaurantMediaPath() async {
    utilisateur = await Data().getUtilisateur();
    if (utilisateur!.idRestaurant != null) {
      path = 'restaurants/${utilisateur!.idRestaurant!}/';
    }
    notifyListeners();
  }

  Future<void> createFolder(String name) async {
    await FirebaseStorage.instance.ref(path).child('$name/.init').putString('');
    notifyListeners();
  }

  Future pickImages() async {
    ImagePicker picker = ImagePicker();
    await picker.pickMultiImage().then((List<XFile>? file) async {
      if (file != null) await uploadImages(file);
    });
    notifyListeners();
  }

  Future uploadImages(List<XFile> file) async {
    await Future.forEach(file, (XFile xFile) async {
      Uint8List bytes = await xFile.readAsBytes();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref(path)
          .child(xFile.name)
          .putData(bytes, SettableMetadata(contentType: xFile.mimeType));
      await uploadTask.timeout(
        const Duration(seconds: 15),
        onTimeout: () async {
          await uploadTask.cancel();
          throw TimeoutException('Délai depassé');
        },
      );
    });
  }

  addSelcetedReference(RestaurantMedia value) {
    listSelectedMedia.add(value);
  }

  removeSelectedReference(int index) {
    listSelectedMedia.removeWhere((element) => element.index == index);
  }

  deleteFile() {
    for (int i = 0; i < listSelectedMedia.length; i++) {
      if (listSelectedMedia[i].type == 'file') {
        FirebaseStorage.instance
            .ref(listSelectedMedia[i].reference.fullPath)
            .delete()
            .then((value) => clearSelecteted());
      } else {
        navigateToFolderForDelete(listSelectedMedia[i].reference);
      }
    }
  }

  navigateToFolderForDelete(Reference value) {
    FirebaseStorage.instance.ref(value.fullPath).listAll().then(
      (media) {
        for (int i = 0; i < media.prefixes.length; i++) {
          navigateToFolderForDelete(media.prefixes[i]);
        }
        for (int i = 0; i < media.items.length; i++) {
          FirebaseStorage.instance
              .ref(media.items[i].fullPath)
              .delete()
              .then((value) => clearSelecteted());
        }
      },
    );
  }

  clearSelecteted() {
    checkboxSelected = false;
    listCheckboxSelectedValue.clear();
    listSelectedMedia.clear();
    notifyListeners();
  }

  selectedFile(RestaurantMedia? media) {
    this.media = media;
    notifyListeners();
  }

  selectedFolder(RestaurantMedia? media) {
    if (media != null) {
      path = media.reference.fullPath;
      folderList.add(media);
      listCheckboxSelectedValue.clear();
    } else {
      path = 'restaurants/${utilisateur!.idRestaurant!}/';
      listCheckboxSelectedValue.clear();
      folderList.clear();
    }
    notifyListeners();
  }

  updateFolderListe(int index) {
    folderList.removeRange(index, folderList.length);
    notifyListeners();
  }

  addSelectedValue(int index) {
    if (listCheckboxSelectedValue.asMap().containsKey(index)) {
    } else {
      listCheckboxSelectedValue.add(false);
    }
  }

  setSelectedValue(int index) {
    listCheckboxSelectedValue[index] = !listCheckboxSelectedValue[index];
    if (listCheckboxSelectedValue.contains(true)) {
      checkboxSelected = true;
    } else {
      checkboxSelected = false;
    }
    notifyListeners();
  }
}

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key, this.onNavigate = false}) : super(key: key);
  final bool? onNavigate;

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final mediaState = ref.watch(mediaProvider);
      return mediaState.utilisateur != null
          ? mediaState.utilisateur!.idRestaurant != null
              ? Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    centerTitle: false,
                    title: Text(
                      'Documents',
                      style: Theme.of(context).textTheme.headline2!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    actions: [
                      Visibility(
                        visible: widget.onNavigate!,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          splashRadius: 20.0,
                        ),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DocumentsPageBody(
                      onNavigate: widget.onNavigate,
                    ),
                  ),
                )
              : const SizedBox.shrink()
          : const SizedBox.shrink();
    });
  }
}

class DocumentsPageBody extends ConsumerStatefulWidget {
  const DocumentsPageBody({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  final bool? onNavigate;

  @override
  _DocumentsPageBodyState createState() => _DocumentsPageBodyState();
}

class _DocumentsPageBodyState extends ConsumerState<DocumentsPageBody> {
  bool createFolderValue = false;
  TextEditingController newFolderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaState = ref.watch(mediaProvider);

    return Card(
      child: Scaffold(
        appBar: !mediaState.checkboxSelected
            ? AppBar(
                automaticallyImplyLeading: false,
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.read(mediaProvider).selectedFolder(null);
                        },
                        child: const Text(
                          'Mes documents',
                        ),
                      ),
                      Row(
                        children: mediaState.folderList.map((media) {
                          var index = mediaState.folderList.indexOf(media);
                          return Row(
                            children: [
                              Text(
                                ' > ',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              mediaState.folderList[
                                          mediaState.folderList.length - 1] !=
                                      media
                                  ? TextButton(
                                      child: Text(media.reference.name),
                                      onPressed: () {
                                        ref
                                            .read(mediaProvider)
                                            .updateFolderListe(index);
                                        ref
                                            .read(mediaProvider)
                                            .selectedFolder(media);
                                      },
                                    )
                                  : Text(
                                      media.reference.name,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(mediaProvider).pickImages();
                      },
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Importer un fichier'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          createFolderValue = true;
                        });
                      },
                      icon: const Icon(Icons.create_new_folder),
                      splashRadius: 20,
                    ),
                  )
                ],
              )
            : AppBar(
                centerTitle: false,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: IconButton(
                        onPressed: () {
                          ref.read(mediaProvider).clearSelecteted();
                        },
                        icon: const Icon(Icons.close),
                        splashRadius: 20.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${mediaState.listSelectedMedia.length} sélectionné(s)',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Ouvrir',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(mediaProvider).deleteFile();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('Supprimer'),
                        ),
                        style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                          width: 1.0,
                          color: Colors.white,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ListView(
                children: [
                  FutureBuilder<ListResult>(
                    future:
                        FirebaseStorage.instance.ref(mediaState.path).listAll(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Visibility(
                              visible: createFolderValue,
                              child: SizedBox(
                                width: double.infinity,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: newFolderNameController,
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      createFolderValue = false;
                                                    });
                                                  },
                                                  child: const Text('Annuler')),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: TextButton(
                                                onPressed: () {
                                                  ref
                                                      .read(mediaProvider)
                                                      .createFolder(
                                                          newFolderNameController
                                                              .value.text)
                                                      .then((value) {
                                                    setState(() {
                                                      createFolderValue = false;
                                                    });
                                                    newFolderNameController
                                                        .clear();
                                                  });
                                                },
                                                child: const Text(
                                                    'Ajouter un dossier'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Text('Nom'),
                                ),
                              ],
                              rows: [
                                ...snapshot.data!.prefixes.map((folder) {
                                  int index =
                                      snapshot.data!.prefixes.indexOf(folder);
                                  RestaurantMedia media =
                                      RestaurantMedia(index, 'folder', folder);

                                  ref
                                      .read(mediaProvider)
                                      .addSelectedValue(index);

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:
                                                  Icon(Icons.folder_outlined),
                                            ),
                                            Text(folder.name),
                                          ],
                                        ),
                                        onTap: () {
                                          ref
                                              .read(openInfoProvider.notifier)
                                              .setValue(false);
                                          ref
                                              .read(mediaProvider)
                                              .selectedFolder(media);
                                        },
                                      ),
                                    ],
                                    selected: mediaState
                                        .listCheckboxSelectedValue[index],
                                    onSelectChanged: (value) {
                                      ref
                                          .read(mediaProvider)
                                          .setSelectedValue(index);
                                      if (value!) {
                                        ref
                                            .read(mediaProvider)
                                            .addSelcetedReference(media);
                                      } else {
                                        ref
                                            .read(mediaProvider)
                                            .removeSelectedReference(index);
                                      }
                                    },
                                  );
                                }).toList(),
                                ...snapshot.data!.items.map((file) {
                                  int index = snapshot.data!.prefixes.length +
                                      snapshot.data!.items.indexOf(file);
                                  RestaurantMedia media =
                                      RestaurantMedia(index, 'file', file);
                                  ref
                                      .read(mediaProvider)
                                      .addSelectedValue(index);
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.description_outlined,
                                                color: mediaState.media != null
                                                    ? mediaState.media!.index ==
                                                            index
                                                        ? Theme.of(context)
                                                            .secondaryHeaderColor
                                                        : null
                                                    : null,
                                              ),
                                            ),
                                            Text(
                                              file.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: mediaState.media != null
                                                    ? mediaState.media!.index ==
                                                            index
                                                        ? Theme.of(context)
                                                            .secondaryHeaderColor
                                                        : null
                                                    : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          ref
                                              .read(mediaProvider)
                                              .selectedFile(media);
                                          ref
                                              .read(openInfoProvider.notifier)
                                              .setValue(true);
                                        },
                                        onDoubleTap: widget.onNavigate!
                                            ? () {
                                                file.getDownloadURL().then(
                                                  (value) {
                                                    Navigator.pop(
                                                        context, value);
                                                  },
                                                );
                                              }
                                            : null,
                                      ),
                                    ],
                                    selected: mediaState
                                        .listCheckboxSelectedValue[index],
                                    onSelectChanged: (value) {
                                      ref
                                          .read(mediaProvider)
                                          .setSelectedValue(index);
                                      if (value!) {
                                        ref
                                            .read(mediaProvider)
                                            .addSelcetedReference(media);
                                      } else {
                                        ref
                                            .read(mediaProvider)
                                            .removeSelectedReference(index);
                                      }
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            Info(
              onNavigate: widget.onNavigate!,
            ),
          ],
        ),
      ),
    );
  }
}
