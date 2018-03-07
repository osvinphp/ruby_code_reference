class CurrentEvent < ApplicationRecord
    include Blockfunc::BlockUser

    belongs_to :event_category
    belongs_to :user, optional: true
    has_many :donations, class_name: "Donation", foreign_key: :event_id
    has_many :post_events, foreign_key: :event_id

    #event's stories
    has_many :stories, as: :storyable, dependent: :destroy

    #event's hosts
    has_many :hosts, class_name: 'Host', foreign_key: 'event_id', dependent: :destroy

    #reports abuse
    has_many :reports, as: :reportable, dependent: :destroy
end
