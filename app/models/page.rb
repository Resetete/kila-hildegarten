class Page < ApplicationRecord
  has_many :contents # one page type can have several

  PAGE_TYPES = %w[home contact team parents]
end
