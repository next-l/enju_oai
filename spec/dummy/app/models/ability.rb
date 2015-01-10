class Ability
  include CanCan::Ability

  def initialize(user)
    case user.try(:role).try(:name)
    when 'Administrator'
      can [:read, :create, :update], Manifestation
    when 'Librarian'
      can [:read, :create, :update], Manifestation
    when 'User'
      can :read, Manifestation do |manifestation|
        manifestation.required_role_id <= 2
      end
    else
      can :read, Manifestation
    end
  end
end
