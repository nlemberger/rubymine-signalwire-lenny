require "signalwire"
require 'open-uri'
require 'localtunnel'
require 'webrick'


# Signalwire tokens, either set in WSL environment, or uncomment and set here.
#ENV['SIGNALWIRE_PROJECT_KEY'] = 'YOUR_PROJECT_KEY'
#ENV['SIGNALWIRE_TOKEN'] = 'YOUR_TOKEN'

# Start the local webserver
Thread.new {
  include WEBrick
  s = HTTPServer.new(:Port => 3000,  :DocumentRoot => Dir::pwd)
  s.start
}

# Start the local-tunnel client
Localtunnel::Client.start(port: 3000)
puts "Local Tunnel Running: #{Localtunnel::Client.running?}"
puts "Local Tunnel URL: #{Localtunnel::Client.url}"

class MyConsumer < Signalwire::Relay::Consumer
  contexts ['lenny']

  def on_event(event)
    #puts "Received Event #{event.payload}"
  end

  def on_task(task)
    #puts "Received Task #{task.message}"
  end

  def on_incoming_call(call)
    # Answer
    call.answer

    puts "New incoming call!"

    # Lenny speech collector parameters, wait 20s for human to talk, move on to next lenny utterance after 0.75s of silence
    lenny_speech_collect_params = { initial_timeout: 20, speech: { end_silence_timeout: 1 } }

    # Lenny record call parameters (no initial timeout, no end or silence detection timeout)
    lenny_record_params = { audio: { initial_timeout: 0, end_silence_timeout: 0, direction: 'both' } }


    # Start recording the call, why Lenny if you can't laugh at the results
    record_action = call.record!(lenny_record_params)

    # Start the Lenny loop
    (1..19).each do |num|
      break if call.state != "answered"

      audio_file = "#{Localtunnel::Client.url}/resources/Lenny#{format('%02d', num)}.ulaw.mp3"
      puts "Loop #{num}, playing: #{audio_file}"

      # Here's where it gets fun, play lenny, wait for the caller to talk
      call.prompt_audio(lenny_speech_collect_params, audio_file)
    end

    # Stop record_action
    record_action.stop
    sleep 1

    # Fetch the recording
    download_url = record_action.component.url.nil? ? nil : URI.parse(record_action.component.url)

    puts "Download URL: #{download_url}"
    if !download_url.nil? then
      filename = "#{Dir.getwd}/recordings/#{File.basename(download_url.path)}"
      puts "Filename: #{filename}"

      File.open(filename, "wb") do |file|
        file.write open(download_url).read
      end
    end

    # End the call
    call.hangup
  rescue StandardError => e
    puts e.inspect
    puts e.backtrace
  end
end

MyConsumer.new.run