
# HOOT


To build & run, 

Clone the project to your Xcode with the GitHub provided address, or with the GitHub button ”Open in Xcode”


Set your preferred Team, Provisioning Profile & Signing certificate in the Hoot target, and build to your device.

If any problems with the pods, reinstall with the included podfile.

**If running on simulator, toggle the hardware keyboard off and use the simulator’s software keyboard. ⇧⌘K  
Hardware keyboard in the simulator doesn't play together well with the keyboardnotifications.**


Tests are recommened to be run on a simulator or a device which is not used to run the application.  
(Although if done so, there will not be a problem as any affected user data will be synced again to the device/simulator. Just logout the current user before running the tests if there is one logged in.)  
Note that the syncAndDelete tests require a network connection.    
Tests are designed to run in suites.  

Users can be created liberally in the app.

