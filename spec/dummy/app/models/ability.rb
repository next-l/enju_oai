class Ability
  include CanCan::Ability

  def initialize(user, ip_address = nil)
    case user.try(:role).try(:name)
    when 'Administrator'
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        if defined?(EnjuCirculation)
          manifestation.items.empty? and !manifestation.periodical_master? and !manifestation.is_reserved?
        else
          manifestation.items.empty? and !manifestation.periodical_master?
        end
      end
    when 'Librarian'
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        false
      end
    when 'User'
      can :read, Manifestation do |manifestation|
        manifestation.required_role_id <= 2
      end
      can :edit, Manifestation
    else
      can :read, Manifestation
    end
  end
end
