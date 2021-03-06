class Trip < ApplicationRecord
  belongs_to :user
  has_many :trip_categories
  has_many :categories, through: :trip_categories
  has_many :entries
  has_many :locations, as: :place

  accepts_nested_attributes_for :locations, :allow_destroy => true
  accepts_nested_attributes_for :categories

  validates :name, presence: true
  validate :has_location?
  validates :locations, presence: true
  validates :start_date, presence: true
  validate :end_date_not_before_start_date
  validates :categories, presence: { message: 'need to be chosen'}
  
  before_save :reject_blank_locations!
    # Use this instead of "reject_if: proc {|attributes| attributes['name'].blank?}" or "reject_if: :all_blank" to be able to create multiple blank fields for form input. Otherwise, user has to fill field, then add one by one
  # before_save :add_other_to_custom_category!

  #VALIDATIONS / INIT
  
  def has_location?
    named_locations = locations.count { |location| location.name.present? }
    if named_locations == 0
      errors.add(:locations, "can't be blank")
    end
  end

  def reject_blank_locations!
    locations.each do |location|
      location.destroy if location.name.blank?
    end
  end

  def end_date_not_before_start_date
    if start_date.present? && end_date.present? && start_date > end_date
      errors.add(:end_date, "can't be before the start date")
    end
  end

  def categories_attributes=(category_attributes)
    category_attributes.values.each do |category_attribute|
      category = Category.find_or_create_by(category_attribute)
      self.categories << category if self.categories.none?{|cat| cat == category } && category.name.present?
    end
  end

  #SCOPE


  scope :by_order, -> (order) { order(created_at: order) }
  scope :by_user, -> (user_id) { where(user: user_id) }
  scope :by_category, -> (category_name) { joins(:categories).where('categories.name' => category_name) }

  # examples used to build out a fancy scope
    # succ = ->(x) { x + 1 }
    # succ = lambda { |x| x + 1 }

    # Student.joins(:schools).where(schools: { category: 'public' })
    # Student.joins(:schools).where('schools.category' => 'public' )

  #CUSTOM

  def self.filtered_by(order: 'desc', user:  nil, category: nil)
    return by_order(order).by_user(user).by_category(category).distinct if user && category 
    return by_order(order).by_user(user).distinct if user 
    return by_order(order).by_category(category).distinct if category

    by_order(order)
  end
  
end
