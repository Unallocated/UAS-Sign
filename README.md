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
| PUT    | [server]/message/[uuid] | 200 with all message attributes | An existing message is updated.**see note**                       |
| DELETE | [server]/message/[uuid] | 200 with no data                | A message is deleted from the sign.                               |
| GET    | [server]/message/[uuid] | 200 with all message attributes | Returns message attributes, does not change anything on the sign. |

The server will respond with a 404 error if a target does not exist.

**Note:**Currently the PUT request will set default attribute values to the message when they are not specifed. For example, if you update a
message that is orange with a new message and do not add `{ "color":"orange" }` to your request, the default value for the color attribute (red)
will be applied to the message. This is not desired behavior and will be fixed in futre updates.

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

Here are some examples of interacting with the sign using curl. The examples are using the "-v" switch to show HTTP headers.

####Write a new message to the sign:

`curl -vd '{"message":"This message is orange.","color":"orange","transition":"none","timer":"2h15m"}' localhost:8080/message/new`

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


####Update the message we just wrote with new text:

`curl -X PUT -vd '{"message":"This is an updated message"}' localhost:8080/message/95b00c05-b134-4f7d-9a61-6fcd55b9ec03'`

Server response(HTTP header + JSON data):
> < HTTP/1.1 200 OK                                                                                                          
> < Content-Type: application/json                                                                                           
> < Content-Length: 100                                                                                                      
> < X-Content-Type-Options: nosniff                                                                                          
> < Connection: keep-alive                                                                                                   
> < Server: thin 1.3.1 codename Triple Espresso                                                                              
> <                                                                                                                                                                                                       
> {"message":"This is an updated message","status":"on","uuid":"95b00c05-b134-4f7d-9a61-6fcd55b9ec03"}

Note that the server does not return message attributes that were not set by the client (color, timer, transition). These attributes will be reset to their
defaults. See note on PUT requests above. This is not desired behavior and will be addressed in the future.

####Getting the message from the server:

`curl -v localhost:8080/message/95b00c05-b134-4f7d-9a61-6fcd55b9ec03`

Server response(HTTP header + JSON data):
> < HTTP/1.1 200 OK                                                                        
> < Content-Type: application/json                                                         
> < Content-Length: 89                                                                     
> < X-Content-Type-Options: nosniff                                                        
> < Connection: keep-alive                                                                 
> < Server: thin 1.3.1 codename Triple Espresso                                            
> <                                                                                                                                    
> {"message":"This is an updated message","color":"red","transition":"close","timer":"30m"}>

Note again that the color, transition, and timer attributes have been reset to defaults.

####Deleting a message from the server:

`curl -vX DELETE localhost:8080/message/95b00c05-b134-4f7d-9a61-6fcd55b9ec03`

Server response(HTTP header + JSON data):
> < HTTP/1.1 1                                 
> < Content-Type: application/json             
> < Content-Length: 0                          
> < X-Content-Type-Options: nosniff            
> < Connection: keep-alive                     
> < Server: thin 1.3.1 codename Triple Espresso

Notes
-----

Server response codes are not completly RESTfull yet. In the future responses that return no data will set 204 instead of 200.
There is no error checking built into the codebase yet so it is entirely possible that a malicious request could break things.
If you find a bug please report it as an issue on the github page.

Hack the planet.
