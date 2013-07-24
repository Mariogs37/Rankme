module Rankme
  class Ranker
    # Modules (Math for access to E)
    include Math

    # Constants
    E = Math::E
    PI = Math::PI
    BETA = 25.0 / 6.0
    GAMMA = 25.0 / 300.0
    EPSILON = 0.08
    A1 =  0.254829592
    A2 = -0.284496736
    A3 =  1.421413741
    A4 = -1.453152027
    A5 =  1.061405429
    P  =  0.3275911

    attr_accessor :played, :players, :current_match_up

    def initialize(player_ids = [])
      reset(player_ids)
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
      @current_match_up = []
      player_ids.each { |id| @players[id] = Player.new(id) }
    end

    private

    def score(winner_id)
      loser_id = @current_match_up.select { |k,v| k != winner_id }[0]
      #score round
      calculate_mu_sigma(winner_id, loser_id)
      puts "#{@played.map(&:id).length}/#{@players.length} #{progress} -#{winner_id}- stomps -#{loser_id}-"
    end

    def next_round
      players_left = @players.reject { |k,v| @played.flatten.include?(k) }
      match_up = []
      match_up << players_left.keys.sample
      match_up << ( players_left.select { |p| p != match_up[0] } ).keys.sample
      @current_match_up = [match_up[0], match_up[1]]
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