require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "get /api/v1/articles.json" do
    subject { get(api_v1_articles_path) }

    before  { user_with_articles(articles_count: 3) }

    it "投稿一覧が取得できる" do
      subject
      res = JSON.parse(response.body)

      expect(res.length).to eq 3
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(response).to have_http_status(:ok)
    end
  end

  describe "get /api/v1/articles.json/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidの投稿が取得できる時" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }
      it "投稿詳細が取得できる" do
        subject

        res = JSON.parse(response.body)

        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res.keys).to eq ["id", "title", "body", "updated_at", "user"]
        expect(res["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "指定したidの投稿が取得できる時" do
      let(:article_id) { 10000 }
      it "投稿詳細が取得できない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "post /api/v1/articles.json" do
    subject { post(api_v1_articles_path, params: params) }

    context "正しいパラメータを入力した時" do
      let(:params) do
        { article: attributes_for(:article) }
      end
      let!(:current_user) { create(:user) }

      before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

      fit "新規記事投稿に成功する" do

        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:ok)
      end
    end

    context "不正なパラメータを入力した時" do
      let(:params) do
        attributes_for(:article)
      end
      let!(:user) { create(:user) }
      fit "新規記事投稿に失敗する" do
        expect{ subject }.to raise_error ActionController::ParameterMissing
      end
    end
  end
end
