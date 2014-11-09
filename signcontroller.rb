class SignController
  #Class to controll the LCD sign
  def initialize (signConnector)
    #TODO @running = threading.Event() #used to kill thread
    @newMessage = ""
    @spaceSign = ledSign(signConnector)
    @spaceSign.OpenSerial()
    @spaceSign.ClearSign()
    @spaceSign.CloseSerial()
    @ledServer = server(@spaceSign)
    @ledServer.start()
    @running.set() #mark that the server thread is running
    #TODO @safety = threading.RLock()
  end

  def cancel()
    #Exit the program
    #TODO
  end

  def exitJob()
    #Close out anything we had running and exit
    #THIS FUNCTION IS ALL messed UP IGNORE THIS CODE 
    #Ill fix the control C break later
  end

  def writeHistory()
    #Write out log file of every item written to sign
    #should check what page its written to?
    begin
      if len(@spaceSign.signBufHistory) == 0

      else
        current = @spaceSign.signBufHistory[-1]
        history = open('SignHistory.csv','a')
        history.writelines(current)
        history.close()

        csign = open('/tmp/sign','w')# added by CP for bot stuff
        #TODO csign.write(current[current.find(',')+1:])
        csign.close()

        os.system("bash ./sign2wave.sh") # for the asterisk box
      end

    rescue
      print('Sign History file not found\n')
    end
  end

  def readHistory()
    #Read in log file to display last message update
    
    begin
    history = open('SignHistory.csv','r')
    x = history.readlines()[-1].strip()
    if (x == '')
      history.seek(0)
      x = history.readlines()[-2].strip()
      history.close()
      return x
    end
    rescue IOError
      puts "Sign History file not found"
      return " , "
    end
  end

  def main()
    #Control the LED sign from this function

    begin
      #display the last updated message
      @spaceSign.OpenSerial()
      @spaceSign.SendSTDMessage(self.readHistory().split(',')[1])
      @spaceSign.CloseSerial()
      while true
          if !(@running.is_set())
            exitJob()
            return
          end
              
          if len(@spaceSign.signBuffer) != 0
            sleep 2
            @spaceSign.OpenSerial()
            @newMessage = @spaceSign.signBuffer.pop(0)
            @spaceSign.SendSTDMessage(self.newMessage)
            print("Wrote to Sign: "+str(self.newMessage))
            @spaceSign.CloseSerial()
            writeHistory()
          else
            sleep 5
            #TODO Not sure what to do with this:
            # except KeyboardInterrupt:
            #     pass
            #     self.cancel()
          end
    end
  end

  #TODO Not sure what to do with this:
  # if __name__ == "__main__":
  #     #test handler script
  #     controller(sys.argv[1]).main()



  end
end