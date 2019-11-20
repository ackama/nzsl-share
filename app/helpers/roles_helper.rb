module RolesHelper
  def find_roles(user)
    roles = []
    user.administrator? && roles.push("Admin")
    user.validator? && roles.push("Validator")
    user.moderator? && roles.push("Moderator")
    user.approved? && roles.push("Approved")
    roles.empty? && roles.push("Basic")
    roles.join(", ")
  end
end
