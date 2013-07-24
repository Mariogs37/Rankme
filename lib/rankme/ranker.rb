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

    def initialize(player_ids = [])
      reset(player_ids)
    end

    def play(winner_id = nil)
      if @current_match_up.empty?
        return next_round
      end

      score(winner_id) unless winner_id.nil?

      #return next match-up
      next_round
    end

    def progress
      if @played.length > 0
        @players.length / ( @played.length * 2 )
      else
        0
      end
    end

    def results
      # return plays sorted
      participants = @players.select(@played.flatten)
      participants.sort { |a,b| sort_players(a, b) }
    end

    def reset(player_ids = [])
      @players = {}
      @results = {}
      @played = {}
      @current_match_up = []
      player_ids.each { |id| players[id] = Player.new(id) }
    end

    private

    def score(winner_id)
      loser_id = @current_match_up.reject(winner_id)
      #score round
      calculate_mu_sigma(winner_id, loser_id) unless ( winner.nil? || loser.nil? )
    end

    def next_round
      players_left = @players.reject(@played.flatten)
      match_up = []
      match_up << players_left.sample
      match_up << ( players_left.select { |p| p != match_up[0] } ).sample
      @current_match_up = [match_up[0].id, match_up[1].id]
    end

    def sort_players(a, b)
      @players[a].score.estimated_skill <=> @players[b].score.estimated_skill
    end

    # Functions: erf, pdf, cdf, vwin, wwin
    def self.erf(x)
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

    def self.pdf(x)
      1 / (2 * PI) ** 0.5 * E ** (-x ** 2 / 2)
    end

    def self.cdf(x)
      (1 + erf(x / PI ** 0.5)) / 2
    end

    def self.vwin(t, e)
      pdf(t - e) / cdf(t - e)
    end

    def self.wwin(t, e)
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
      @players[winner_id].score.mu = sigmaw_new

      @players[loser_id].score.mu = mul_new
      @players[loser_id].score.mu = sigmal_new

      @rounds << [players[winner_id], players[loser_id]]
    end

  end
end