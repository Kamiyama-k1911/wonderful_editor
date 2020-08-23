require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  describe "GET /api/v1/articles/draft" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    let(:headers) { user.create_new_auth_token }
    let(:user) { create(:user) }
    context "下書きを作成して下書き一覧ページに移動した時" do
      before { create_list(:article, 5, :with_draft) }

      it "下書き一覧が取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.length).to eq 5
        expect(res[0]["status"]).to eq "draft"
        expect(res[0].keys).to eq ["id", "title", "status", "updated_at", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "本書きを作成して下書き一覧ページに移動した時" do
      before { create_list(:article, 5, :with_published) }

      it "下書き一覧が取得できない" do
        subject
        res = JSON.parse(response.body)
        expect(res.length).to eq 0
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /api/v1/articles/draft/:id" do
    subject { get(api_v1_articles_draft_path(article.id), headers: headers) }

    let(:headers) { user.create_new_auth_token }
    let(:user) { create(:user) }
    context "記事の状態がdraftの下書き詳細ページに移動した時" do
      let(:article) { create(:article, :with_draft) }
      it "下書きの投稿詳細が取得できる" do
        subject

        res = JSON.parse(response.body)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res.keys).to eq ["id", "title", "body", "status", "updated_at", "user"]
        expect(res["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "記事の状態がpublishedの下書き詳細ページに移動した時" do
      let(:article) { create(:article, :with_published) }
      it "下書きの投稿詳細が取得できない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
