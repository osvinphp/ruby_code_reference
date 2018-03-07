class Api::V1::RelationshipsController < Api::V1::BaseController
  before_action :activated_user, only: [:follow_unfollow_list, :follow_request_list, :block_user]
  #follower and following list: 0 denotes followers, 1 denotes followings
  def follow_unfollow_list
    user = User.find_by(id: params[:user_id])
    if params[:list_status].eql?('0')
      users_ids = user.follower_relationships.where(follow_status: 2).pluck(:follower_id)
      list = User.where(id: users_ids).paginate(page: params[:page], per_page: params[:per_page])
    else
      list = user.following.paginate(page: params[:page], per_page: params[:per_page])
    end
    render json: {message: 'List has been fetched successfully.', user: list, responseCode: 1},status: 200
  end

  #follow request
  def follow_request_list
    user_ids = @current_user.follower_relationships.where(follow_status: 1).pluck(:follower_id)
    user_detail = User.where(id: user_ids).as_json(only: [:id, :fullname, :image])
    render json: {message: 'Your request list has been fetched successfully.', user: user_detail, responseCode: 1},status: 200
  end

  # 2: block users list, 0: block, 1: unblock
  def block_user 
    if params[:block].eql?("0")
      current_user.blocks.find_or_create_by(block_user_id: params[:block_user_id])
      if current_user.following_relationships.pluck(:following_id).include?(params[:block_user_id].to_i)
        current_user.unfollow params[:block_user_id] 
      end
      return render json: {message: 'User has been blocked successfully', responseCode: 1},status: 200
    elsif params[:block].eql?("1")
      current_user.blocks.find_by(block_user_id: params[:block_user_id]).destroy
      return render json: {message: 'User has been unblocked successfully', responseCode: 1},status: 200
    elsif params[:block].eql?("2")
      blocked_users_ids = current_user.blocks.pluck(:block_user_id)
      users = User.where(id: blocked_users_ids).as_json(only: [:id, :fullname, :image])
      return render json: {message: 'Blocked users has been fetched successfully', user: users, responseCode: 1},status: 200
    else
      return render json: {message: 'Please try again!', responseCode: 0},status: 200
    end
  end
end

