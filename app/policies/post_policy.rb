class PostPolicy < ApplicationPolicy
  def index?
    true
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

  def approve?
    user&.admin? && record.under_review?
  end

  alias_method :reject?, :approve?
end
