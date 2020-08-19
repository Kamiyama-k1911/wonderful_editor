require "rails_helper"

RSpec.describe "User", type: :request do
  describe "POST api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "正しいデータを入力した時" do
      let(:params) { attributes_for(:user) }
      it "ユーザー作成に成功する" do
        expect { subject }.to change { User.count }.by(1)
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)

        expect(res["data"]["name"]).to eq params[:name]
        expect(res["data"]["title"]).to eq params[:title]
      end

      it "期待したヘッダー情報が付与されている" do
        subject
        expect(response.header["access-token"]).to be_present
        expect(response.header["uid"]).to be_present
        expect(response.header["expiry"]).to be_present
        expect(response.header["token-type"]).to be_present
        expect(response.header["client"]).to be_present
      end
    end

    context "不正なデータを入力した時" do
      let!(:params) { attributes_for(:user, name: nil) }
      it "ユーザー作成に失敗する" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)

        expect(res["errors"]["name"][0]).to eq "can't be blank"
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "期待したヘッダー情報が付与されていない" do
        subject
        expect(response.header["access-token"]).not_to be_present
        expect(response.header["uid"]).not_to be_present
        expect(response.header["expiry"]).not_to be_present
        expect(response.header["token-type"]).not_to be_present
        expect(response.header["client"]).not_to be_present
      end
    end
  end
end
