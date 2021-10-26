module RolesHelper
  ROLES = %w[
    administrator
    approved
    basic
    moderator
    validator
    unconfirmed
  ].freeze

  ROLE_CHECKS = [
    [->(user) { user.administrator? }, "Admin"],
    [->(user) { user.validator? }, "Validator"],
    [->(user) { user.moderator? }, "Moderator"],
    [->(user) { user.approved? }, "Approved"],
    [->(user) { !user.confirmed? }, "Unconfirmed"]
  ].freeze

  def find_roles(user)
    roles = ROLE_CHECKS.map do |(check, label)|
      next unless check.call(user)

      label
    end.compact

    roles.push("Basic") if roles.empty?
    roles.join(", ")
  end
end
