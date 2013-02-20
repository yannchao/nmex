#include <hx/Macros.h>
#include <hx/CFFI.h>

#include "AD.h"
#include "Device.h"
#include "UI.h"
#include "GA.h"
#include "Events.h"
#include <hxcpp.h>
#include "GameCenter.h"
#include "InAppPurchase.h"
#include "Notifications.h"
#include "Audio.h"

using namespace nmeExtensions;

#ifdef HX_WINDOWS
typedef wchar_t OSChar;
#define val_os_string val_wstring
#else
typedef char OSChar;
#define val_os_string val_string

#endif

AutoGCRoot *nmexEventHandle=0;

extern "C"{
	void nme_extensions_main(){
		//printf("nme_extensions_main()\n");
	}
	DEFINE_ENTRY_POINT(nme_extensions_main);
	
	int nmex_register_prims(){
		//printf("nmex: register_prims()\n");
		nme_extensions_main();
    hxInitAudio();
		return 0;
	}
	
	void nme_extensions_send_event(Event &inEvent){
		//printf("Send Event: %i\n",inEvent.type);
		
		value o = alloc_empty_object();
		alloc_field(o,val_id("type"),alloc_int(inEvent.type));
		alloc_field(o,val_id("code"),alloc_int(inEvent.code));
		alloc_field(o,val_id("value"),alloc_int(inEvent.value));
		alloc_field(o,val_id("data"),alloc_string(inEvent.data));
		  
		val_call1(nmexEventHandle->get(),o);
	}
}

/* init Event handle
*************************************************/
static value nmex_set_event_handle(value onEvent)
{
	nmexEventHandle = new AutoGCRoot(onEvent);
	return alloc_bool(true);
}
DEFINE_PRIM(nmex_set_event_handle,1);

#ifdef GOOGLE_LIBS

/* AD 
*************************************************/
value nmex_ad_init(value id,value x, value y, value sizeType){
	initAd(val_string(id),val_int(x),val_int(y),val_int(sizeType) );
	return alloc_null();
}
DEFINE_PRIM(nmex_ad_init,4);

value nmex_ad_show(){
	showAd();
	return alloc_null();
}
DEFINE_PRIM(nmex_ad_show,0);

value nmex_ad_hide(){
	hideAd();
	return alloc_null();
}
DEFINE_PRIM(nmex_ad_hide,0);

value nmex_ad_refresh(){
	refreshAd();
	return alloc_null();
}
DEFINE_PRIM(nmex_ad_refresh,0);

#endif

/* Device
**************************************************/
value nmex_device_unique_id(){
	return alloc_string(uniqueId());
}
DEFINE_PRIM(nmex_device_unique_id,0);

value nmex_device_os(){
	return alloc_string(os());
}
DEFINE_PRIM(nmex_device_os,0);

value nmex_device_vervion(){
	return alloc_string(vervion());
}
DEFINE_PRIM(nmex_device_vervion,0);

value nmex_device_name()
{
	return alloc_string(deviceName());
}
DEFINE_PRIM(nmex_device_name,0);

value nmex_device_model()
{
	return alloc_string(model());
}
DEFINE_PRIM(nmex_device_model,0);

value nmex_device_is_retina()
{
	return alloc_bool(isRetina());
}
DEFINE_PRIM(nmex_device_is_retina,0);

value nmex_device_network_available()
{
	return alloc_bool(networkAvailable());
}
DEFINE_PRIM(nmex_device_network_available,0);

value nmex_device_vibrate(value time){
	Vibrate(val_float(time));
	return alloc_null();
}
DEFINE_PRIM(nmex_device_vibrate,1);

/* Game Center
***********************************************************/
#ifdef IPHONE
static value init_game_kit(){
	return alloc_bool(hxInitGameKit());
}
DEFINE_PRIM(init_game_kit,0);

static value authenticate_local_user(){
	hxAuthenticateLocalUser();
	return alloc_null();
}
DEFINE_PRIM(authenticate_local_user,0);

static value is_game_center_available(){
	return alloc_bool(hxIsGameCenterAvailable());
}
DEFINE_PRIM(is_game_center_available,0);

