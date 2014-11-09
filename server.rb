require 'thread'
require 'socket'
include Socket::Constants

class Server
  def initialize(ip="0.0.0.0",port=9001)
    #threading.Thread.__init__(self)
    thread = Thread.new()

    #threading.Thread.daemon = True
    thread.Thread.daemon = true
    @ip  = ip
    @port = port
    #TODO Don't think we need these two:  
    @sign = LEDSign.new() #sign is the namespace of the led sign class 
    @controller = SignController.new() #namespace of the controller used catch request to kills
    
    @die = False
  end

  def OpenListener()
    #Open socket to lisen for messages
    @mySocket = Socket.new( AF_INET, SOCK_STREAM, 0 )
    sockaddr = Socket.pack_sockaddr_in( @port, @ip )
    @mySocket.bind( sockaddr )
    @mySocket.listen( 5 )
  end


  def CloseListener()
    #Close Socket
    @mySocket.close
    puts("Listen socket closed")
  end

  def GetMessage()
      Get a message from a client and append it to the Sign Buffer to be displayed 
      puts "Waiting for Connections"
      #TODO Need to work on this:
      channel, details = self.mySocket.accept()
      puts("We have opened a Connection with "+str(details))
    begin
      message = channel.recv(1024)
      if @sign.SignCheck() == false
        #TODO Need to work on this:
        #channel.sendall('The sign is turned off')
        return None
        #TODO Need to work on this:
        #@sign.signBufHistory.append('%s,%s\n'%(details[0],message))
        @sign.signBuffer.append(message)
      end
    rescue
          print(len(self.sign.signBuffer))
          channel.sendall("Updating sign to "+message)
          os.system("python /opt/uas/random/ringaling.py 500")
          return False
    end

    def recover()
      #recover if the listener crashes
      begin
        CloseListener()
        OpenListener()
      rescue
        print("waiting for port to close:")
          begin
            CloseListener()
            sleep 10
            OpenListener()
          rescue
            puts("you broke it you dumb mook")
            @controller.cancel()
          end

      end

    end

    def run()
    #Run the thread in a loop
      begin
        OpenListener()
        while true
            if not controller.running.is_set()
                CloseListener()
                break
            else
                if GetMessage() == false
                  recover()
                end
            end
            end    
      rescue
        CloseListener()
        print "The Listener Closed"
        exit(-1) 

      end
    end



                


  end
end