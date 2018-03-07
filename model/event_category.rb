class EventCategory < ApplicationRecord
	mount_uploader :image, EventImageUploader

	has_many :flyers, dependent: :destroy
	has_many :sub_categories, dependent: :destroy
	
	accepts_nested_attributes_for :sub_categories, reject_if: proc { |attributes| attributes[:name].blank? }
end
