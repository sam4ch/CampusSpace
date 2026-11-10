import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/room_model.dart';
import '../widgets/data_view.dart';
import '../widgets/room_card.dart';

class RoomCatalogScreen extends StatefulWidget {
  const RoomCatalogScreen({super.key});
  @override
  State<RoomCatalogScreen> createState() => _RoomCatalogScreenState();
}

class _RoomCatalogScreenState extends State<RoomCatalogScreen> {
  String _query = '';
  bool _lab = false, _small = false, _projector = false;
  @override
  Widget build(BuildContext context) {
    final model = context.watch<RoomModel>();
    final rooms = model.rooms
        .where(
          (room) =>
              room.name.toLowerCase().contains(_query.toLowerCase()) &&
              (!_lab || room.type == 'Лаборатория') &&
              (!_small || room.capacity <= 20) &&
              (!_projector || room.equipment.contains('Проектор')),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог помещений'),
        actions: [
          IconButton(
            tooltip: 'Обновить каталог',
            onPressed: model.isLoading || model.isSaving
                ? null
                : () => context.read<RoomModel>().load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: DataView(
          models: [model],
          onRetry: () => context.read<RoomModel>().load(),
          builder: (context) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        labelText: 'Поиск по названию',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Лаборатория'),
                          selected: _lab,
                          onSelected: (value) => setState(() => _lab = value),
                        ),
                        FilterChip(
                          label: const Text('До 20 мест'),
                          selected: _small,
                          onSelected: (value) => setState(() => _small = value),
                        ),
                        FilterChip(
                          label: const Text('Проектор'),
                          selected: _projector,
                          onSelected: (value) =>
                              setState(() => _projector = value),
                        ),
                      ],
                    ),
                    Text(
                      '${rooms.length} помещений · избранных ${model.favoriteCount}',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rooms.isEmpty
                    ? const Center(child: Text('Помещения не найдены'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: rooms.length,
                        itemBuilder: (_, index) => RoomCard(
                          key: ValueKey(rooms[index].id),
                          room: rooms[index],
                          onTap: () =>
                              context.push('/rooms/${rooms[index].id}'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
