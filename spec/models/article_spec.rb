# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :string           default("draft")
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
  describe "正常系" do
    context "statusがデフォルトの状態で正しいデータを入力した時" do
      let(:article) { build(:article) }
      it "下書きデータの登録に成功する" do
        expect(article).to be_valid
        expect(article.status).to eq "draft"
      end
    end

    context "statusがdraftの状態で正しいデータを入力した時" do
      let(:article) { build(:article, :with_draft) }
      it "下書きデータの登録に成功する" do
        expect(article).to be_valid
        expect(article.status).to eq "draft"
      end
    end

    context "statusがpublishedの状態で正しいデータを入力した時" do
      let(:article) { build(:article, :with_published) }
      it "公開データの登録に成功する" do
        expect(article).to be_valid
        expect(article.status).to eq "published"
      end
    end
  end

  context "タイトルが空のデータを入力した時" do
    it "データ登録に失敗する" do
      article = build(:article, title: nil)

      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "本文が空のデータを入力した時" do
    it "データ登録に失敗する" do
      article = build(:article, body: nil)

      expect(article).to be_invalid
      expect(article.errors.details[:body][0][:error]).to eq :blank
    end
  end
end
