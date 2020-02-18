class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAIL_FROM"]
  layout "mailer"

  def admins
    User.where(administrator: true).map(&:email)
  end

  def nzsl_text_signature
    "Kind regards\n\n" \
    "NZSL Share Team\n\n" \
    "NZSL Share: https://nzslshare.nz\n" \
    "NZSL Online Dictionary: https://nzsl.nz\n" \
    "Learn NZSL: http://www.learnnzsl.nz\n" \
    "Email: DSRU@vuw.ac.nz"
  end
end
