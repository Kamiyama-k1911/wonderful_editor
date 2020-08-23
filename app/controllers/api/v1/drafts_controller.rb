class Api::V1::DraftsController < Api::V1::BaseApiController
  before_action :authenticate_user!

  def index
    @articles = Article.draft.order(updated_at: "DESC")
    render json: @articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    @article = Article.draft.find(params[:id])

    render json: @article, serializer: Api::V1::ArticleDetailSerializer
  end
end
