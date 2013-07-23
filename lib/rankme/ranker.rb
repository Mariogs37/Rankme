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



    attr_accessor :squads

    def initialize
      @squads = {}
      @games = []
      @girls = ["Jessica Alba", "Jessica Simpson", "Britney Spears", "Jennifer Lopez", "Heidi Klum",
                "Gisele", "Emma Watson", "Beyonce", "Denise Richards", "Christina Aguilera", "Lucy Liu", "Nicole Kidman",
                "Jennifer Anniston", "Scarlett Johansson", "Carmen Electra", "Natalie Portman", "Anna Kournikova"]
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

    def self.calculate_mu_sigma(winner, loser)

      muw = winner[0]
      sigmaw = winner[1]
      mul = loser[0]
      sigmal = loser[1]
      c = (2 * BETA ** 2 + sigmaw ** 2 + sigmal ** 2) ** 0.5
      t = (muw - mul) / c
      e = EPSILON / c
      sigmaw_new = (sigmaw ** 2 * (1 - (sigmaw ** 2) / (c ** 2) * wwin(t, e)) + GAMMA ** 2) ** 0.5
      sigmal_new = (sigmal ** 2 * (1 - (sigmal ** 2) / (c ** 2) * wwin(t, e)) + GAMMA ** 2) ** 0.5
      muw_new = (muw + sigmaw ** 2 / c * vwin(t, e))
      mul_new = (mul - sigmal ** 2 / c * vwin(t, e))

      winner = [muw_new, sigmaw_new]
      loser = [mul_new, sigmal_new]

      [winner, loser]

    end

    def update_stats(winner, loser)
      squads[winner] ||= [25, 25.0 / 3]
      squads[loser] ||= [25, 25.0 / 3]
      [squads[winner], squads[loser]]
    end

    def assign_mu_sigma(winner, loser)
      game_stats = update_stats(winner, loser)
      winner_stats = game_stats[0]
      loser_stats = game_stats[1]
      # assigns [muw_new, sigmaw_new] to squads[winner]
      squads[winner] = (Rankme::Ranker.calculate_mu_sigma(winner_stats, loser_stats))[0]

      # assigns [mul_new, sigmal_new] to squads[loser]
      squads[loser] = (Rankme::Ranker.calculate_mu_sigma(winner_stats, loser_stats))[1]

      [squads[winner], squads[loser]]
    end

    def update(winner, loser)
      update_stats(winner, loser)
      assign_mu_sigma(winner, loser)
    end

    #rank function in python code
    #calculates mu - 3 * sigma

    def estimated_skill(player)
      squads[player][0] - 3 * squads[player][1]
    end


    # squad --> map by estimated_skill function
    #sort and reverse

    def rate_me(matchups)
      matchups.each do |matchup|
        update(*matchup)
        @squads.keys.sort { |a,b| self.sorted_squads_reverse(a, b) }
      end
      @squads.keys.sort { |a,b| self.sorted_squads_reverse(a, b) }
    end

    def sorted_squads_reverse(a, b)
      estimated_skill(b) <=> estimated_skill(a)
    end

    def round
      girl1 = @girls.sample
      modified_array = @girls
      modified_array.delete(girl1)
      girl2 = modified_array.sample
      puts "Who is cuter, #{girl1} (1) or #{girl2} (2) ?"
      answer = gets.chomp
      if answer == '1'
        outcome = [girl1, girl2]
      else
        outcome = [girl2, girl1]
      end
      winner = outcome[0]
      loser = outcome[1]
      update(winner, loser)
      @games.push(outcome)
    end

    def play
      puts "ROUND #: #{@games.length + 1}"
    end

    def test_game
      puts "How many rounds would you like to play?"
      num_rounds = gets.chomp.to_i
      n = 0
      while n < num_rounds
        play
        round
        n += 1
      end
      winner = rate_me(@games)[0]
      loser = rate_me(@games)[1]
      winner_score = squads[winner]
      loser_score = squads[loser]
      puts rate_me(@games)
    end

    # open('rankings.txt','w').write('\n'.join(trueskill.rate(games)))

  end
end