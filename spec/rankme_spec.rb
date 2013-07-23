require 'spec_helper'

describe "basic rankme functions" do

  let(:rankme) { Rankme::Ranker.new }

  it "should return ~0.84 for erf(1)" do
    expect(Rankme::Ranker.erf(1)).to be_within(0.01).of(0.84)
  end
  it "should return ~0.15 for pdf(1)" do
    expect(Rankme::Ranker.pdf(1)).to be_within(0.01).of(0.15)
  end

  it "should return ~0.92 for cdf(PI ** 0.5)" do
    PI = Math::PI
    expect(Rankme::Ranker.cdf(PI ** 0.5)).to be_within(0.01).of(0.92)
  end

  it "should return ~0.09 for vwin(0, -PI ** 0.5)" do
    expect(Rankme::Ranker.vwin(0, -PI ** 0.5)).to be_within(0.01).of(0.09)
  end

  it "should return ~0.22 for wwin(0, -1)" do
    expect(Rankme::Ranker.wwin(0, -1)).to be_within(0.01).of(0.22)
  end
end

describe "advanced rankme functions" do

  let(:rankme) { Rankme::Ranker.new }
  it "should return 0 for estimated_skill('ben')" do
    rankme.squads['ben'] = [25, 25/3.0]
    rankme.estimated_skill('ben').should == 0
  end

  describe "calculate mu sigma function" do
    let(:arr) { Rankme::Ranker.calculate_mu_sigma([1,1], [1,1]) }

    it "should return ~1.13 for arr[0][0]" do
      expect(arr[0][0]).to be_within(0.01).of(1.13)
    end
    it "should return ~0.99 for arr[0][1]" do
      expect(arr[0][1]).to be_within(0.01).of(0.99)
    end
    it "should return ~0.87 for arr[1][0]" do
      expect(arr[1][0]).to be_within(0.01).of(0.87)
    end
    it "should return ~0.99 for arr[1][1]" do
      expect(arr[1][1]).to be_within(0.01).of(0.99)
    end
  end

  describe "update stats function" do
    it "should set winner_stats = [25, 25.0/3] if squads[winner].nil?" do
      rankme.update_stats('ben', 'sam')[0].should == [25, 25.0/3]
    end

    it "should set loser_stats = [25, 25.0/3] if squads[loser].nil?" do
      rankme.update_stats('ben', 'sam')[1].should == [25, 25.0/3]
    end

  end

  describe "assign_mu_sigma function for new player" do
    it "should set updated mu value for winner to ~29.22" do
      rankme.assign_mu_sigma('ben', 'sam')[0][0].should be_within(0.01).of(29.22)
    end

    it "should set updated sigma value for winner to ~7.19" do
      rankme.assign_mu_sigma('ben', 'sam')[0][1].should be_within(0.01).of(7.19)
    end

    it "should set updated mu value for loser to ~20.78" do
      rankme.assign_mu_sigma('ben', 'sam')[1][0].should be_within(0.01).of(20.78)
    end

    it "should set updated sigma value for loser to ~7.19" do
      rankme.assign_mu_sigma('ben', 'sam')[1][1].should be_within(0.01).of(7.19)
    end
  end

  describe "rate me function" do
    let(:rankme) { Rankme::Ranker.new }


    it "should return 185 for Ben's estimated skill" do
      rankme.squads = {"Ben" => [200, 5], "Evan" => [100, 20], "Warren" => [400, 5], "Andy" => [1, 1]}
      rankme.estimated_skill("Ben").should == 185
    end

    it "should sort players by estimated skill" do
      player_matchups = [["Warren", "Ben"], ["Ben", "Evan"], ["Warren", "Evan"], ["Evan", "Andy"]]
      rankme.rate_me(player_matchups).should == ["Warren", "Ben", "Evan", "Andy"]
    end

  end
end