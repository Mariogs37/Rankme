require 'spec_helper'

describe "basic rankme functions" do


  it "should return ~0.84 for erf(1)" do
    expect(Rankme::Stats.erf(1)).to be_within(0.01).of(0.84)
  end
  it "should return ~0.15 for pdf(1)" do
    expect(Rankme::Stats.pdf(1)).to be_within(0.01).of(0.15)
  end

  it "should return ~0.92 for cdf(PI ** 0.5)" do
    PI = Math::PI
    expect(Rankme::Stats.cdf(PI ** 0.5)).to be_within(0.01).of(0.92)
  end

  it "should return ~0.09 for vwin(0, -PI ** 0.5)" do
    expect(Rankme::Stats.vwin(0, -PI ** 0.5)).to be_within(0.01).of(0.09)
  end

  it "should return ~0.22 for wwin(0, -1)" do
    expect(Rankme::Stats.wwin(0, -1)).to be_within(0.01).of(0.22)
  end

  context "#get_remaining_players" do

    let(:a) { Rankme::Player.new(1) }
    let(:b) { Rankme::Player.new(2) }
    let(:c) { Rankme::Player.new(3) }
    let(:d) { Rankme::Player.new(4) }

    it "should not re-match played subjects" do
      game_subjects = [a.id, b.id, c.id, d.id]

      ranker = Rankme::Ranker.new(game_subjects)
      round_subjects = ranker.play(nil)
      ranker.play(round_subjects[0])
      ranker1 = ranker.current_match_up
      ranker2 = ranker.current_match_up.reverse

      [ranker1, ranker2].should include(ranker.get_remaining_player_ids)

    end
  end
end

describe "advanced rankme functions" do

  let(:calculate) { Rankme::Stats.calculate_mu_sigma(a, b) }
  let(:a) { Rankme::Player.new(1) }
  let(:b) { Rankme::Player.new(2) }
  let(:rankme) { Rankme::Ranker.new }

  it "should return 0 for new player" do
    a.score.estimated_skill.should == 0
  end

  describe "new players" do
    before (:each) do
      a.score.mu = 1
      a.score.sigma = 1
      b.score.mu = 1
      b.score.sigma = 1
    end

    describe "calculate mu sigma function" do

      it "should return ~1.13 for arr[0][0]" do
        expect(calculate[0].score.mu).to be_within(0.01).of(1.13)
      end
      it "should return ~0.99 for arr[0][1]" do
        expect(calculate[0].score.sigma).to be_within(0.01).of(0.99)
      end
      it "should return ~0.87 for arr[1][0]" do
        expect(calculate[1].score.mu).to be_within(0.01).of(0.87)
      end
      it "should return ~0.99 for arr[1][1]" do
        expect(calculate[1].score.sigma).to be_within(0.01).of(0.99)
      end
    end
  end

  describe "update stats function" do

    it "should set new player mu to 25 and sigma to 25/3" do
      a.score.mu.should == 25
      a.score.sigma.should == 25.0/3
    end
  end

  describe "stock players" do

    let(:a) { Rankme::Player.new(1) }
    let(:b) { Rankme::Player.new(2) }
    let(:c) { Rankme::Player.new(3) }
    let(:d) { Rankme::Player.new(4) }
    let(:e) { Rankme::Player.new(5) }

    describe "rate me function" do

      it "should return 185 for a's score" do
        a.score.mu = 200
        a.score.sigma = 5
        a.score.estimated_skill.should == 185
      end

      it "should sort players by estimated skill" do
        a.score.mu = 200
        b.score.mu = 200
        c.score.mu = 200
        d.score.mu = 200
        e.score.mu = 200
        a.score.sigma = 5
        b.score.sigma = 4
        c.score.sigma = 3
        d.score.sigma = 2
        e.score.sigma = 1
        ranker = Rankme::Ranker.new
        ranker.played = [a, b, c, d, e]
        test_results = ranker.results
        test_results.should == [e.id, d.id, c.id, b.id, a.id]
      end

    end

    describe "skip function" do
      it "current matchup should include E" do

        ranker = Rankme::Ranker.new([a.id, b.id])

        ranker.start()

        ranker.add_player(c.id)

        round = ranker.play(a.id)

        puts "Round is " + round.to_s

        round.should include(c.id)

        ranker.add_player(d.id)

        round = ranker.skip_match

        round = ranker.play(c.id)


      end
    end
  end
end