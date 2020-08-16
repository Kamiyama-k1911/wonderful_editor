require 'rails_helper'

RSpec.describe "Articles", type: :request do
  describe "get /api/vi/articles.json" do
    subject { get(api_v1_articles_path) }
    before  { user_with_articles(articles_count: 3) }
      it "投稿一覧が取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user",]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(200)
      end
  end

  describe "get /api/vi/articles.json/:id" do
    subject { get(api_v1_article_path(article_id)) }
    context "指定したidの投稿が取得できる時" do

      let(:article) { create(:article) }
      let(:article_id) { article.id }
        fit "投稿詳細が取得できる" do

          subject

          res = JSON.parse(response.body)

          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["updated_at"]).to be_present
          expect(res.keys).to eq ["id", "title", "body", "updated_at", "user",]
          expect(res["user"].keys).to eq ["id", "name", "email"]
          expect(response).to have_http_status(200)
        end
    end

    context "指定したidの投稿が取得できる時" do
      let(:article_id) { 10000 }
        fit "投稿詳細が取得できない" do
          expect{ subject }.to raise_error ActiveRecord::RecordNotFound
        end
    end
  end
end
