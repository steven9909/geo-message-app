# GeoMessage

Flutter App designed to allow users to leave annoymous messages at their current location. You can also read nearby messages within a certain distance from your current location. The messages persist until it is picked up by someone else and dissapears once it is read. 

At first you will be greeted with the loading screen while the app tries to grab the location of your phone:

<img src="https://github.com/steven9909/GeoMessageApp/blob/master/assets/images/loading_screen.png" width="350"/>

After the app succesfully locates your phone it will turn into:

<img src="https://github.com/steven9909/GeoMessageApp/blob/master/assets/images/loading_screen_2.png" width="350"/>

Then you will be greeted with:

<img src="https://github.com/steven9909/GeoMessageApp/blob/master/assets/images/map.png" width="350"/>

where you can center the map position to your location with the bottom center button or compose a message in your location using the top right icon button. Pressing the top right icon button leads to:

<img src="https://github.com/steven9909/GeoMessageApp/blob/master/assets/images/message_write.png" width="350"/>
<img src="https://github.com/steven9909/GeoMessageApp/blob/master/assets/images/message_written.png" width="350"/>

After submitting, the map updates and fetches the message from the database and places a marker where the message was sent:

<img src="https://github.com/steven9909/GeoMessageApp/blob/master/assets/images/marker_updated.png" width="350"/>

This marker is visible to anyone within a certain radius (depends on the setting) and anyone can click on it and view the message. However, once the message is viewed by 1 person, it is gone forever.

<img src="https://github.com/steven9909/GeoMessageApp/blob/master/assets/images/message_viewed.png" width="350"/>
<img src="https://github.com/steven9909/GeoMessageApp/blob/master/assets/images/message_gone.png" width="350"/>

This works with any number of users.
