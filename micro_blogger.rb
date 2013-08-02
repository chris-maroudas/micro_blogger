require 'jumpstart_auth'
require 'bitly'
require 'klout'
Bitly.use_api_version_3

class MicroBlogger

  attr_reader :client

  def initialize
    puts "Initializing.."
    @client = JumpstartAuth.twitter # this is our connection to Twitter
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def run
    puts "Welcome to the JSL Twitter Client!"

    input = ''
    until input == "quit"
      printf "Enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]


      case command
        when 'quit' then
          puts "Goodbye!"
        when 'tweet' then
          tweet(parts[1..-1].join)
        when 'turl' then
          tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        when 'dm' then
          dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then
          spam_my_followers(parts[1..-1].join)
        when 'score' then
          klout_score(parts[1])
        else
          puts "Sorry, I don't know how to #{command}"
      end

    end

  end

  def tweet(message)

    if message.length <= 140
      @client.update(message)
      puts 'Message send'
    else
      puts 'Your message exceeded the 140 chars limit.'
    end

  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    to_send = "d #{target} #{message}"

    screen_names = @client.followers.collect { |follower| follower.screen_name }

    if screen_names.include?(target)
      tweet(to_send)
    else
      puts 'That person is not following you!'
    end

  end

  def followers_list
    screen_names = []
    @client.followers.users.each { |follower| screen_names << follower["screen_name"] }
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each { |follower| dm(follower, message) }
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    bitly.shorten(original_url).short_url
  end

  def klout_score(user)
      identity = Klout::Identity.find_by_screen_name(user)
      user = Klout::User.new(identity.id)
      puts user.score.score
  end

end

blogger = MicroBlogger.new
blogger.run