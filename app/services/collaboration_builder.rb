class CollaborationBuilder
  def initialize(scope, params)
    @scope = scope
    @params = params
    @identifier = params[:identifier]
  end

  def build
    @scope.build(@params.merge(collaborator: collaborator || invite_user))
  end

  private

  def collaborator
    if email?
      User.find_by(email: @identifier)
    else
      User.find_by(username: @identifier)
    end
  end

  def invite_user
    return unless email?

    User.invite!(email: @identifier, username: @identifier[/[^@]+/])
  end

  def email?
    Devise.email_regexp.match?(@identifier)
  end
end
