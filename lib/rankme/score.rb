class Score
  attr_accessor :mu, :sigma

  DEFAULT_MU = 25.0
  DEFAULT_SIGMA = DEFAULT_MU / 3

  def initialize(mu=DEFAULT_MU, sigma=DEFAULT_SIGMA)
    @mu = mu
    @sigma = sigma
  end

  def estimated_skill
    mu - 3 * sigma
  end

  private

  def default_sigma(mu)
    mu / 3
  end
end