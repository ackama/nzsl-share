# frozen_string_literal: true

AdminPolicy = Struct.new(:user, :admin) do
  def index?
    user.administrator
  end
end
