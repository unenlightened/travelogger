class Trip < ApplicationRecord
  belongs_to :user
  has_many :trip_categories
  has_many :purposes, through: :trip_categories
  has_many :entries
  has_many :locations, as: :place
  accepts_nested_attributes_for :locations, :allow_destroy => true, reject_if: proc {|attributes| attributes['name'].blank?}

  validates :name, presence: true
  validates :start_date, presence: true
  validate :end_date_not_before_start_date

  

  def end_date_not_before_start_date
    if start_date.present? && end_date.present? && start_date > end_date
      errors.add(:end_date, "can't be before the start date")
    end
  end

end
