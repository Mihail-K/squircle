require 'rails_helper'

RSpec.describe User, type: :model do
  let :user do
    build :user
  end

  it_behaves_like ApplicationRecord

  it 'has a valid factory' do
    expect(user).to be_valid
  end

  it 'is not valid without an email' do
    user.email = nil
    expect(user).not_to be_valid
  end

  it 'is not valid if the email is already taken' do
    create :user, email: user.email
    expect(user).not_to be_valid
  end

  it 'is not valid without a display name' do
    user.display_name = nil
    expect(user).not_to be_valid
  end

  it 'is not valid if the display name is already taken' do
    create :user, display_name: user.display_name
    expect(user).not_to be_valid
  end

  it 'is not valid without a date of birth' do
    user.date_of_birth = nil
    expect(user).not_to be_valid
  end

  it 'is not valid if the date of birth is in the future' do
    user.date_of_birth = Faker::Date.forward 1
    expect(user).not_to be_valid
  end

  it 'is not valid if the date is more than 100 years in the past' do
    user.date_of_birth = 100.years.ago
    expect(user).not_to be_valid
  end

  it 'generates an email token on creation' do
    user.save
    expect(user.email_token).to be_present
  end

  it 'generates a new email token whenever the email is changed' do
    user.save
    old_token = user.email_token

    user.update email: Faker::Internet.email
    expect(user.email_token).not_to eq old_token
  end

  describe 'with bans' do
    let :user do
      create :user, :with_bans
    end

    it 'has a valid factory' do
      expect(user).to be_valid
      expect(user.bans).not_to be_empty
    end

    it 'marks the user as banned' do
      expect(user.banned?).to be true
      expect(User.banned.exists?(id: user)).to be true
    end

    it 'is ready to be unbanned when no active bans are present' do
      user.bans.update_all expires_at: 1.day.ago
      expect(User.banned.no_active_bans.exists?(id: user)).to be true
    end

    it 'is unbanned by the unban-job once all bans are expired' do
      UnbanJob.perform
      expect(user.reload.banned?).to be true

      user.bans.update_all expires_at: 1.day.ago
      UnbanJob.perform
      expect(user.reload.banned?).to be false
    end
  end

  describe '.most_active' do
    let :user do
      create :user, :with_posts
    end

    it 'includes users that have visible posts' do
      expect(User.most_active.exists?(id: user)).to be true
    end

    it 'does not includes users that have no visible posts' do
      user.posts.each { |post| post.update(deleted: true, deleted_by: user) }
      expect(User.most_active.exists?(id: user)).to be false
    end

    it 'does not include banned users' do
      user.roles << Role.find_by!(name: 'banned')
      expect(User.most_active.exists?(id: user)).to be false
    end
  end

  describe '.can?' do
    let :user do
      create :user
    end

    let :permission do
      user.permissions.first
    end

    it 'is true if the user has permission' do
      expect(user.can?(permission.name)).to be true
    end

    it 'is false if the user does not have permission' do
      expect(user.can?(create(:permission).name)).to be false
    end

    it 'is true if the permission is implied' do
      child_permission = create(:permission, implied_by: permission)
      expect(user.can?(child_permission.name)).to be true
    end
  end
end
