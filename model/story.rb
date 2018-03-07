class Story < ApplicationRecord
	belongs_to :storyable, polymorphic: true
	has_many :seens, dependent: :destroy
	belongs_to :user, class_name: "User", foreign_key: 'user_id', optional: true
end
