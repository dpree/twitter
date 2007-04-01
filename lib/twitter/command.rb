# The command class is used for the command line interface. 
# It is only used and included in the bin/twitter file.
module Twitter
  class Command
    @@commands  = [:post, :timeline, :friends, :friend, :followers, :follower, :featured]
    
    @@template  = <<EOF
# .twitter
# 
# Please fill in fields like this:
#
#  email: bla@bla.com
#  password: secret
#
email: 
password: 
EOF
 
    class << self
      def process!
        command = ARGV.shift
        
        if !command.nil? && @@commands.include?(command.intern)
          send(command)
        else
          puts "\nUsage: twitter <command> [options]\n\nAvailable Commands:"
          Twitter::Command.commands.each do |c|
            puts "    - #{c}"
          end
        end
      end
      
      def commands
        @@commands
      end
      
      # Posts an updated status to twitter
      def post
        config = create_or_find_config
        
        if ARGV.size == 0
          puts %(\n  You didn't enter a message to post.\n\n  Usage: twitter post "You're fabulous message"\n)
          exit(0)
        end
        
        post = ARGV.shift
        
        status = Twitter::Base.new(config['email'], config['password']).post(post)
        puts "\nGot it! New twitter created at: #{status.created_at}\n"
      end
      
      # Shows status, time and user for the specified timeline
      def timeline
        config = create_or_find_config
        
        timeline = :friends
        timeline = ARGV.shift.intern if ARGV.size > 0 && Twitter::Base.timelines.include?(ARGV[0].intern)
        
        puts
        Twitter::Base.new(config['email'], config['password']).timeline(timeline).each do |s|
          puts "#{s.text}\n-- #{s.user.name} at #{s.created_at}"
          puts
        end
      end
      
      def friends
        config = create_or_find_config
        
        puts
        Twitter::Base.new(config['email'], config['password']).friends.each do |u|
          puts "#{u.name} (#{u.screen_name})"
          puts "#{u.status.text} at #{u.status.created_at}" unless u.status.nil?
        end
      end
      
      # Shows last updated status and time for a friend
      # Needs a screen name
      def friend
        config = create_or_find_config
        
        if ARGV.size == 0
          puts %(\n  You forgot to enter a screen name.\n\n  Usage: twitter friend jnunemaker\n)
          exit(0)
        end
        
        screen_name = ARGV.shift
        
        puts
        found = false
        Twitter::Base.new(config['email'], config['password']).friends.each do |u|
          if u.screen_name == screen_name
            puts "#{u.name} #{u.screen_name}"
            puts "#{u.status.text} at #{u.status.created_at}" unless u.status.nil?
            found = true
          end
        end
        
        puts "Sorry couldn't find a friend of yours with #{screen_name} as a screen name" unless found
      end
      
      # Shows all followers and their last updated status
      def followers
        config = create_or_find_config
        
        puts
        Twitter::Base.new(config['email'], config['password']).followers.each do |u|
          puts "#{u.name} (#{u.screen_name})"
          puts "#{u.status.text} at #{u.status.created_at}" unless u.status.nil?
        end
      end
      
      # Shows last updated status and time for a follower
      # Needs a screen name
      def follower
        config = create_or_find_config
        
        if ARGV.size == 0
          puts %(\n  You forgot to enter a screen name.\n\n  Usage: twitter follower jnunemaker\n)
          exit(0)
        end
        
        screen_name = ARGV.shift
        
        puts
        found = false
        Twitter::Base.new(config['email'], config['password']).followers.each do |u|
          if u.screen_name == screen_name
            puts "#{u.name} (#{u.screen_name})"
            puts "#{u.status.text} at #{u.status.created_at}" unless u.status.nil?
            found = true
          end
        end
        
        puts "Sorry couldn't find a follower of yours with #{screen_name} as a screen name" unless found
      end
      
      def featured
        puts
        puts 'This is all implemented, just waiting for twitter to get the api call working'
        # config = create_or_find_config
        # 
        # puts
        # Twitter::Base.new(config['email'], config['password']).featured.each do |u|
        #   puts "#{u.name} last updated #{u.status.created_at}\n-- #{u.status.text}"
        #   puts
        # end
      end
      
      private
        # Checks for the config, creates it if not found
        def create_or_find_config
          home = ENV['HOME'] || ENV['USERPROFILE'] || ENV['HOMEPATH']
          begin
            config = YAML::load open(home + "/.twitter")
          rescue
            open(home + '/.twitter','w').write(@@template)
            config = YAML::load open(home + "/.twitter")
          end
          
          if config['email'] == nil or config['password'] == nil
            puts "Please edit ~/.twitter to include your twitter email and password\nTextmate users: mate ~/.twitter"
            exit(0)
          end
          
          config
        end
    end
  end
end