FactoryGirl.define do
  factory :user do
    transient do
      build_group true
    end

    hash_func 'bcrypt'
    sequence(:email) {|n| "example#{n}@example.com"}
    password 'password'
    encrypted_password { User.new.send(:password_digest, 'password') }
    sequence(:display_name) { |n| "New User #{n}" }
    credited_name 'Dr User'
    activated_state :active
    sequence(:login) { |n| "new_user_#{n}" }
    global_email_communication true
    project_email_communication true
    admin false
    banned false


    after(:build) do |u, env|
      if env.build_group
        u.identity_group = build(:user_group, name: u.login)
        u.identity_membership = build(:membership, user: u, user_group: u.identity_group, state: 0, identity: true, roles: ["group_admin"])
      end
    end

    factory :insecure_user do
      hash_func 'sha1'
      password 'tajikistan'
      encrypted_password 'gFlanK5bXjD2YS7LSYndVJNGGdY='
      password_salt 'nK5bXjD2YS7LSYndVJNGGdY='
    end

    factory :project_owner do
      after(:create) do |user|
        user.projects.concat(create_list(:project, 2))
        user.save!
      end
    end

    factory :user_group_member do
      after(:create) do |user|
        create_list(:membership, 1, user: user)
      end
    end

    factory :user_with_collections do
      after(:create) do |user|
        user.collections.concat(create_list(:collection, 2))
        user.save!
      end
    end

    factory :inactive_user do
      activated_state :inactive
      display_name 'deleted_user'
      email 'deleted_user@zooniverse.org'
      login '1234567890'
    end

    factory :user_with_languages do
      languages ['en', 'es', 'fr-ca']
    end

    factory :admin_user do
      admin true
    end
  end

  factory :omniauth_user, class: :user do
    sequence(:login) { |n| "new_user_#{n}" }
    sequence(:email) {|n| "example#{n}@example.com"}
    password 'password'
    display_name 'New User'
    credited_name 'Dr New User'
    activated_state :active
    languages ['en', 'es', 'fr-ca']

    after(:build) do |u|
      u.identity_group = build(:user_group, name: u.login)
      u.identity_membership = build(:membership, user: u, user_group: u.identity_group, state: 0, identity: true, roles: ["group_admin"])
      create_list(:authorization, 1, user: u, provider: 'facebook', uid: '12345')
    end
  end
end
