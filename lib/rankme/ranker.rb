module Rankme
  class Ranker


    attr_accessor :played, :players, :current_match_up

    def initialize(player_ids = [])
      reset(player_ids)
    end

    def get_match_up
      @current_match_up
    end

    def play(winner_id = nil)
      if @current_match_up.empty?
        return next_round
      end

      if winner_id.nil? || !@current_match_up.include?(winner_id)
        return @current_match_up
      end

      score(winner_id)

      #return next match-up
      next_round
    end

    def skip_match
      left_player_id, right_player_id = *current_match_up
      @skipped << [left_player_id, right_player_id]
      next_round

    end

    def get_left_player_id(remaining_players)
      skip_list = []
      left_player_id = remaining_players.keys.sample
      @skipped.each do |pair|
        if pair.include?(left_player_id)
          skip_list.push(pair.reject { |k| k == left_player_id })
          players_remaining = players_remaining.reject { |k| skip_list.flatten.include?(k) }
        end
      end
    end

    def get_right_player_id(remaining_players, left_player_id)
      remaining_players = remaining_players.select { |k| k != left_player_id }
      right_player_id = remaining_players.keys.sample
    end

    def next_round
      remaining_players = get_remaining_players
      left_player_id = get_left_player_id(remaining_players)
      right_player_id = get_right_player_id(left_player_id)
      @current_match_up = [left_player_id, right_player_id]
    end

    def progress
      if @played.length > 0
        ( ( @played.length / ( @players.length * 2 ).to_f ) * 100 ).round(0)
      else
        0
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
      @skipped = [] #array of skipped match_ups
      @current_match_up = []
      player_ids.each { |id| @players[id] = Player.new(id) }
    end

    def get_player_score(player_id)
      @players[player_id].try(:score)
    end



    private

    def score(winner_id)
      loser_id = @current_match_up.select { |k,v| k != winner_id }[0]
      #score round
      calculate_mu_sigma(winner_id, loser_id)
      puts "#{@current_match_up}"
      puts "#{@played.map(&:id).length}/#{@players.length} #{progress} -#{winner_id}- stomps -#{loser_id}-"
    end

    def get_remaining_players
      played_keys = @played.map(&:id)
      @players.reject { |k,v| played_keys.include?(k) }
    end

    def sort_players(a, b)
      @players[a].score.estimated_skill <=> @players[b].score.estimated_skill
    end

    # Functions: erf, pdf, cdf, vwin, wwin
    def erf(x)
      # save the sign of x
      sign = 1
      if x < 0
        sign = -1
      end
      x = x.abs
      # A&S formula 7.1.26
      t = 1.0 / (1.0 + P * x)
      y = 1.0 - (((( (A5 * t + A4) * t) + A3) * t + A2) * t + A1) * t * E **(-x * x)
      sign * y
    end

    def pdf(x)
      1 / (2 * PI) ** 0.5 * E ** (-x ** 2 / 2)
    end

    def cdf(x)
      (1 + erf(x / PI ** 0.5)) / 2
    end

    def vwin(t, e)
      pdf(t - e) / cdf(t - e)
    end

    def wwin(t, e)
      vwin(t, e) * (vwin(t, e) + t - e)
    end

    # Update mu and sigma values for winner and loser

    def calculate_mu_sigma(winner_id, loser_id)
      muw = @players[winner_id].score.mu
      sigmaw = @players[winner_id].score.sigma

      mul = @players[loser_id].score.mu
      sigmal = @players[loser_id].score.sigma

      c = (2 * BETA ** 2 + sigmaw ** 2 + sigmal ** 2) ** 0.5
      t = (muw - mul) / c
      e = EPSILON / c
      sigmaw_new = (sigmaw ** 2 * (1 - (sigmaw ** 2) / (c ** 2) * wwin(t, e)) + GAMMA ** 2) ** 0.5
      sigmal_new = (sigmal ** 2 * (1 - (sigmal ** 2) / (c ** 2) * wwin(t, e)) + GAMMA ** 2) ** 0.5
      muw_new = (muw + sigmaw ** 2 / c * vwin(t, e))
      mul_new = (mul - sigmal ** 2 / c * vwin(t, e))

      @players[winner_id].score.mu = muw_new
      @players[winner_id].score.sigma = sigmaw_new

      @players[loser_id].score.mu = mul_new
      @players[loser_id].score.sigma = sigmal_new

      winner = @players[winner_id]
      loser = @players[loser_id]

      @played.push(winner)
      @played.push(loser)
    end

  end
end