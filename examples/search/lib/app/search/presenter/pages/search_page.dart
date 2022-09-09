// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:search/app/search/domain/entities/result.dart';
import 'package:search/app/search/domain/errors/erros.dart';

import '../stores/search_store.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ModularState<SearchPage, SearchStore> {
  Widget _buildList(List<Result> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, index) {
        final item = list[index];
        return ListTile(
          leading: Hero(
            tag: item.image,
            child: CircleAvatar(
              backgroundImage: NetworkImage(item.image),
            ),
          ),
          title: Text(item.nickname),
          onTap: () {
            Modular.to.pushNamed(
              '/details',
              arguments: item,
            );
          },
        );
      },
    );
  }

  Widget _buildError(Failure error) {
    if (error is EmptyList) {
      return const Center(
        child: Text(
          'Nada encontrado',
        ),
      );
    } else if (error is ErrorSearch) {
      return const Center(
        child: Text(
          'Erro no github',
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Erro interno',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('setState');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Github Search',
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
            child: TextField(
              onChanged: store.setSearchText,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pesquise...',
              ),
            ),
          ),
          Expanded(
            child: ScopedBuilder<SearchStore, Failure, List<Result>>(
              store: store,
              onLoading: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              onError: (_, error) {
                return _buildError(error!);
              },
              onState: (_, state) {
                if (state.isEmpty) {
                  return const Center(
                    child: Text(
                      'Digita alguma coisa...',
                    ),
                  );
                } else {
                  return _buildList(state);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
