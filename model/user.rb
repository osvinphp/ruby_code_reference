class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
   #before_save :ensure_authentication_token
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable
  
  acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitute,
                   :lng_column_name => :longitute

  validate :password_complexity
  has_one :channel, dependent: :destroy
  has_many :current_events, dependent: :destroy
  has_many :causes
  has_one :intro_video, dependent: :destroy
  has_many :stories, as: :storyable, dependent: :destroy

  ##OMIT
  # has_many :friends
  # has_many :friend_stories

  has_many :seens, dependent: :destroy
  has_many :post_events, dependent: :destroy

  #begin: follow unfollow associations
  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following
  #end: follow unfollow associations

  #blocked users
  has_many :blocks, dependent: :destroy

  #blocked posts
  has_many :post_blocks, dependent: :destroy

  #follow stories
  has_many :follow_stories

  #notification
  has_many :notifications, class_name: 'Notification', foreign_key: 'user_id', dependent: :destroy

  #hosts 
  has_many :hosts, dependent: :destroy

  #reports abuse
  has_many :reports, as: :reportable, dependent: :destroy

  #claim event
  has_many :claims, dependent: :destroy

  #begin: follow & unfollow
  def follow(user_id, follow_status)
    following_relationships.create(following_id: user_id, follow_status: follow_status)
  end

  def unfollow(user_id)
    fs =  following_relationships.find_by(following_id: user_id)
    p "#{fs}============================================unfollow"
    fs.destroy
  end

  def confirm_request(user_id)
    follower_relationships.find_by(follower_id: user_id).update(follow_status: 2)
  end
  #end: follow & unfollow


  #OMIT
  # def friends
  #   Friend.where("(user_id in (?) OR friend_id in (?)) AND status = ?", self.id, self.id, 1)
  # end

  #OMIT
  # def friend_stories
  #   friend_stories_arr = []
  #   friend_ids = self.friends.pluck(:user_id, :friend_id).flatten.uniq.reject!{|x| x==self.id}
  #   User.where(id: friend_ids).order('created_at desc').includes(:stories=> [:seens]).select do |x| friend_stories_arr << (x.as_json(only: [:fullname, :image, :id]).merge!(
  #                                     stories: x.stories.map do 
  #                                       |y| y.as_json.merge!(seenCount: y.seens.size, 
  #                                                           seenByMe: y.seens.collect(&:user_id).include?(self.id)
  #                                                           ) #stories merge bracket
  #                                     end #stories loop bracket
  #                                   )
  #                               ) if x.stories.present? #push bracket
  #   end #users loop bracket
  #   friend_stories_arr
  # end

  def follow_stories
    follow_stories_arr = []
    following_users_ids = self.following_relationships.where(follow_status: 2).pluck(:following_id)
    User.where(id: following_users_ids).order('created_at desc').includes(:stories=> [:seens]).select do |x| follow_stories_arr << (x.as_json(only: [:fullname, :image, :id]).merge!(
                                      stories: x.stories.map do 
                                        |y| y.as_json.merge!(seenCount: y.seens.size, 
                                                            seenByMe: y.seens.collect(&:user_id).include?(self.id)
                                                            ) #stories merge bracket
                                      end #stories loop bracket
                                    )
                                ) if x.stories.present? #push bracket
    end #users loop bracket
    follow_stories_arr
  end
  
  
  def password_complexity
    if password.present? and not password.match('^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&#]).{8,}')
      errors.add :password, "must include at least one lowercase letter, one uppercase letter,one Special Character and one digit"
    end
  end
  # validates :authentication_token, uniqueness: true
  def self.save_img(upload)
      uploader = ImageUploader.new
      uploader.store!(upload)
      filepath = Rails.application.secrets.image_link
      return filepath + uploader.url
	end

  def giver_fun
    puts "Hello It's me!"
    sleep(30)
    giver_fun
  end

  def self.genrate_access_token
    return SecureRandom.hex(3)
  end


  def self.unverified_email
    t=Time.now.in_time_zone('Eastern Time (US & Canada)')
    @user = User.where("email_verify_date < ? OR email_verify_date is NULL",t).where(email_verified_flag: 0).where(admin_flag: 0)
    if @user.present?
      @user.destroy_all
      Rails.logger.info "destroy"
    else
      Rails.logger.info "undestroy"
    end
  end
end
