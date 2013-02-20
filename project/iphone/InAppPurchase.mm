//  InAppPurchase.m
//
//  Created by Yann on 11-2-23.
//  Copyright 2011 mybogame. All rights reserved.
 
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h> 
#include "InAppPurchase.h"
#include "Events.h"

extern "C" void nme_extensions_send_event(Event &inEvent);

@interface InAppPurchase: NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    SKProduct *myProduct;
    SKProductsRequest *productsRequest;
	NSString *productID;
    NSMutableDictionary *products;
}

- (void)initInAppPurchase;
- (BOOL)canMakePurchases;
- (void)purchaseProduct:(NSString *) ProductIdentifiers;
- (void)restorePurchases;

@end

@implementation InAppPurchase

#pragma Public methods 

- (void)initInAppPurchase {
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (BOOL)canMakePurchases{
    return [SKPaymentQueue canMakePayments];
} 

- (void)purchaseProduct:(NSString *) ProductIdentifiers{
  /*// return data to client....
	productID = ProductIdentifiers;
	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productID]];
	productsRequest.delegate = self;
	[productsRequest start];
   */
  productID = ProductIdentifiers;
  SKProduct *product = [products objectForKey: productID];
  if (product) {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
  } else {
    Event evt(etIN_APP_PURCHASE_FAIL);
    evt.data = "IN_APP_PURCHASE_FAIL!";
    nme_extensions_send_event(evt);
  }
}

- (void)requestProducts:(NSSet*) productIds {
  productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
  productsRequest.delegate = self;
  [productsRequest start];
}

- (void)restorePurchases {
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
} 

#pragma mark -
#pragma mark SKProductsRequestDelegate methods 

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    Event evt(etIN_APP_PURCHASE_DATA_FAIL);
    if (error) {
      evt.data = [[error localizedDescription] UTF8String];
    }
    nme_extensions_send_event(evt);
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
   	
  if (!products) {
    products = [[NSMutableDictionary alloc] init];
  }

  NSMutableDictionary *returnData = [[NSMutableDictionary alloc] init];
  for (id product in response.products) {
    [products setObject:product forKey:[product productIdentifier]];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:[product priceLocale]];
		NSString *formattedString = [numberFormatter stringFromNumber:[product price]];
    [numberFormatter release];

    NSMutableDictionary *productReturnData = [[NSDictionary alloc] initWithObjectsAndKeys:[product localizedTitle],
                        @"title", [product localizedDescription], @"description", [product price], @"price",
                        formattedString, @"priceString", nil];
    [returnData setObject:productReturnData forKey:[product productIdentifier]];
  }

  NSError *e = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnData options:0 error:&e];
  NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  if (e) {
    NSLog(@"Could not parse product info : %@",e);
    Event evt(etIN_APP_PURCHASE_DATA_FAIL);
    evt.data = "bad product data";
    nme_extensions_send_event(evt);
  } else {
    // send data to client
    Event evt(etIN_APP_PURCHASE_DATA);
    evt.data = [jsonString UTF8String];
    nme_extensions_send_event(evt);
  }

  [returnData release];
  [jsonString release];

  /*
	int count = [response.products count];
    
	NSLog(@"the count is %i",count);

	if (count > 0) {
		myProduct = [response.products objectAtIndex:0];
		//buy it
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:productID];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	} else {
		Event evt(etIN_APP_PURCHASE_FAIL);
		evt.data = "IN_APP_PURCHASE_FAIL!";
		nme_extensions_send_event(evt);
	}
  */
    
    [productsRequest release];
}
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if (wasSuccessful){
		
		Event evt(etIN_APP_PURCHASE_SUCCESS);
		evt.data = "etIN_APP_PURCHASE_SUCCESS!";
		nme_extensions_send_event(evt);
		
        //finished the transaction
    }else{
        //failed transaction		
		Event evt(etIN_APP_PURCHASE_FAIL);
		evt.data = "IN_APP_PURCHASE_FAIL!";
		nme_extensions_send_event(evt);
    }

}
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    [self finishTransaction:transaction wasSuccessful:YES];
} 
- (void)restoreTransaction:(SKPaymentTransaction *)transaction{
    [self finishTransaction:transaction wasSuccessful:YES];
} 
- (void)failedTransaction:(SKPaymentTransaction *)transaction{
    if (transaction.error.code != SKErrorPaymentCancelled){
        [self finishTransaction:transaction wasSuccessful:NO];
    }else{
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		
		Event evt(etIN_APP_PURCHASE_CANNEL);
		evt.data = "IN_APP_PURCHASE_CANNEL!";
		nme_extensions_send_event(evt);
        
    }
}

// called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
	for (SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

//Then this delegate Funtion Will be fired
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
  if (queue.transactions.count > 0) {
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for (SKPaymentTransaction *transaction in queue.transactions) {
      [ids addObject:transaction.payment.productIdentifier];
    }

    NSError *e = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ids options:0 error:&e];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!e) {
      Event evt(etIN_APP_PURCHASE_RESTORE);
      evt.data = [jsonString UTF8String];
      nme_extensions_send_event(evt);
    }
    [ids release];
    [jsonString release];
  }
}

- (void)dealloc{
	if(myProduct) [myProduct release];
	if(productsRequest) [productsRequest release];
	if(productID) [productID release];
  if(products) [products release];
	[super dealloc];
}

@end

extern "C"{
	static InAppPurchase *inAppPurchase = nil;
	
	// static const char* jailbreak_apps[] = {
	// 	"/Applications/Cydia.app", 
	// 	"/Applications/limera1n.app", 
	// 	"/Applications/greenpois0n.app", 
	// 	"/Applications/blackra1n.app",
	// 	"/Applications/blacksn0w.app",
	// 	"/Applications/redsn0w.app",
	// 	NULL,
	// };

	// bool isJailBroken(){
	// 	// Now check for known jailbreak apps. If we encounter one, the device is jailbroken.
	// 	for (int i = 0; jailbreak_apps[i] != NULL; ++i){	
	// 		if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]]){
	// 			
	// 			Event evt(etIN_APP_PURCHASE_FAIL);
	// 			evt.data = "IN_APP_PURCHASE_FAIL!";
	// 			nme_extensions_send_event(evt);
	// 			
	// 			return YES;
	// 		}		
	// 	}
	// 	return NO;
	// }

	void initInAppPurchase(){
		inAppPurchase = [[InAppPurchase alloc] init];
		[inAppPurchase initInAppPurchase];
	}

  void requestProductData(const char *productIDs) {
    NSArray *productArray = [[NSString stringWithUTF8String:productIDs] componentsSeparatedByString:@","];
    [inAppPurchase requestProducts:[NSSet setWithArray:productArray]];
  }

	bool canPurchase(){
		return [inAppPurchase canMakePurchases];
	}

	void purchaseProduct(const char *inProductID){
		//if(isJailBroken())	return;
		NSString *productID = [[NSString alloc] initWithUTF8String:inProductID];
		[inAppPurchase purchaseProduct:productID];
	}

  void restorePurchases() {
    [inAppPurchase restorePurchases];
  }

	void releaseInAppPurchase(){
		[inAppPurchase release];
	}
	
}



