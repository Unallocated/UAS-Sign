UAS-Sign
========

Unallocated Space Prolite sign API code

This code provides a REST API for updating the text on the LED sign above the bathrooms.

This readme is not complete and the code is still considered to be beta so at any given time this may be outdated or inacurate.

The code will not run unless it has a valid serial device to output to. For testing purposes, you can create a fake serial device with socat like this:
socat -d -d pty,raw,echo=0 pty,raw,echo=0

Example usage:
http POST to [server_ip]:8080/message/new to write a new message to the sign:
	curl -d '{"message":"This message is orange.","color":"orange","transition":"none","timer":"2h15m"}' signserver:8080/message/new
The server will return:
	{"message":"This message is orange.","color":"orange","transition":"none","timer":"2h15m","uuid":"d3397304-4363-46fe-9a7b-14fb1eba6b65"}
The uuid is unique to your message and is used to update or delete your message
color, transition, and timer are optional, if they are ommited they default to "red", "close", and "30m"

Color options are:
	red
	green
	yellow
	orange
	rainbow

Transition options are:
	none
	close
	dots
	scrollup
	scrolldown
	
Timer is a time string in the format [num]h[num[m]. The message will be automatically deleted after the time has elapsed.

http DELETE to [server_ip]/message/[uuid] to remove message [uuid] from the sign
	curl -X DELETE signserver:8080/message/cf7e5697-1b18-421e-b2b8-85b2d3bc4194
The uuid of a message is only know to the person/client and the server so that messages can only be deleted by their creators

http PUT to [server_ip]/message/[uuid] to change message [uuid]
	curl -X PUT -d '{"message":"This is updated message text.","color":"orange","transition":"none"}' signserver:8080/message/cf7e5697-1b18-421e-b2b8-85b2d3bc4194
