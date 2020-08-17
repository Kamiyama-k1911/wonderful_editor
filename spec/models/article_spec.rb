# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  context "正しいデータを入力した時" do
    it "データ登録に成功する" do
      user = build(:article)
      expect(user).to be_valid
    end
  end

  context "タイトルが空のデータを入力した時" do
    it "データ登録に失敗する" do
      user = build(:article, title: nil)

      binding.pry

      expect(user).to be_invalid
      expect(user.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "本文が空のデータを入力した時" do
    it "データ登録に失敗する" do
      user = build(:article, body: nil)

      expect(user).to be_invalid
      expect(user.errors.details[:body][0][:error]).to eq :blank
    end
  end
end
