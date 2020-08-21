require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /api/v1/articles.json" do
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

  describe "GET /api/v1/articles.json/:id" do
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

    context "指定したidの投稿が取得できない時" do
      let(:article_id) { 10000 }
      it "投稿詳細が取得できない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST /api/v1/articles.json" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:headers) { user.create_new_auth_token }
    context "正しいパラメータを入力した時" do
      let!(:user) { create(:user) }
      let(:params) { { article: attributes_for(:article) } }

      it "新規記事投稿に成功する" do
        expect { subject }.to change { Article.where(user_id: user.id).count }.by(1)
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
      it "新規記事投稿に失敗する" do
        expect { subject }.to raise_error ActionController::ParameterMissing
      end
    end
  end

  describe "PATCH /api/v1/articles.json/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:user) { create(:user) }
    let(:params) { { article: attributes_for(:article) } }
    let(:headers) { user.create_new_auth_token }
    context "自分が所持している記事のレコードを更新しようとするとき" do
      let(:article) { create(:article, user: user) }
      it "記事更新に成功する" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body])
        expect(response).to have_http_status(:ok)
      end
    end

    context "自分が所持していない記事のレコードを更新しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }
      it "記事更新に失敗する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) & change { Article.count }.by(0)
      end
    end
  end

  describe "DERETE /api/v1/articles.json/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let(:headers) { user.create_new_auth_token }
    let(:user) { create(:user) }
    context "自分が所持している記事のレコードを削除しようとするとき" do
      let!(:article) { create(:article, user: user) }
      let!(:article_id) { article.id }
      fit "記事削除に成功する" do
        subject
        binding.pry
        # expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "自分が所持していない記事のレコードを削除しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }
      let(:article_id) { article.id }

      it "記事削除に失敗する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) & change { Article.count }.by(0)
      end
    end
  end
end
