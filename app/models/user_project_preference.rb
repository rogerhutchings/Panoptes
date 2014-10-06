class UserProjectPreference < ActiveRecord::Base
  extend ControlControl::Resource
  include RoleControl::Adminable
  include RoleControl::RoleModel
  
  belongs_to :user, dependent: :destroy
  belongs_to :project, dependent: :destroy

  attr_accessible :roles, :preferences, :email_communication

  roles_for :user, :project, valid_roles: [:collaborator,
                                           :translator,
                                           :tester,
                                           :scientist,
                                           :moderator]

  validates_presence_of :user, :project

  can :update, :allowed_to_change?
  can :destroy, :allowed_to_change?
  can :show, :allowed_to_change?

  def self.visible_to(actor, as_admin: false)
    UserProjectPreferenceVisibilityQuery.new(actor, self).build(as_admin)
  end

  def self.can_create?(actor)
    !!actor
  end

  def allowed_to_change?(actor)
    actor.user == user || actor.owns?(project)
  end
end
