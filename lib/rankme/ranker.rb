module Rankme
  class Ranker
    attr_accessor :played, :players, :current_match_up

    def initialize(player_ids = [])
      reset(player_ids)
    end

    def get_match_up
      @current_match_up
    end

    def start
      puts "initializing game"
      next_round
    end

    def play(winner_id = nil)
      if @current_match_up.empty?
        start
      end

      if winner_id.nil? || !@current_match_up.include?(winner_id)
        puts "no winner (#{winner_id})"
        return @current_match_up
      else
        puts "WINNER (#{winner_id})"
      end

      score(winner_id)

      #return next match-up
      next_round
    end

    def skip_match
      left_player_id, right_player_id = *current_match_up
      @skipped << [left_player_id, right_player_id]
      puts "skipping #{@skipped}"
      next_round
    end

    def get_left_player_id(remaining_player_ids)
      remaining_player_ids.sample
    end

    def get_right_player_id(remaining_player_ids, left_player_id)

      remaining_player_ids = remaining_player_ids.select { |k| k != left_player_id }
      skip_list = []
      @skipped.each do |pair|
        if pair.include?(left_player_id)
          skip_list.push(pair.reject { |k| k == left_player_id })
          remaining_player_ids = remaining_player_ids.reject { |k| skip_list.flatten.include?(k) }
        end
      end
      remaining_player_ids.sample
    end

    def next_round
      remaining_player_ids = get_remaining_player_ids
      left_player_id = get_left_player_id(remaining_player_ids)
      right_player_id = get_right_player_id(remaining_player_ids, left_player_id)

      @current_match_up = []

      if !left_player_id.nil? && !right_player_id.nil?
        @current_match_up = [left_player_id, right_player_id]
        puts "inside round: #{get_round()}: current_match_up #{current_match_up}"
      else

      end

      puts "round: #{get_round()}: current_match_up #{current_match_up}"

      return @current_match_up
    end

    def progress
      if @played.length > 0
        ( ( @played.length / ( @players.length * 2 ).to_f ) * 100 ).round(0)
      else
        0
      end
    end

    def add_player(player_id)
      if @players.is_a?(Hash)
        @players[player_id] = Player.new(player_id)
        puts "added player #{player_id} total players #{@players.count}"
      else
        raise StandardError "Players is not a Hash!"
      end
    end

    def results
      # return plays sorted
      @played.uniq.sort_by!{ |player| player.score.estimated_skill } .reverse.map(&:id)
    end

    def reset(player_ids = [])
      @players = {}
      @results = []
      @played = []
      @played_pairs = []
      @skipped = [] #array of skipped match_ups
      @current_match_up = []
      player_ids.each { |id| add_player(id) }
    end

    def get_player_score(player_id)
      @players[player_id].try(:score)
    end

    def score(winner_id)
      loser_id = @current_match_up.select { |k,v| k != winner_id }[0]
      #score round

      winner = @players[winner_id]

      loser = @players[loser_id]

      scored = Rankme::Stats.calculate_mu_sigma(winner, loser)

      @played.push(scored[0])
      @played.push(scored[1])

      first = @players[scored[0]]
      second = @players[scored[1]]

      @played_pairs.push([first, second])

      puts "#{@current_match_up}"
      puts "round #{get_round()} #{@played.map(&:id).length}/#{@players.length} #{progress} -#{winner_id}- stomps -#{loser_id}-"
    end

    def get_round
      return @played.count / 2
    end

    def get_remaining_player_ids
      remaining_player_ids = []
      backup_player = nil

      average_count = get_average_count

      puts "average #{average_count}"
      @players.each_value do |p|

        puts "get remaining player ids ... #{p.id} - #{p.count}"
        if p.count <= average_count
          remaining_player_ids << p.id
        else
          if backup_player.nil?
            backup_player = p.id
          else
            if p.count <= @players[backup_player].count
              backup_player = p.id
            end
          end
        end
      end
      remaining_player_ids << backup_player if remaining_player_ids.length < 2
      return remaining_player_ids
    end

    def get_average_count
      sum = 0
      @players.each_value do |p|
        puts "averaging #{p.count}"
        sum += p.count
      end
      average = ( sum / @players.count.to_f )
      return average
    end

    def sort_players(a, b)
      @players[a].score.estimated_skill <=> @players[b].score.estimated_skill
    end

    def get_last_round_player_objects
      @played_pairs[-1]
    end

    def get_player_score(player_object)
      player_object.score
    end

    def last_round_scores
      players_hash = {}
      player_pair = get_last_round_player_objects
      first = player_pair[0]
      second = player_pair[1]
      players_hash[first.id] = { 'mu' => first.score.mu, 'sigma' => first.score.sigma, 'score' => first.score.estimated_skill }
      players_hash[second.id] = { 'mu' => second.score.mu, 'sigma' => second.score.sigma, 'score' => second.score.estimated_skill }
      return players_hash
    end
  end
end