#ifndef UI
#define UI

//#import <UIKit/UIKit.h>


namespace nmeExtensions{

    void ShowSystemAlert(const char *title,const char *message);
    void ShowSystemLoadingView();
    void HideSystemLoadingView();
	//rate
	void rate(int appID);
}

#endif
