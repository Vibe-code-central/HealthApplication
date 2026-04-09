import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_requiem/providers/user_provider.dart';

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int goldCost;
  final bool isConsumable;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.goldCost,
    required this.isConsumable,
  });
}

final shopCatalog = <ShopItem>[
  const ShopItem(
    id: 'pass_kevlar',
    name: 'Kevlar Vest',
    description: 'PASSIVE: Reduces Wesker penalty by 10%.',
    goldCost: 100,
    isConsumable: false,
  ),
  const ShopItem(
    id: 'pass_stimpack',
    name: 'Combat Stimpack',
    description: 'PASSIVE: Permanent 15% bonus to all XP earned.',
    goldCost: 300,
    isConsumable: false,
  ),
  const ShopItem(
    id: 'cons_medkit',
    name: 'Field Medkit',
    description: 'CONSUMABLE: Protects your streak if missed.',
    goldCost: 50,
    isConsumable: true,
  ),
];

final shopProvider = Provider<ShopService>((ref) {
  return ShopService(ref);
});

class ShopService {
  final Ref _ref;
  ShopService(this._ref);

  Future<bool> purchase(String itemId) async {
    final item = shopCatalog.firstWhere((i) => i.id == itemId);
    final userNotif = _ref.read(userProvider.notifier);
    final user = _ref.read(userProvider);
    if (user == null) return false;

    if (user.gold < item.goldCost) return false;

    // Check if already owns passive
    if (!item.isConsumable && user.unlockedBuffs.containsKey(item.id)) {
      return false; // Already owned
    }

    // Deduct gold
    await userNotif.addGold(-item.goldCost);

    // Apply buff
    final currentBuffs = Map<String, DateTime?>.from(user.unlockedBuffs);
    if (item.isConsumable) {
      if (item.id == 'cons_medkit') {
        // Special logic for medkit — save the user's streak right now
        // This usually would be implemented on the streak breaker validator,
        // but for now, we just grant an artificial +1 day streak protection
        currentBuffs['streak_protection'] = null; 
      }
    } else {
      currentBuffs[item.id] = null; // null = never expires
    }
    
    await userNotif.updateBuffs(currentBuffs);
    return true;
  }
}