static value is_user_authenticated(){
	return alloc_bool(hxIsUserAuthenticated());
}
DEFINE_PRIM(is_user_authenticated,0);

static value show_achievements(){
	hxShowAchievements();
	return alloc_null();
}
DEFINE_PRIM(show_achievements,0);

static value show_leaderboard_for_category(value category){
	hxShowLeaderBoardForCategory(val_string(category));
	return alloc_null();
}
DEFINE_PRIM(show_leaderboard_for_category,1);

static value report_score_for_category(value score, value category){
	hxReportScoreForCategory(val_int(score),val_string(category));
	return alloc_null();
}
DEFINE_PRIM(report_score_for_category,2);

static value report_achievement(value achievementId, value percent){
	hxReportAchievement(val_string(achievementId),val_float(percent));
	return alloc_null();
}
DEFINE_PRIM(report_achievement,2);

static value reset_achievements(){
	hxResetAchievements();
	return alloc_null();
}
DEFINE_PRIM(reset_achievements,0);

static value show_matchmaking_ui(){
  hxShowMatchmakingUI();
  return alloc_null();
}
DEFINE_PRIM(show_matchmaking_ui,0);

static value broadcast_match_data(value data){
  hxBroadcastMatchData(val_string(data));
  return alloc_null();
}
DEFINE_PRIM(broadcast_match_data,1);

static value is_match_started() {
  return alloc_bool(hxIsMatchStarted());
}
DEFINE_PRIM(is_match_started,0);

static value in_match() {
  return alloc_bool(hxInMatch());
}
DEFINE_PRIM(in_match,0);

static value disconnect_match() {
  hxDisconnectMatch();
  return alloc_null();
}
DEFINE_PRIM(disconnect_match, 0);

static value get_player_id() {
  char playerID[256];
  hxGetPlayerID(playerID, 256);
  return alloc_string(playerID);
}
DEFINE_PRIM(get_player_id, 0);

static value get_match_num_players() {
  return alloc_int(hxGetNumMatchPlayers());
}
DEFINE_PRIM(get_match_num_players, 0);

static value get_match_player_id(value index) {
  char playerID[256];
  if ( hxGetMatchPlayerID(val_int(index), playerID, 256) ) {
    return alloc_string(playerID);
  }
  return alloc_null();
}
DEFINE_PRIM(get_match_player_id, 1);

#endif

#ifdef IPHONE
//inAppPurchase start
value nmex_system_in_app_purchase_init(){
	initInAppPurchase();
	return alloc_null();
}
DEFINE_PRIM(nmex_system_in_app_purchase_init,0);

value nmex_system_in_app_purchase_can_purchase(){

	return alloc_bool(canPurchase());
}
DEFINE_PRIM(nmex_system_in_app_purchase_can_purchase,0);

value nmex_system_in_app_purchase_purchase(value productID){
	purchaseProduct(val_os_string(productID));
	return alloc_null();
}
DEFINE_PRIM(nmex_system_in_app_purchase_purchase,1);

value nmex_system_in_app_purchase_release(value productID){
	releaseInAppPurchase();
	return alloc_null();
}
DEFINE_PRIM(nmex_system_in_app_purchase_release,0);

value nmex_system_in_app_purchase_request_product_data(value productIDs) {
  requestProductData(val_os_string(productIDs));
  return alloc_null();
}
DEFINE_PRIM(nmex_system_in_app_purchase_request_product_data,1);

value nmex_system_in_app_purchase_restore_purchases() {
  restorePurchases();
  return alloc_null();
}
DEFINE_PRIM(nmex_system_in_app_purchase_restore_purchases,0);

//inAppPurchase end
#endif

/* Native UI 
***********************************************************/
#ifdef IPHONE
value nmex_system_ui_show_alert(value title,value message){
	
	ShowSystemAlert(val_string(title),val_string(message));
	return alloc_null();
}
DEFINE_PRIM(nmex_system_ui_show_alert,2);

value nmex_system_ui_show_system_loading_view(){

	ShowSystemLoadingView();
	return alloc_null();
}
DEFINE_PRIM(nmex_system_ui_show_system_loading_view,0);

value nmex_system_ui_hide_system_loading_view()
{
	HideSystemLoadingView();
	return alloc_null();
}
DEFINE_PRIM(nmex_system_ui_hide_system_loading_view,0);

