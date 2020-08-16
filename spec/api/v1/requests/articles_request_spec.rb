require 'rails_helper'

RSpec.describe "Articles", type: :request do
  describe "get /api/vi/articles.json" do
    subject { get(api_v1_articles_path) }
    before  { user_with_articles(articles_count: 3) }
      fit "投稿一覧が取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user",]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(200)
      end
  end
end
