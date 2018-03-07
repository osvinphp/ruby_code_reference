class Api::V1::ClaimsController < Api::V1::BaseController

	def create
		event_claim = current_user.claims.create(claim_params)
		if event_claim.present?
			Thread.new{
				ClaimMailer.send_claim_request(event_claim).deliver_now
			}
			render json: {message: 'Your request has been under processed, you will receive a notification when your request has been approved by admin.', responseCode: 1}, status: 200
		else
			render json: {message: 'Please try again!', responseCode: 0}, status: 200
		end
	end

	private
	def claim_params
		{
			address: params[:address],
			phone_no: params[:phone_no],
			business_name: params[:business_name],
			email: params[:email],
			event_id: params[:event_id],
			designation_of_location: params[:designation_of_location]
		}
	end
end
