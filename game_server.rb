require 'socket'
require 'gosu'
require_relative 'res/data'

#  File to create server, accept clients and info exchange.
class Client
  attr_accessor :client_socket, :player_id, :x_client, :y_client, :angle, :score

  def initialize(client, id, x_client, y_client)
    # initializing client and position
    @client_socket = client
    @player_id = id
    @x_client = x_client
    @y_client = y_client
    @score = 0
  end

  def listen(players_list)
    # listening each clients and pushing arguments for them
    loop do
      next unless players_list.size == 2
      begin
        info = @client_socket.gets.chomp.split(',')
        id = info[0].to_i
        if (id == 0) && !$players.empty?
          # $players = []
        elsif id == 1
          @x_client = info[1].to_f
          @y_client = info[2].to_f
          @angle = info[3].to_f
          @score = info[4].to_f
          string_clients = "1,#{@x_client},#{@y_client},#{@angle},#{@score},#{players_list.size},#{$server_timer}"
          players_list[1 - @player_id].client_socket.puts string_clients
        end
      rescue NoMethodError
        puts 'NoMethodError'
        break
      rescue IOError
        puts 'IOError'
        @client_socket.close
      end
    end
  end
end
# creating server
server = TCPServer.new NET_HOST, NET_PORT
# creating clients array
$players = []
# Server's time
$server_timer = Gosu.milliseconds
loop do
  begin
    # server is waiting clients and initialize instances for them
    Thread.start(server.accept) do |client|
      num_players = $players.size
      if num_players < 2
        case num_players
        when 0 then
          player = Client.new(client, num_players,
                              PLAYER_1_POSITION.x, PLAYER_1_POSITION.y)
        when 1 then
          player = Client.new(client, num_players,
                              PLAYER_2_POSITION.x, PLAYER_2_POSITION.y)
        end
        $players << player
        info = "connected #{player.player_id},#{player.x_client},#{player.y_client}"
        player.client_socket.puts info
        puts info
        begin
          player.listen($players)
        rescue server.close
        end
      else
        puts 'error full number of players'
        # server.close
        client.close
      end
    end
  rescue StandardError
    break
    # puts 'Connection closed'
  end
end
