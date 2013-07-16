require "rankme/version"

module Rankme

# Modules (Math for access to E)

  include Math

# Constants

  E = Math::E
  PI = Math::PI
  BETA = 25 / 6
  GAMMA = 25 / 300
  EPSILON = 0.08
  A1 =  0.254829592
  A2 = -0.284496736
  A3 =  1.421413741
  A4 = -1.453152027
  A5 =  1.061405429
  P  =  0.3275911

# Global Variables

  games = [
      ["PK", "SF"], ["RT", "XT"], ["ACE", "BS"], ["SRM", "GB"], #day 1
      ["SysX", "XT"], ["PK", "RT"], ["SF", "GB"], ["SRM", "BS"], #day 2
      ["SysX", "GB"], ["RT", "BS"], ["SF", "SRM"], ["XT", "ACE"], #day 3
      ["SysX", "PK"], ["RT", "SF"], ["XT", "BS"], ["GB", "SRM"], #day 4
      ["SysX", "RT"], ["PK", "ACE"], ["XT", "SF"], ["BS", "GB"], #day 5
      ["SysX", "SF"], ["RT", "GB"], ["XT", "PK"], ["ACE", "SRM"], #day 6
      ["SysX", "ACE"], ["RT", "SF"], ["XT", "PK"], ["BS", "SRM"], #day 7
      ["SysX", "BS"], ["PK", "GB"], ["RT", "SRM"], ["ACE", "SF"], #day 8
      ["SysX", "RT"], ["PK", "SRM"], ["XT", "SF"], ["BS", "ACE"], #day 9
      ["PK", "SF"], ["XT", "SysX"], ["SRM", "ACE"], ["BS", "GB"], #day 10
      ["SysX", "SF"], ["PK", "RT"], ["XT", "SRM"], ["ACE", "GB"], #day 11
      ["SysX", "SRM"], ["PK", "BS"], ["RT", "ACE"], ["XT", "GB"], #day 12
      ["SysX", "PK"], ["RT", "XT"], ["BS", "ACE"], ["GB", "ACE"], #day 13
  ]

  squads = {}

# Functions: erf, pdf, cdf, vwin, wwin

  def erf(x)
    # save the sign of x
    sign = 1
    if x < 0
      sign = -1
      x = x.abs
      # A&S formula 7.1.26
      t = 1.0 / (1.0 + P * x)
      y = 1.0 - (((( (A5 * t + A4) * t) + A3) * t + A2) * t + A1) * t * (-x ** x)
      sign * y
    end
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

  def calculate_mu_sigma(winner, loser)
    muw = sigmaw = winner
    mul = sigmal = loser
    c = (2 * BETA ** 2 + sigmaw ** 2 + sigmal ** 2) ** 0.5
    t = (muw - mul) / c
    e = EPSILON / c

    sigmaw_new = (sigmaw ** 2 * (1 - (sigmaw ** 2) / (c ** 2) * wwin(t, e)) + GAMMA ** 2) ** 0.5
    sigmal_new = (sigmal ** 2 * (1 - (sigmal ** 2) / (c ** 2) * wwin(t, e)) + GAMMA ** 2) ** 0.5
    muw_new = (muw + sigmaw ** 2 / c * vwin(t, e))
    mul_new = (mul - sigmal ** 2 / c * vwin(t, e))

    winner = [muw_new, sigmaw_new]
    loser = [mul_new, sigmal_new]

    winner_loser = [winner, loser]

  end

  def update(winner, loser)
    winner_stats = squads[winner].present? ? squads[winner] : [25, 25/3]
    loser_stats = squads[loser].present? ? squads[loser] : [25, 25/3]

    # assigns [muw_new, sigmaw_new] to squads[winner]
    squads[winner] = calculate_mu_sigma(winner_stats, loser_stats)[0]

    # assigns [mul_new, sigmal_new] to squads[loser]
    squads[loser] = calculate_mu_sigma(winner_stats, loser_stats)[1]

    [winner, loser]
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
      squads.sort { |a,b| sorted_squads_reverse(a, b) }
      squads.each do |squad|
        mu = squads[squad][0]
        sigma = squads[squad][1]
        squads.sort { |a,b| sorted_squads_reverse(a, b) }
      end
    end
  end

  private

  def sorted_squads_reverse(a, b)
    estimated_skill(b) <=> estimated_skill(a)
  end
end