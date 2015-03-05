UAS-Sign
========

Unallocated Space Prolite sign API code

This code provides a REST API for updating the text on the LED sign above the bathrooms.

This readme is not complete and the code is still considered to be beta so at any given time this may be outdated or inacurate.

The code will not run unless it has a valid serial device to output to. For testing purposes, you can create a fake serial device with socat like this:
socat -d -d pty,raw,echo=0 pty,raw,echo=0

Example usage:
http POST to server/message/new to write a new message to the sign:
	curl -d '{"message":"This message is orange.","color":"orange","transition":"none"}' localhost:4567/message/new
The server will return:
	{"message":"This message is orange.","color":"orange","transition":"none","uuid":"d3397304-4363-46fe-9a7b-14fb1eba6b65"}
The uuid is unique to your message and is used to update or delete your message
color and transition are optional, if they are ommited they default to "red" and "close"

http DELETE to server/message/uuid to remove message from the sign
	curl -X DELETE localhost:4567/message/cf7e5697-1b18-421e-b2b8-85b2d3bc4194
The uuid of a message is only know to the person/client and the server so that messages can only be deleted by their creators

