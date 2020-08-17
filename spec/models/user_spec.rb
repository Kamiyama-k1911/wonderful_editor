# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  image                  :string
#  name                   :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  context "正しいデータを入力した時" do
    it "データ登録に成功する" do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  context "名前が空のデータを入力した時" do
    fit "データ登録に失敗する" do

      binding.pry

      user = build(:user, name: nil)

      expect(user).to be_invalid
      expect(user.errors.details[:name][0][:error]).to eq :blank
    end
  end

  context "メールアドレスが空のデータを入力した時" do
    it "データ登録に失敗する" do
      user = build(:user, email: nil)

      expect(user).to be_invalid
      expect(user.errors.details[:email][0][:error]).to eq :blank
    end
  end

  context "すでに登録されているメールアドレスが入力された時" do
    before { create(:user, email: "foo@example.com") }

    fit "データ登録に失敗する" do
      user = build(:user, email: "foo@example.com")

      expect(user).to be_invalid
      expect(user.errors.details[:email][0][:error]).to eq :taken
    end
  end

  context "フォーマットに沿わないメールアドレスが入力された時" do
    it "データ登録に失敗する" do
      user = build(:user, email: "aaaaaaaaaa")

      expect(user).to be_invalid
      expect(user.errors.messages[:email][0]).to eq "is not an email"
    end
  end
end
