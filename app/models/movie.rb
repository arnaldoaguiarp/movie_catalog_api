class Movie < ApplicationRecord
  self.primary_key = 'id'

  validates :title, presence: true
  validates :year, presence: true, numericality: { only_integer: true }
  validates :title,
            uniqueness: { scope: :year, message: 'The movie has already been registered for the specified year.' }
  validate :published_at_is_valid_date

  private

  def published_at_is_valid_date
    return if published_at.nil?

    # Try converting to a valid date
    begin
      Date.parse(published_at.to_s)
    rescue ArgumentError
      errors.add(:published_at, 'is not a valid date')
    end
  end
end
