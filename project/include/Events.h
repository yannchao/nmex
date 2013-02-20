#ifndef Events_H_
#define Events_H_

enum EventType{
   etUnknown,                   // 0
   etIN_APP_PURCHASE_SUCCESS,   // 1
   etIN_APP_PURCHASE_FAIL,      // 2
   etIN_APP_PURCHASE_CANNEL,    // 3
   etIN_APP_PURCHASE_DATA,      // 4
   etIN_APP_PURCHASE_DATA_FAIL, // 5

	AUTH_SUCCEEDED,				//6
	AUTH_FAILED,				//7
	LEADERBOARD_VIEW_OPENED,	//8
	LEADERBOARD_VIEW_CLOSED,	//9
	ACHIEVEMENTS_VIEW_OPENED,	//10
	ACHIEVEMENTS_VIEW_CLOSED,	//11
	SCORE_REPORT_SUCCEEDED,		//12
	SCORE_REPORT_FAILED,		//13
	ACHIEVEMENT_REPORT_SUCCEEDED,//14
	ACHIEVEMENT_REPORT_FAILED,	//15
	ACHIEVEMENT_RESET_SUCCEEDED,//16
	ACHIEVEMENT_RESET_FAILED,	//17
  MATCHMAKING_VIEW_CLOSED, // 18
  MATCH_STARTED, // 19
  MATCH_DATA_RECEIVED, // 20
  MATCH_PLAYER_DISCONNECTED, // 21

  etIN_APP_PURCHASE_RESTORE, //22
  AUDIO_PLAYBACK_STATE_CHANGED, // 23
};

struct Event{
	
   Event(EventType inType=etUnknown,int inCode=0,int inValue=0,const char *inData = "")
   :type(inType), code(inCode), value(inValue), data(inData){}

   EventType type;
   int       code;
   int       value;
   const char *data;
};

#endif