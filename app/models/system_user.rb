class SystemUser
  class << self
    def find
      User.where(username: "nzsl.share").first_or_initialize do |user|
        # We do not want the system user to be log-in-able.
        # This means no email or password.
        user.save(validate: false)
      end
    end
  end
end
