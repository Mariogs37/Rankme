module Rankme
  module Stats
    # Modules (Math for access to E)
    include Math

    extend self

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

    def calculate_mu_sigma(winner, loser)
      muw = winner.score.mu
      sigmaw = winner.score.sigma

      mul = loser.score.mu
      sigmal = loser.score.sigma

      c = (2 * BETA ** 2 + sigmaw ** 2 + sigmal ** 2) ** 0.5
      t = (muw - mul) / c
      e = EPSILON / c
      sigmaw_new = (sigmaw ** 2 * (1 - (sigmaw ** 2) / (c ** 2) * wwin(t, e)) + GAMMA ** 2) ** 0.5
      sigmal_new = (sigmal ** 2 * (1 - (sigmal ** 2) / (c ** 2) * wwin(t, e)) + GAMMA ** 2) ** 0.5
      muw_new = (muw + sigmaw ** 2 / c * vwin(t, e))
      mul_new = (mul - sigmal ** 2 / c * vwin(t, e))

      winner.score.mu = muw_new
      winner.score.sigma = sigmaw_new
      winner.count += 1


      loser.score.mu = mul_new
      loser.score.sigma = sigmal_new
      loser.count += 1


      [winner, loser]

    end
  end
end