class ApplicationPolicy
  attr_reader :user, :record
  delegate :administrator?, :validator?, :approved?, :moderator?, to: :user, allow_nil: true

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    administrator?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
