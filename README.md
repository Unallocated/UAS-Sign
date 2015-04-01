UAS-Sign
========

This code provides a REST API for updating the text on the LED sign above the bathrooms.

*This readme is not complete and the code is still considered to be beta so at any given time this may be outdated or inacurate.*

The code will not run unless it has a valid serial device to output to. For testing purposes, you can create a fake serial device with socat like this:
socat -d -d pty,raw,echo=0 pty,raw,echo=0

Suported HTTP Methods
---------------------
###Client Methods
The table below shows methods the server will respond to from any client.

| Method | Target                  | Response                        | Result                                                            |
|--------|-------------------------|---------------------------------|-------------------------------------------------------------------|
| POST   | [server]/message/new    | 201 with all message attributes | A new message is written to the sign and assigned a new uuid.     |
| PUT    | [server]/message/[uuid] | 200 with all message attributes | An existing message is updated.                                   |
| DELETE | [server]/message/[uuid] | 200 with no data                | A message is deleted from the sign.                               |
| GET    | [server]/message/[uuid] | 200 with all message attributes | Returns message attributes, does not change anything on the sign. |

The server will respond with a 404 error if a target does not exist.

###Admin Methods
This table shows methods the server will respond to if the request orginates from localhost(127.0.0.1) only.

| Method | Target                | Response                            | Result                                                                       |
|--------|-----------------------|-------------------------------------|------------------------------------------------------------------------------|
| GET    | [server]/message/all  | 200 with every message's attributes | Returns every message's attributes, does not change anything on the sign.    |
| DELETE | [server]/message/all  | 200 with no data                    | Nuclear option, deletes every message from the sign and any queued messages. |

The server will respond with a 401 if a client that isn't localhost uses either method on "/message/all".

Message Attributes
------------------
The server accepts JSON data for POST and PUT requests with attributes from the table below.

| Attribute  | Required | Valid values                                                    | Effect                                                     |
|------------|----------|-----------------------------------------------------------------|------------------------------------------------------------|
| message    | yes      | String contanting any characters supported by the ProLite sign. | This is the text of the message being written to the sign. |
| color      | no       | red                                                             | This will set to color of the message.                     |
|            |          | green                                                           |                                                            |
|            |          | yellow                                                          |                                                            |
|            |          | orange                                                          |                                                            |
|            |          | rainbow                                                         |                                                            |
| transition | no       | none                                                            | This sets how the sign will transition into the message.   |
|            |          | close                                                           |                                                            |
|            |          | dots                                                            |                                                            |
|            |          | scrollup                                                        |                                                            |
|            |          | scrolldown                                                      |                                                            |
| timer      | no       | [num]h[num]m                                                    | This sets how long the message will be displayed.          |
|            |          |                                                                 | The message will be deleted after the time has elapsed.    |







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

Admin functionality:
The following actions can only be preformed from localhost.

http get to [server_ip]/message/all
	returns all messages and their id's

http DELETE to [server_ip]/message/all
	deletes every message from the sign