value nmex_system_ui_rate(value id)
{
	rate(val_int(id));
	return alloc_null();
}
DEFINE_PRIM(nmex_system_ui_rate,1);
#endif

/* Notifications
***********************************************************/
#ifdef IPHONE
value nmex_notifications_schedule_local(value secondsToFire, value bodyText, value actionText, value badgeNumber,
    value userInfo)
{
  scheduleLocalNotification(val_int(secondsToFire), val_string(bodyText), val_string(actionText), val_int(badgeNumber),
      val_string(userInfo));
	return alloc_null();
}
DEFINE_PRIM(nmex_notifications_schedule_local,5);

value nmex_notifications_cancel()
{
  cancelLocalNotifications();
	return alloc_null();
}
DEFINE_PRIM(nmex_notifications_cancel,0);

value nmex_notifications_set_app_badge(value num)
{
  setAppIconBadge(val_int(num));
	return alloc_null();
}
DEFINE_PRIM(nmex_notifications_set_app_badge,1);
#endif


/* AudioSession
********************************************************************************/
#ifdef IPHONE
value nmex_get_music_player_state() {
  return alloc_int(hxAudioGetMusicPlayerState());
}
DEFINE_PRIM(nmex_get_music_player_state,0);


value nmex_set_audio_session_category(value sessionType) {
  int type = val_int(sessionType);
  hxAudioSetAudioSessionCategory(type);
  return alloc_null();
}
DEFINE_PRIM(nmex_set_audio_session_category,1);

#endif

#ifdef GOOGLE_LIBS

/* GA 
********************************************************************************/
value nmex_tracker_start_tracker(value acountID,int disPatchPeriod)
{
	#ifdef IPHONE
	startTracker(val_string(acountID),disPatchPeriod);
	return alloc_null();
	#endif
}
DEFINE_PRIM(nmex_tracker_start_tracker,2);

value nmex_tracker_track_event(value category,value action,value label,int value)
{
	#ifdef IPHONE
	trackEvent(val_string(category), val_string(action), val_string(label), value);
	return alloc_null();
	#endif
}
DEFINE_PRIM(nmex_tracker_track_event,4);

value nmex_tracker_track_page(value pageName)
{
	#ifdef IPHONE
	trackPageView(val_string(pageName));
	return alloc_null();
	#endif
}
DEFINE_PRIM(nmex_tracker_track_page,1);

value nmex_tracker_dispatch_tracker()
{
	#ifdef IPHONE
	dispatchTracker();
	return alloc_null();
	#endif
}
DEFINE_PRIM(nmex_tracker_dispatch_tracker,0);

value nmex_tracker_stop_tracker()
{
	#ifdef IPHONE
	stopTracker();
	return alloc_null();
	#endif
}
DEFINE_PRIM(nmex_tracker_stop_tracker,0);


/* Utiles 
*******************************************************************************/
/*
value nmex_utils_merge_alpha(value inSurface1, value inSurface2){
		
	Surface *surf1;
	Surface *surf2;
    if (nme::AbstractToObject(inSurface1,surf1) && nme::AbstractToObject(inSurface2,surf2) ){
      int w = surf1->Width();
      int h = surf1->Height();
      uint32 p = 0x0;
      int j = 0;
      for(int i=0;i<w;i++){
         for(j=0;j<h;j++){
            surf1->setPixel(i,j, (surf1->getPixel(i,j) & 0xffffff) | ( surf2->getPixel(i,j) >> 16 << 24 )  ,true);
         }
      }

   }
   return alloc_null();
}
DEFINE_PRIM(nmex_utils_merge_alpha,2);
*/
value nmex_device_get_doc_path(){
#ifdef IPHONE
	return alloc_string(getDocPath());
#else
	return alloc_null();
#endif
}
DEFINE_PRIM(nmex_device_get_doc_path,0);

value nmex_device_get_rec_path(){
#ifdef IPHONE
	return alloc_string(getRecPath());
#else
	return alloc_null();
#endif
}
DEFINE_PRIM(nmex_device_get_rec_path,0);

#endif

///////////////////////////////////////////////////////////////////
 