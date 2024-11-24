class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.approved? || author? || admin?
  end

  def create?
    !!user
  end

  def update?
    author? || admin?
  end

  def destroy?
    author? && record.draft?
  end

  def submit_to_review?
    author? && record.draft?
  end

  def approve?
    admin? && record.under_review?
  end

  alias_method :reject?, :approve?

  private

  def author?
    user&.id == record.user_id
  end

  def admin?
    user&.admin?
  end
end
