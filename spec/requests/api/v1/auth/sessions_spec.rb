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
end
