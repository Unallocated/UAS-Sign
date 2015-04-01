UAS-Sign
========

This code provides a REST API for updating the text on the LED sign above the bathrooms.

*This readme is not complete and the code is still considered to be beta so at any given time this may be outdated or inacurate.*

The code will not run unless it has a valid serial device to output to. For testing purposes, you can create a fake serial device with socat like this: `socat -d -d pty,raw,echo=0 pty,raw,echo=0`


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
The server accepts JSON formatted data for POST and PUT requests and will return JSON formatted data on all requests that return data.

###Client Attributes

The attributes in the table below are set by the client in POST or PUT requests. 

| Attribute  | Required | Valid values                                                    | Effect                                                     |
|------------|----------|-----------------------------------------------------------------|------------------------------------------------------------|
| message    | yes      | String contanting any characters supported by the ProLite sign. | This is the text of the message being written to the sign. |
| color      | no       | red, green, yellow, orange, rainbow                             | This will set to color of the message.                     |
| transition | no       | none, close, dots, scrollup, scrolldown                         | This sets how the sign will transition into the message.   |
| timer      | no       | [num]h[num]m                                                    | This sets how long the message will be displayed.          |

Default values for attributes will be allpied if they are not specifed by the client.

| Attribute  | Default Value |
|------------|---------------|
| color      | red           |
| transition | close         |
| timer      | 30m           |

###Server Response Attributes

The server will respond to valid requests with all of the client specified attributes and with two additional attributes.

| Attribute | Possible Values | Explanation                                                                                                                        |
|-----------|-----------------|------------------------------------------------------------------------------------------------------------------------------------|
| uuid      | A valid v4 uuid | This is the id of a given message. The server will generate a uuid for every message that is used to update or delete the message. |
| status    | on, off         | This is the status of the sign. Returns "on" if the sign is powered on, "off" if the sign is not powered on.                       |

Example usage
-------------

Here are some examples of interacting with the sign using curl.

Write a new message to the sign:
`curl -d '{"message":"This message is orange.","color":"orange","transition":"none","timer":"2h15m"}' signserver:8080/message/new`
Server response(HTTP header + JSON data):
> < HTTP/1.1 201 Created                                                                                                                            
> < Content-Type: application/json                                                                                                                  
> < Location: http://localhost:8080/95b00c05-b134-4f7d-9a61-6fcd55b9ec03                                                                            
> < Content-Length: 150                                                                                                                             
> < X-Content-Type-Options: nosniff                                                                                                                 
> < Connection: keep-alive                                                                                                                          
> < Server: thin 1.3.1 codename Triple Espresso                                                                                                     
> <                                                                                                                                                                                                                                                     
> {"message":"This message is orange.","color":"orange","transition":"none","timer":"2h15m","status":"on","uuid":"95b00c05-b134-4f7d-9a61-6fcd55b9ec03"}


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
