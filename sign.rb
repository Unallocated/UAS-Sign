#!/usr/bin/env ruby
require 'serialport'
require 'rufus-scheduler'

class LedSign 
  def initialize(serial_dev)
    #set values for communication with the sign, establish serial connection
    @prepend = "<ID01><PA>"
    @terminator = " \r\n"
    @serial = SerialPort.new(serial_dev,9600,8,1,SerialPort::NONE)
    @serial.read_timeout = 100 #this is so @serial.read doesn't hang, units is ms
  end

  def is_on?
    #check to see if the sign is responding
    @serial.flush_input #flush data that has not been read
    @serial.write("#{@prepend}#{@terminator}")
    if @serial.read(8) == nil #This should be 12 bits for for some reason it breaks things when set to 12
      return false
    else
      return true
    end
  end

  def write(message) #returns true for success, false when sign is off
    if self.is_on?
      sleep(1) #The sign can't take input too fast.
      message = message[0,1016] #making sure we don't exceed the sign's max
      @serial.write("#{@prepend}#{message}#{@terminator}")
      return true
    else
      return false
    end
  end
end

class SignHandler
  def initialize(serial_dev)
    @messages = Hash.new
    @sign = LedSign.new(serial_dev)
    @colors = {
      red: "<CB>",
      orange: "<CD>",
      yellow: "<CG>",
      green: "<CM>",
      rainbow: "<CP>"
    }
    @transitions = {
      close: "<FG>",
      dots: "<FR>",
      scrollup: "<FI>",
      scrolldown: "<FJ>",
      none: " {0} "
    }
    @scheduler = Rufus::Scheduler.new
  end
  
  attr_reader :messages

  #function to add a new message to the sign
  def add(uuid, message, color = nil, transition = nil, timer = nil)
    color ||= :red
    transition ||= :close
    timer ||= '30m'
    @messages[uuid] = [message, color, transition, timer]
    @scheduler.in timer do
      self.delete(uuid)
    end
    return update #update will return false if message length is too long
  end

  #deletes message with number uuid from the sign
  def delete(uuid)
    @messages.delete(uuid)
    update
  end

  #clears all messages from the sign
  def reset
    @messages.clear
    update
  end

  private
  def update
    sign_text = ""
    @messages.each do |key, value|
        sign_text << "#{@transitions[value[2]]}#{@colors[value[1]]}#{value[0]}"
      end
    if sign_text.length < 1016
      puts sign_text
      @sign.write(sign_text)
      sleep(1) #keeps the sign from updating too fast
    else
      false #return false when total message length is too long for the sign
    end 
  end
end




=begin
uas_sign = SignHandler.new("/dev/ttyUSB0")
uas_sign.add(1,"red ", :red, :none)
uas_sign.add(2,"orange ", :orange, :none)
uas_sign.add(3,"green ", :green, :none)
uas_sign.add(4,"yellow ", :yellow, :none)
uas_sign.add(5,"rainbow", :rainbow, :none)


=begin
text = "start: "
while uas_sign.add(1, text, :yellow, :none)
  text = text + "123456789test  1234123412341234123412341234"
  puts text.length
  sleep(9)
end
=begin
for i in 0..5
  uas_sign.add(42, "8======D", :rainbow, :none)
  sleep(5)
  uas_sign.add(42, "this is a test", :green, :none)
  sleep(5)
end

uas_sign.reset
=end
