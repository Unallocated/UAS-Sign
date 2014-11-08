class ledSign
  def initialize()
    @tty  = '/dev/ttyUSB0'
    @baud = 9600
    @bytesize = serial.EIGHTBITS
    @parity   = serial.PARITY_NONE
    @stopbit  = serial.STOPBITS_ONE
    @timeout  = .5
    @xonxoff  = 0 
    @rtscts   = 0
    @signBuffer = [] #buffer to be written
    @signBufHistory = [] #buffer that was written
    #SCF @formatRE =~ ('<ID\d\d><\w\w>.*') #match something that looks like <ID01><PA>
  end

  def formatMSG(msg, page='A')
    #Format a message with page and propper headers and footers
    #SCF May need to work on this if elsif else
    if str(msg) == '': #clear each page
        fmsg = '<ID01><P%s> %s \r\n'[:1016] %(page,msg)
    elsif !(msg =~ '<ID\d\d><\w\w>.*') #use client supplied formatting
        fmsg = str(msg)+'\r\n'[:1016]
    else
        fmsg = "<ID01><P%s><CL> {0} %s \r\n"[:1016] %(page,msg)
    return fmsg
    end
  end

  def signCheck(ledSign)
    #Check to see if the sign is on, True if on False if off
    ledSign.openSerial()
    ledSign.signObj.write("<ID01>\r\n")
    responce = ledSign.signObj.read(10)
    CloseSerial()
    #SCF not sure what responce[:8] means
        if len(responce) >=8 && responce[:8] == "\x13<ID01>S":
            return True
        else
            return False
        end
  end

  def openSerial
    #Open led sign serial device
    #SCF Need to wrap this code in ruby error handling syntax
    try:
          @signObj  = serial.Serial(@tty, @baud, @bytesize,
            @parity, @stopbit, @timeout, @xonxoff, @rtscts)
        @signObj.flush() #flush serial connection
    except Exception:
        print("Open Failed")
        return
  end

  def clearSign
    #A function to blank out every page on the sign
    print("Clearing all sign Pages")
    #SCF need to make this a RUBY for loop
    for x in range(65,91):
        #time.sleep(.2)
        CycleWriteMsg('',chr(x)) #1016 is max message len
  end

  def sendSTDMessage(ledSign, message, page='A')
      #Send a standard text message to the LED screen
        sTDMessage = formatMSG(message,page)
        ledSign.signObj.write(STDMessage) #1016 is max message len
  end

  def CloseSerial(self):
    #Flush all data to serial device and then close connection
    #SCF need to format this if statement
    if self.signObj.isOpen() is True:
        self.signObj.flush()
        self.signObj.close()
      end
  end

  def CycleWriteMsg(self,message,page):
    #Open serial device write message then close it
    #SCF need to format this if statement
    if self.signObj.isOpen() is True:
        self.CloseSerial()
        self.OpenSerial()
        self.SendSTDMessage(message,page)
        self.CloseSerial()
    else
        self.OpenSerial()
        self.SendSTDMessage(message,page)
        self.CloseSerial()
      end
  end

end