
# Description of solution / experience with the assignment


I started the project by conceptualizing it;   
- what the architecture of the app will be  
- what kind of a solution there will be for data management
- what views will there be
- how the user experience would be
- which components / frameworks / pods will it use  
 

The assignment stated that all data should be saved locally, but it also stated that the app would be for sharing observations with other users, so in addition to managing data locally a remote solution was needed. 

I skipped wireframing on this as there weren't really that many layouts, and I already had a pretty good vision on how the views and their functionalities would be and how the data flow would be.

After making plans on the other parts, I decided to handle data management with Apple's Core Data and filesystem for local persistence and Firebase Firestore and Storage for remote db & file storage.

From there I went on to do the data modeling for the objects.

In addition to the bonus features, there was mention of including video and audio to the observations, so I decided to implement both. 

As the app was to be used to share observations, there was need for user management and authentication, and I went with Firebase authentication on that, implementing the email/password authentication. 

Also to make the app a bit more whole, I decide to add the possibility to log out, and the option to delete the observations that the user had recorded.

As the app was to function fully also offline, but still access remote data when online, I decided to make a clear difference between the states and also indicate it in the app.  
In offline state, the user can save observations, delete them, and only see his/her own observations in the main view.  
In online state, the user can do the same as in offline state, and additionally the user can view all other users' observations in the main view.  
To indicate the current state, there is a label in the mainview which is displayed when the device is offline, and there is also a switch which the user can operate to see only his/her own items vs. items of all users. The switch is also flipped and the state is enforced by the app when applicable when there is a change in the network connection state.  

 Originally I thought to display all information and provide all the user actions for the observations inside the mainview cells, ie. diplaying a bigger picture, playing the audio recording and playing the video recording.  
  But it became apparent that the cell would get too cluttered with that approach, so I decided to add a detail view for the observations where the users can observe a bigger picture and play the audio & video recordings if they exist (and delete the observation if is their own).  

Both the user's observations, and other users' observations (from the local user's perspective) have their own models, which are combined together with a protocol in the mainview.
  I implemented the mainview with listeners on the remote side, being that one of the requirements was a dynamic mainview. The user's own observations are dynamic in the mainview by design and are loaded from local data.
  

After getting the data input and the views done, I moved to building the data sync and delete features.  
The data sync works in 2 ways, if the user's local db(Core data) is empty, it retrieves the users observations from Firestore if they exist.
If the user's local db is not empty, it checks if any of the observations have not been uploaded, and uploads them if it finds any.  
To clear out the possibility that the user would delete an observation while it is being uploaded to Firestore, there is a property in the object that indicates if there is an ongoing upload; if there is, the user is displayed a notice to wait for the sync to complete.  
The sync is run in the main view's viewWillAppear to ensure sync when the user logs in, as well as when the user records a new observation.

After getting the features together, I moved to creating the tests.  
As I haven't yet found a good way to mock Firestore with swift, I went with using live test data and database connections in the tests. This is not desirable in unit tests, and I do see the fact that the tests should be testing the written code, not Apple library code or 3rd party library code, but I thought this is the best available choice in this timeframe.  
There are a few tests for the viewcontroller classes, as well as for the sync & delete structs. The sync & delete tests are integration tests, and they are built at the moment to only test one of the possible 4 video&audio combination cases.  

Running through the app with the leaks instrument, there is one small leak which is due to a bug in Apple's code in UIImageViewPicker when using the infoKey CFString describing the picked mediatype, and a couple small ones which come from the FirebaseUI library, seems from the UITextFields with secureTextEntry in the FirebaseUI login viewController. The leaks are small (and cannot really be avoided when using the said functionalities), the firebaseUI ones coming only in login, and don't affect the function of the app. Also in the debugger there are outputs from BoringSSL, 'get output frames failed' and the 'TIC' outputs, which according to Apple employees come from CFNetwork since iOS 11 and are safe to ignore when (and as) everything works as expected.

Hmm, what else, the images are royalty free images, and the ones redesigned were done with GIMP.  
For languages, I wrote the code with support for localization.  

All in all, I enjoyed completing the assignment. I do like to create things and when I get to think of solutions, it puts me into a mind space I enjoy being in.

*-- Kristian*