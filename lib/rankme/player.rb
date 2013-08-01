module Rankme
  class Player
    attr_accessor :score, :id , :count

    def initialize(id)
      @id = id
      @score = Score.new()
      @count = 0
    end
  end
end