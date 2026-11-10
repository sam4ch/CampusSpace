import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/room_model.dart';
import '../widgets/data_view.dart';
import '../widgets/room_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<RoomModel>();
    final rooms = model.favorites;
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное (${model.favoriteCount})'),
        actions: [
          IconButton(
            tooltip: 'Обновить избранное',
            icon: const Icon(Icons.refresh),
            onPressed: model.isLoading || model.isSaving
                ? null
                : () => context.read<RoomModel>().load(),
          ),
        ],
      ),
      body: SafeArea(
        child: DataView(
          models: [model],
          onRetry: () => context.read<RoomModel>().load(),
          builder: (_) => rooms.isEmpty
              ? const Center(child: Text('В избранном пока нет помещений'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Dismissible(
                      key: ValueKey(room.id),
                      direction: model.isSaving
                          ? DismissDirection.none
                          : DismissDirection.endToStart,
                      background: ColoredBox(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Icon(Icons.heart_broken),
                          ),
                        ),
                      ),
                      confirmDismiss: (_) async {
                        final error = await context
                            .read<RoomModel>()
                            .toggleFavorite(room.id);
                        if (context.mounted && error != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error)));
                        }
                        // The model removes the row; no optimistic deletion on failure.
                        return false;
                      },
                      child: RoomCard(
                        room: room,
                        onTap: () => context.push('/favorites/${room.id}'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
