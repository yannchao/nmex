#ifndef GA
#define GA

namespace nmeExtensions{
	#ifdef IPHONE
	void startTracker(const char *acountID,int dispatchPeriod);
	void trackPageView(const char *pageName);
	void trackEvent(const char *category,const char *action,const char *label,int value);
	void dispatchTracker();
	void stopTracker();
	#endif
}

#endif
