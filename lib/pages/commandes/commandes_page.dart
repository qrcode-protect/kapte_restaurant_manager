import 'package:flutter/material.dart';
import 'package:kapte_cms/pages/commandes/commande_terminer.dart';
import 'package:kapte_cms/pages/commandes/commandes_encours.dart';

class CommandesPage extends StatefulWidget {
  const CommandesPage({Key? key}) : super(key: key);

  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Commandes',
            style: Theme.of(context).textTheme.headline2!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 700.0,
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: [
                      Tab(
                        child: Text(
                          'En cours',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Terminé',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ],
                    onTap: (index) {
                      setState(() {
                        pageIndex = index;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: pageIndex,
          children: [
            CommandeEnCours(),
            CommandeTerminer(),
          ],
        ),
      ),
    );
  }
}
