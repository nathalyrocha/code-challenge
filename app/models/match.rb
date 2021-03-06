class Match < ApplicationRecord
  has_many :scores
  has_many :players, through: :scores
  has_many :frags
  has_many :deaths

  validates :match_id, :start_date, presence: true
  validates :match_id, uniqueness: true

  def ranking
    players.includes(:deaths, :frags).uniq.map do |player|
      {
        name: player.name,
        frags: player.frags_per_match(id).size,
        deaths: player.deaths_per_match(id).size,
        favorite_gun: player.favorite_gun(id)&.name,
        award: player.deaths_per_match(id).empty?,
        award_five_kills: FiveKillsStreak.new(player, id).award
      }
    end.sort_by { |data| data[:frags] }.reverse
  end
end
