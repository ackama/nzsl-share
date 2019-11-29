# frozen_string_literal: true

AdminPolicy = Struct.new(:user, :admin) do
  def administrator_or_moderator?
    user.administrator? || user.moderator?
  end
end
