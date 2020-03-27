if Rails.env.production? || Rails.env.staging?
	ActionMailer::Base.smtp_settings = {
    :address              => ENV['APPLICATION_EMAIL_SMTP_ADDRESS'],
    :port                 => 587,
    :domain               => ENV['APPLICATION_EMAIL_DOMAIN'],
    :user_name            => ENV['APPLICATION_EMAIL_SMTP_AUTH_USER'],
    :password             => ENV['APPLICATION_EMAIL_SMTP_AUTH_PASSWORD'],
		:authentication       => 'plain',
		:enable_starttls_auto => true
	}
end
