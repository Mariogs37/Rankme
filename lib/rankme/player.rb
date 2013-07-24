module Rankme
  class Player
    attr_accessor :score, :id

    def initialize(id)
      @id = id
      @score = Score.new()
    end
  end
end