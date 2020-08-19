require "rails_helper"

RSpec.describe "User", type: :request do
  describe "POST api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "メールアドレスとパスワードを入力し、それらがUserモデルに存在していた時" do
      let!(:user) { create(:user) }
      let(:params) { { email: user.email, password: user.password } }
      it "ログインに成功する" do
        subject
        header = response.header
        expect(response).to have_http_status(:ok)
        expect(header["access-token"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["client"]).to be_present
      end
    end

    context "メールアドレスが間違っていた時" do
      let!(:user) { create(:user) }
      let(:params) { { email: "ajiaji", password: user.password } }
      it "期待したエラーを返す" do
        subject
        header = response.header
        res = JSON.parse(response.body)
        expect(header["access-token"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["client"]).to be_blank
        expect(res["errors"][0]).to eq "Invalid login credentials. Please try again."
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "パスワードが間違っていた時" do
      let(:other_user) { create(:user) }
      let!(:user) { create(:user) }
      let(:params) { { email: user.email, password: other_user.password } }
      it "期待したエラーを返す" do
        subject
        header = response.header
        res = JSON.parse(response.body)
        expect(header["access-token"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["client"]).to be_blank
        expect(res["errors"][0]).to eq "Invalid login credentials. Please try again."
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "適切な値を持っていた場合" do
      let!(:user) { create(:user) }
      let!(:headers) { user.create_new_auth_token }

      it "ログアウトに成功する" do
        expect { subject }.to change { user.reload.tokens }.from(be_present).to(be_blank)
        expect(response).to have_http_status(:ok)
      end
    end

    context "適切な値を持っていなかった場合" do
      let!(:user) { create(:user) }
      let!(:headers) { { "access-token": "", "token-type": "", client: "", expiry: "", uid: "" } }

      it "ログアウトに失敗する" do
        subject
        expect(response).to have_http_status(:not_found)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "User was not found or was not logged in."
      end
    end
  end
end
