package nmex;

class AudioSession extends NXObject
{
  private static var instance:AudioSession;

  public var musicPlayerState(get_musicPlayerState, never) : MusicPlayerState;
  public var audioSessionCategory(get_audioSessionCategory, set_audioSessionCategory) : AudioSessionCategory;

  private function new(){
    super();
    this.audioSessionCategory = AudioSessionCategory.SoloAmbient;
  }

  public static function getInstance():AudioSession {
    if(instance == null){
      instance = new AudioSession();
    }
    
    return instance;
  }

  public function get_musicPlayerState() : MusicPlayerState {
    var state = cast(nmex_get_music_player_state(), Int);
    return switch(state) {
    case 1: MusicPlayerState.Playing;
    case 2: MusicPlayerState.Paused;
    case 3: MusicPlayerState.Interrupted;
    case 4: MusicPlayerState.SeekingForward;
    case 5: MusicPlayerState.SeekingBackward;
    default: Stopped;
    }
  }

  public function get_audioSessionCategory() : AudioSessionCategory {
    return audioSessionCategory;
  }

  public function set_audioSessionCategory(cat:AudioSessionCategory) : AudioSessionCategory {
    audioSessionCategory = cat;
    untyped nmex_set_audio_session_category(Type.enumIndex(cat));
    return cat;
  }
    
  private static var nmex_get_music_player_state  = nme.Loader.load("nmex_get_music_player_state",0);
  private static var nmex_set_audio_session_category = nme.Loader.load("nmex_set_audio_session_category",1);
}
