NME extensions for IOS/Android game development

Features<br/>
-------------
*   InAppPurchase<br/>
*   Google Analytics<br/>
*   GameCenter<br/>
*   AdMob<br/>
*   NativeUI...

Android is not supported currently.

Installation
------------
1. Install NMEX into a directory:
git clone https://github.com/watsnow/nmex.git DESTINATION-FOLDER
2. Point haxelib to this directory:
haxelib dev nmex DESTINATION-FOLDER
3. Add the following to your application NMML file:<br />
  &lt;haxelib name="nmex" if="ios" /&gt;
4. You may need to add the following framework dependencies:<br />
  &lt;dependency name="GameKit.framework" if="ios" /&gt;<br />
  &lt;dependency name="StoreKit.framework" if="ios" /&gt;<br />
  &lt;dependency name="SystemConfiguration.framework" if="ios" /&gt;<br />
  &lt;dependency name="Social.framework" if="ios" /&gt;<br />
  &lt;dependency name="Accounts.framework" if="ios" /&gt;<br />
  &lt;dependency name="AdSupport.framework" if="ios" /&gt;<br />
  &lt;dependency name="MediaPlayer.framework" if="ios" /&gt;<br />