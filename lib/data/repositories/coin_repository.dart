import 'package:firebase_database/firebase_database.dart';

/// Coin balance, rewarded-ad daily limit, and IAP-purchase-dedupe data access.
///
/// Every balance change goes through a transaction so concurrent writes (a
/// settling match, an ad reward, another debit) can never clobber each other.
class CoinRepository {
  CoinRepository(this._database);

  final FirebaseDatabase _database;

  DatabaseReference _coinRef(String uid) =>
      _database.ref().child('users').child(uid).child('coin');

  /// Atomically removes [amount] from [uid]'s balance. Returns `false` and
  /// changes nothing when the balance is too low to cover it.
  Future<bool> debitCoins(String uid, int amount) async {
    final result = await _coinRef(uid).runTransaction((current) {
      final int balance = (current as int?) ?? 0;
      if (balance < amount) return Transaction.abort();
      return Transaction.success(balance - amount);
    });
    return result.committed;
  }

  /// Atomically adds [amount] to [uid]'s balance.
  Future<void> creditCoins(String uid, int amount) async {
    if (amount <= 0) return;
    await _coinRef(uid).runTransaction((current) {
      final int balance = (current as int?) ?? 0;
      return Transaction.success(balance + amount);
    });
  }

  // ── Rewarded ad limit ────────────────────────────────────────────────────
  // Watch count is keyed by calendar date so the daily limit resets itself
  // at midnight without a separate cleanup job.

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  DatabaseReference _adWatchRef(String uid) => _database
      .ref()
      .child('users')
      .child(uid)
      .child('adWatch')
      .child(_todayKey());

  Future<bool> canWatchRewardedAdToday(String uid, int limit) async {
    final snapshot = await _adWatchRef(uid).get();
    final int count = (snapshot.value as int?) ?? 0;
    return count < limit;
  }

  Future<void> recordRewardedAdWatch(String uid) async {
    await _adWatchRef(uid).runTransaction((current) {
      final int count = (current as int?) ?? 0;
      return Transaction.success(count + 1);
    });
  }

  // ── IAP purchase dedupe ──────────────────────────────────────────────────
  // The store can redeliver an unfinished purchase on the next app launch
  // (e.g. the app died between crediting coins and acknowledging the
  // transaction), so crediting must be idempotent per purchase id.

  // Store order/transaction ids (e.g. Android's "GPA.xxxx-xxxx-xxxx-xxxxx")
  // can contain characters Firebase keys reject ('.', '#', '$', '[', ']', '/').
  String _sanitizeKey(String key) => key.replaceAll(RegExp(r'[.#$\[\]/]'), '_');

  DatabaseReference _claimedPurchaseRef(String uid, String purchaseId) =>
      _database
          .ref()
          .child('users')
          .child(uid)
          .child('claimedPurchases')
          .child(_sanitizeKey(purchaseId));

  /// Atomically claims [purchaseId] for [uid]. Returns `true` only the first
  /// time a given purchase id is claimed, so a redelivered/replayed purchase
  /// is never credited twice.
  Future<bool> claimPurchase(String uid, String purchaseId) async {
    final result =
        await _claimedPurchaseRef(uid, purchaseId).runTransaction((current) {
      if (current != null) return Transaction.abort();
      return Transaction.success(true);
    });
    return result.committed;
  }
}
