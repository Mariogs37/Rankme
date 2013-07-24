class Player
  attr_accessor :score, :id

  def initialize(id, score=Score.new())
    @id = id
    @score = score
  end
end