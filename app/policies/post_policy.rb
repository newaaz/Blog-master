class PostPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    true
  end

  def create?
    !!user
  end

  def destroy?
    record.user == user && record.draft?
  end

  def submit_to_review?
    !!user && record.draft?
  end

  def accept?
    can_changed_from_review?
  end

  alias_method :reject?, :accept?

  private

  def can_changed_from_review?
    user&.admin? && record.under_review?
  end
end
