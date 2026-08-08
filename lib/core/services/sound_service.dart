import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:tic_tac_toe/common/local_storage.dart';

abstract class SoundService {
  static final AudioPlayer _musicPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.loop);

  // audioFocus: none / mixWithOthers so sfx never steals audio focus and
  // pauses _musicPlayer.
  static final AudioContext _sfxAudioContext = AudioContext(
    android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
    iOS: AudioContextIOS(options: const {
      AVAudioSessionOptions.mixWithOthers,
    }),
  );

  static bool _enabled = true;
  // Whether the current screen wants background music playing at all, as
  // opposed to [_enabled] which is the user's mute preference. Kept separate
  // so that muting mid-game and un-muting mid-game both work regardless of
  // whether music happened to be enabled when the game screen was entered.
  static bool _wantsMusic = false;
  static bool _musicStarted = false;

  // Identifies which screen currently "owns" background music. On restart,
  // Navigator.pushReplacementNamed builds the new MazeScreen (which calls
  // playBackgroundMusic) before the old one's dispose (stopBackgroundMusic)
  // runs, since removal happens after the route transition. Without this
  // guard the old screen's stale stopBackgroundMusic call would kill the
  // music the new screen just started.
  static Object? _activeSession;

  static bool get isEnabled => _enabled;

  static void init() {
    _enabled = LocalStorage.isSoundEnabled();
  }

  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await LocalStorage.setSoundEnabled(enabled);
    if (!_wantsMusic) return;
    try {
      if (!enabled) {
        await _musicPlayer.pause();
      } else if (_musicStarted) {
        await _musicPlayer.resume();
      } else {
        await _musicPlayer.play(AssetSource('music/music.mp3'));
        _musicStarted = true;
      }
    } catch (_) {}
  }

  static Future<void> playClick() async {
    if (!_enabled) return;
    await _playOneShot('music/click.mp3');
  }

  static Future<void> playWin() async {
    if (!_enabled) return;
    final bool resumeMusicAfter = _musicStarted;
    if (resumeMusicAfter) {
      try {
        await _musicPlayer.pause();
      } catch (_) {}
    }
    await _playOneShot('music/wingame.mp3', onComplete: () async {
      if (resumeMusicAfter && _wantsMusic && _enabled) {
        try {
          await _musicPlayer.resume();
        } catch (_) {}
      }
    });
  }

  /// Plays a short sfx on a fresh, disposable [AudioPlayer]. A shared player
  /// reused across repeated plays only reliably fires once on some Android
  /// SoundPool setups (the click after the first goes silent), so instead
  /// each call gets its own player that's discarded once the clip completes.
  static Future<void> _playOneShot(
    String assetPath, {
    Future<void> Function()? onComplete,
  }) async {
    final AudioPlayer player = AudioPlayer();
    late final StreamSubscription<void> completeSub;
    Future<void> cleanUp() async {
      await completeSub.cancel();
      await player.dispose();
    }

    completeSub = player.onPlayerComplete.listen((_) async {
      await cleanUp();
      await onComplete?.call();
    });

    try {
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setAudioContext(_sfxAudioContext);
      await player.play(AssetSource(assetPath));
    } catch (_) {
      await cleanUp();
    }
  }

  static Future<void> playBackgroundMusic(Object session) async {
    _activeSession = session;
    _wantsMusic = true;
    if (!_enabled) return;
    try {
      await _musicPlayer.play(AssetSource('music/music.mp3'));
      _musicStarted = true;
    } catch (_) {}
  }

  static Future<void> stopBackgroundMusic(Object session) async {
    // A newer screen has already taken over background music; this call is
    // from a screen that's only now getting around to disposing.
    if (_activeSession != session) return;
    _activeSession = null;
    _wantsMusic = false;
    _musicStarted = false;
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }
}
