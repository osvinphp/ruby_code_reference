class Api::V1::ReportsController < Api::V1::BaseController
	before_action :activated_user, only: [:abuse]

	#reports : users, posts, events
	def abuse

		user = User.find_by(id: params[:user_id])
		msg = report_abuse(user, params[:content])
		Thread.new{
			ReportMailer.send_report_user(current_user, user.reportable).deliver_now
		}
		render json: {message: msg, responseCode: 1}, status: 200
	end

	def report_abuse(reported_for, content)
		report = reported_for.reports.find_by(user_id: current_user.id)
		Thread.new{
			ClaimMailer.send_report_mailer(event_claim).deliver_now
		}
		if report.present?
			msg = 'You have already reported for this.'
		else
			reported_for.reports.create(user_id: current_user.id, content: content)
			msg = 'Your request has been recieved.'
		end
		return msg
	end
end
